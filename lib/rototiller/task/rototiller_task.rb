require 'rototiller/utilities/env_var_checker'
require 'rake/tasklib'

module Rototiller
  module Task
    class RototillerTask < ::Rake::TaskLib
      attr_accessor :name
      attr_accessor :command

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
        @env_vars      = []
        @flags         = []

        define(args, &task_block)
      end

      # define_task is included to allow task to work like Rake::Task
      # using .define_task or .new as appropriate
      def self.define_task(*args, &task_block)
        self.new(*args, &task_block)
      end

      def add_env(env_vars)
        (@env_vars << env_vars).flatten!
      end

      def add_flag(flag)
        (@flags << flag).flatten!
      end

      private

      # @private
      def run_task
        command_str = @command + ' ' + @flags.join(' ')
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
        desc "RototillerTask: A Task with optional environment variable and command flag tracking" unless ::Rake.application.last_comment

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
