require 'rototiller/utilities/env_var'
require 'rototiller/utilities/param_collection'
require 'rototiller/utilities/env_collection'
require 'rototiller/utilities/flag_collection'
require 'rototiller/utilities/command_flag'
require 'rototiller/utilities/command'
require 'rototiller/utilities/block_syntax_object'
require 'rake/tasklib'

module Rototiller
  module Task
    class RototillerTask < ::Rake::TaskLib
      #TODO rename instance vars and methods to not match sub blocks
      attr_reader :name
      attr_reader :command
      attr_reader :override_env

      # Whether or not to fail Rake when an error occurs (typically when
      # examples fail). Defaults to `true`.
      attr_accessor :fail_on_error

      # A message to print to stderr when there are failures.
      attr_accessor :failure_message

      def initialize(*args, &task_block)
        @name          = args.shift
        @fail_on_error = true
        @command       = 'echo empty RototillerTask. You should define a command, send a block, or EnvVar to track.'
        # rake's in-task implied method is true when using --verbose
        @verbose       = verbose == true
        @env_vars      = EnvCollection.new
        @flags         = FlagCollection.new

        define(args, &task_block)
      end

      # define_task is included to allow task to work like Rake::Task
      # using .define_task or .new as appropriate
      def self.define_task(*args, &task_block)
        self.new(*args, &task_block)
      end

      # adds environment variables to be tracked
      # @param [Hash] *args hashes of information about the environment variable
      # @option args [String] :name The environment variable
      # @option args [String] :default The default value for the environment variable
      # @option args [String] :message A message describing the use of this variable
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the environment variable, available methods track hash keys
      def add_env(*args,&block)
        raise ArgumentError.new("add_env takes a block or a hash") if !args.empty? && block_given?
        attributes = [:name, :default, :message]
        add_param(@env_vars, EnvVar, attributes, args, &block)
      end

      # adds command line flags to be used in a command
      # @param [Hash] *args hashes of information about the command line flag
      # @option args [String] :name The command line flag
      # @option args [String] :value The value for the command line flag
      # @option args [String] :message A message describing the use of this command line flag
      # @option args [String] :override_env An environment variable used to override the flag value
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about the command line flag, available methods track hash keys
      def add_flag(*args, &block)
        raise ArgumentError.new("add_flag takes a block or a hash") if !args.empty? && block_given?
        attributes = [:name, :default, :message, :override_env]
        add_param(@flags, CommandFlag, attributes, args, &block)
      end

      # adds command to be executed by task
      # @param [Hash] args hash of information about the command to be exedcuted
      # @option arg [String] :name The command to be executed
      # @option arg [String] :override_env An environment variable used to override the command to be executed by the task
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about command, available methods track hash keys
      def add_command(args={}, &block)
        attributes = [:name, :override_env]
        if block_given?
          attribute_hash = pull_params_from_block(attributes, &block).to_h
        else
          attribute_hash = args
        end
        @command = Rototiller::Command.new(attribute_hash).name
      end

      private

      def print_messages
        puts @flags.format_messages
        puts @env_vars.format_messages
        exit_code = 1
        exit exit_code if @env_vars.stop? || @flags.stop?
      end

      # @private
      def run_task
        print_messages
        command_str = @command + @flags.to_s
        puts command_str if @verbose

        return if system(command_str)
        puts failure_message if failure_message

        return unless fail_on_error
        $stderr.puts "#{command_str} failed" if @verbose
        exit $?.exitstatus
      end

      # @private
      # register the new block w/ run_task call in a rake task
      #   any block passed is run prior to our command
      # TODO: probably need pre/post-command block functionality
      def define(args, &task_block)
        # Default task description
        # can be overridden with standard 'desc' DSL method
        desc 'RototillerTask: A Task with optional environment-variable and command-flag tracking' unless ::Rake.application.last_description

        task(@name, *args) do |_, task_args|
          RakeFileUtils.__send__(:verbose, @verbose) do
            task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block
            run_task
          end
        end
      end

      # @private
      #   for unit testing, we need a shortcut around rake's CLI --verbose
      def set_verbose(verbosity=true)
        @verbose = verbosity
      end

      def add_param(collection, param_class, param_array, args, &block)

        if block_given?

          param_hash = pull_params_from_block(param_array, &block).to_h
          collection.push(param_class.new(param_hash))
        else

          args.each do |arg|

            raise ArgumentError.new("Argument must ba a Hash not a #{arg.class}") unless arg.is_a?(Hash)
            collection.push(param_class.new(arg))
          end
        end
      end

      def pull_params_from_block(param_array, &block)

        block_syntax_obj = Rototiller::Block_syntax.new(param_array)
        yield(block_syntax_obj)
        block_syntax_obj
      end
    end
  end
end
