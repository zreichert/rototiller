require 'rake'
require 'rake/tasklib'
require 'rototiller/task/flags/cli_flags'

module Rototiller
  module Task
    class AcceptanceTask < ::Rake::TaskLib
      # CLI flags are stored on a module and mixed in
      include CLIFlags
      include ::Rake::DSL if defined?(::Rake::DSL)
      include EnvVar

      @@cli_flag_names.each do |flag|
        attr_accessor flag
      end

      # Whether or not to fail Rake when an error occurs (typically when
      # examples fail). Defaults to `true`.
      attr_accessor :fail_on_error

      # A message to print to stderr when there are failures.
      attr_accessor :failure_message

      # Use verbose output. If this is set to true, the task will print the
      # command to stdout. Defaults to `true`.
      attr_accessor :verbose

      def initialize(*args, &task_block)
        @name          = args.shift || :acceptance
        @flags = {}
        @verbose       = true
        @fail_on_error = true

        define(args, &task_block)
      end

      def self.define_task(*args, &task_block)
        self.new(*args, &task_block)
      end

      def run_task(verbose)
        command = generate_command
        puts command if verbose

        # run it!
        # TODO: create a command class that uses Open3 so we get stdout/err
        return if system(command)
        puts failure_message if failure_message

        return unless fail_on_error
        $stderr.puts "#{command} failed" if verbose
        #exit $?.exitstatus
      end

      private

      # @private
      def define(args, &task_block)
        desc "An Acceptance Task" unless ::Rake.application.last_comment

        task(@name, *args) do |_, task_args|
          RakeFileUtils.__send__(:verbose, verbose) do
            task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block
            run_task(verbose)
          end
        end
      end

      def set_flags
        @@cli_flag_names.each do |flag|
          @flags["--#{flag}"] = instance_variable_get("@#{flag}") if instance_variable_get("@#{flag}")
        end
      end

      # create a cli string of flags from the hash
      def generate_cli_flags
        @flags.map{|pair| pair.join(' ')}.join(' ').gsub(' true','')
      end

      def generate_command
        set_flags
        cli = "beaker "
        cli += generate_cli_flags
        #cli += " #{ENV["BEAKER_OPTS"]}" if o
        return cli
      end

    end
  end
end
