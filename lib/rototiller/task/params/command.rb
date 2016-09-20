require 'open3'
require 'rototiller/task/params'
require 'rototiller/task/params/env_var'
require 'rototiller/task/block_handling'

module Rototiller
  module Task

    # The Command class to implement rototiller command handling
    #   via a RototillerTask's #add_command
    # @since v0.1.0
    # @attr [String] name The name of the command to run
    # @attr_reader [Struct] result A structured command result
    #    contains members: output, exit_code and pid (from Open3.popen2e)
    # @attr [String] argument Command argument (this will change to add_argument in the next release)
    # @attr [String] argument_override_env The environment variable (if any) users can employ to override the above argument
    #    (this will change to Argument's #add_env in the next release)
    class Command < RototillerParam
      include Rototiller::ColorText
      include BlockHandling

      # @return [String] the command to be used, could be considered a default
      attr_accessor :name

      # @return [Struct] the command results, if run
      attr_reader :result

      # @return [EnvVar] the ENV that is equal to this command
      attr_accessor :override_env

      # @return [String, nil] the value that should be used as an argument to the given command
      attr_accessor :argument

      # @return [EnvVar] the ENV that is equal to the argument to be used with this command
      attr_accessor :argument_override_env

      # Creates a new instance of Command, holds information about desired state of a command
      # @param [Hash,Array<Hash>] args hashes of information about the command
      # for block { |b| ... }
      # @yield Command object with attributes matching method calls supported by Command
      # @return Command object
      def initialize(args={}, &block)
        if block_given?
          required_attributes = [:name, :override_env, :argument, :argument_override_env]
          attribute_hash = pull_params_from_block(required_attributes, &block)
        else
          attribute_hash = args
        end
        # TODO: make this a global options hash?
        #   no, needs to be per-param with a default to false except in task's env_var, the other env_vars should not pollute the environment space
        #attribute_hash[:set_env] = true if opts[:set_env]

        # check if an override_env is provided
        if attribute_hash[:override_env]
          @override_env = EnvVar.new({:name => attribute_hash[:override_env], :default => attribute_hash[:name]})
          @name = @override_env.value
        else
          @name = attribute_hash[:name]
        end

        # check if an argument_override_env is provided
        if attribute_hash[:argument_override_env]
          @argument_override_env = EnvVar.new({:name => attribute_hash[:argument_override_env], :default => attribute_hash[:argument]})
          @argument = @argument_override_env.value
        else
          @argument = attribute_hash[:argument]
        end

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
          @env_vars.push(EnvVar.new(&block))
        else
          #TODO: test this with array and non-array single hash
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            @env_vars.push(EnvVar.new(arg))
          end
        end
        # remove the nils and return the last known value
        @name = @env_vars.map{|x| x.value}.compact.last.to_s if @env_vars.any?
      end

      # convert a Command object to a string (runable command string)
      # @return [String]
      def to_str
        delete_nil_empty_false([
          (name if name),
          @flags.to_s,
          (argument if argument)
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

      private
      # @private
      def delete_nil_empty_false(arg)
        arg.delete_if{ |i| ([nil, '', false].include?(i)) }
      end
    end

  end
end
