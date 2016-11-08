require 'open3'
require 'rototiller/task/collections/env_collection'
require 'rototiller/task/collections/switch_collection'
require 'rototiller/task/collections/option_collection'
require 'rototiller/task/collections/argument_collection'

module Rototiller
  module Task

    # The Command class to implement rototiller command handling
    #   via a RototillerTask's #add_command
    # @since v0.1.0
    # @attr [String] name The name of the command to run
    # @attr_reader [Struct] result A structured command result
    #    contains members: output, exit_code and pid (from Open3.popen2e)
    class Command < RototillerParam

      # @return [String] the command to be used, could be considered a default
      attr_accessor :name

      # @return [Struct] the command results, if run
      attr_reader :result

      # Creates a new instance of Command, holds information about desired state of a command
      # @param [Hash,Array<Hash>] args hashes of information about the command
      # for block { |b| ... }
      # @yield Command object with attributes matching method calls supported by Command
      # @return Command object
      def initialize(args={}, &block)
        # the env_vars that override the command name
        @env_vars      = EnvCollection.new
        @switches      = SwitchCollection.new
        @options       = OptionCollection.new
        @arguments     = ArgumentCollection.new

        block_given? ? (yield self) : send_hash_keys_as_methods_to_self(args)
        # @name is the default unless @env_vars returns something truthy
        (@name = @env_vars.last) if @env_vars.last
      end

      # adds environment variables to be tracked, messaged.
      #   In the Command context this env_var overrides the command "name"
      # @param [Hash] args hashes of information about the environment variable
      # @option args [String] :name The environment variable
      # @option args [String] :default The default value for the environment variable
      # @option args [String] :message A message describing the use of this variable
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the environment variable, available methods match hash keys
      def add_env(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        # this is kinda annoying we have to do this for all params? (not DRY)
        #   have to do it this way so EnvVar doesn't become a collection
        #   but if this gets moved to a mixin, it might be more tolerable
        if block_given?
          new_env_var = EnvVar.new(&block)
          @env_vars.push(new_env_var)
        else
          #TODO: test this with array and non-array single hash
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            new_env_var = EnvVar.new(arg)
            @env_vars.push(new_env_var)
          end
        end
        @name = @env_vars.last if @env_vars.last
      end

      def add_switch(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        # this is kinda annoying we have to do this for all params? (not DRY)
        #   have to do it this way so EnvVar doesn't become a collection
        #   but if this gets moved to a mixin, it might be more tolerable
        if block_given?
          @switches.push(Switch.new(&block))
        else
          #TODO: test this with array and non-array single hash
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            @switches.push(Switch.new(arg))
          end
        end
      end

      def add_option(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        # this is kinda annoying we have to do this for all params? (not DRY)
        #   have to do it this way so EnvVar doesn't become a collection
        #   but if this gets moved to a mixin, it might be more tolerable
        if block_given?
          @options.push(Option.new(&block))
        else
          #TODO: test this with array and non-array single hash
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            @options.push(Option.new(arg))
          end
        end
      end

      # adds argument to append to command.
      #   In the Command context this Argument is added to the end of the command string
      # @param [Hash] args hashes of information about the argument
      # @option args [String] :name The value to be used as the argument
      # @option args [String] :message A message describing the use of argument
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the option, available methods match hash keys
      def add_argument(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        if block_given?
          @arguments.push(Argument.new(&block))
        else
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            @arguments.push(Argument.new(arg))
          end
        end
      end

      # TODO make private method? so that it will throw an error if yielded to?
      # convert a Command object to a string (runable command string)
      # @return [String]
      def to_str
        delete_nil_empty_false([
          (name if name),
          @switches.to_s,
          @options.to_s,
          @arguments.to_s
        ]).join(' ').to_s
      end
      alias :to_s :to_str

      Result = Struct.new(:output, :exit_code, :pid)
      # run Command locally, capture relevent result data
      # @return [Struct<Result>] a Result Struct with stdout, stderr, exit_code members
      def run
        # make this look a bit like beaker's result class
        #   we may have to convert this to a class if it gets complex
        @result = Result.new
        @result.output = ''
        # add ';' to command string as it is a metacharacter that forces open3
        #   to send the command to the shell. This returns the correct
        #   exit_code and stderr, etc when the command is not found
        Open3.popen2e(self.to_str + ";"){|stdin, stdout_err, wait_thr|
          stdout_err.each { |line| puts line
                            @result.output << line }
          @result.pid    = wait_thr.pid # pid of the started process.
          @result.exit_code = wait_thr.value.exitstatus # Process::Status object returned.
        }

        if block_given? # if block, send result to the block
          yield @result
        end
        @result
      end

      # Does this param require the task to stop
      # Determined by the interactions between @name, @env_vars, @options, @switches, @arguments
      # @return [true|nil] if this param requires a stop
      def stop
        return true if [@switches, @options, @arguments].any?{ |collection| collection.stop? }
        return true unless @name
      end

      private
      # @private
      def delete_nil_empty_false(arg)
        arg.delete_if{ |i| ([nil, '', false].include?(i)) }
      end
    end

  end
end
