require 'rototiller/task/collections/env_collection'
require 'rototiller/task/collections/command_collection'
require 'rake/tasklib'
require 'rototiller/task/mixable_methods/add_env'

module Rototiller
  module Task

    class RototillerTask < ::Rake::TaskLib

      include Rototiller::Task::AddEnv

      attr_reader :name
      # Whether or not to fail Rake when an error occurs (typically when
      # examples fail). Defaults to `true`.
      # FIXME: make fail_on_error per-command
      attr_accessor :fail_on_error
      # A message to print to stderr when there are failures.
      # FIXME: make this per-command
      attr_accessor :failure_message

      def initialize(*args, &task_block)
        @name          = args.shift
        @fail_on_error = true
        @commands      = CommandCollection.new

        # rake's in-task implied method is true when using --verbose
        @verbose       = verbose == true
        @env_vars      = EnvCollection.new

        define(args, &task_block)
      end

      # define_task is included to allow task to work like Rake::Task
      # using .define_task or .new as appropriate
      def self.define_task(*args, &task_block)
        self.new(*args, &task_block)
      end

      # adds command to be executed by task
      # @param [Hash] args hash of information about the command to be executed
      # @option arg [String] :name The command to be executed
      # @option arg [String] :override_env An environment variable used to override the command to be executed by the task
      #
      # for block {|a| ... }
      # @yield [a] Optional block syntax allows you to specify information about command, available methods match hash keys
      def add_command(*args, &block)
        raise ArgumentError.new("#{__method__} takes a block or a hash") if !args.empty? && block_given?
        if block_given?
          @commands.push(Command.new(&block))
        else
          args.each do |arg| # we can accept an array of hashes, each of which defines a param
            error_string = "#{__method__} takes an Array of Hashes. Received Array of: '#{arg.class}'"
            raise ArgumentError.new(error_string) unless arg.is_a?(Hash)
            @commands.push(Command.new(arg))
          end
        end
      end

      private

      # @private
      # FIXME: separate out the exit stuff
      def print_messages
        puts @commands.format_messages
        puts @env_vars.format_messages
        exit_code = 1
        exit exit_code if @env_vars.stop? || @commands.stop?
      end

      # @private
      def run_task
        print_messages
        @commands.each do |command|
          puts command if @verbose

          command.run
          command_failed = command.result.exit_code > 0

          $stderr.puts failure_message if failure_message && command_failed
          $stderr.puts "'#{command}' failed" if @verbose && command_failed

          exit command.result.exit_code if fail_on_error && command_failed
        end
        # might be useful in output of t.add_command()?  but if not, Command has #result
        return @commands.map{ |command| command.result }
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

    end

  end
end
