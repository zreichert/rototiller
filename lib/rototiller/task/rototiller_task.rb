require 'rake'
require 'rototiller/utilities/env_var_checker'
require 'rototiller/task/check_env'
require 'rototiller/task/acceptance_task'
require 'rototiller/task/flags/cli_flags'

module Rototiller
  module Task
    class RototillerTask

      include ::Rake::DSL if defined?(::Rake::DSL)
      include EnvVar
      include CLIFlags

      # Beaker CLI flags are stored on a module and mixed in
      @@cli_flag_names.each do |flag|
        attr_accessor flag
      end

      attr_accessor :framework

      def initialize(*args, &task_block)
        @name          = args.shift
        @ruby_opts     = nil
        @verbose       = true
        @fail_on_error = true

        define(args, &task_block)
      end

      def self.define_task(*args, &task_block)
        self.new(*args, &task_block)
      end

      def run_task
        if framework == 'beaker'
          Rototiller::Task::AcceptanceTask.define_task :execute do |t|
            @@cli_flag_names.each do |flag_name|
              flag_value = self.send(flag_name)
              t.send("#{flag_name}=", flag_value) if flag_value
            end
          end

        else
          task :execute do
            puts 'Beaker rspec task would go here'
          end
        end

        task :execute => [:check_env, @name]
        Rake::Task[:execute].invoke
      end

      private

      def define(args, &task_block)
        desc "A Rototiller Task" unless ::Rake.application.last_comment

        task(@name, *args) do |_, task_args|
          RakeFileUtils.__send__(:verbose, verbose) do
            task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block
            run_task
          end
        end
      end
    end
  end
end
