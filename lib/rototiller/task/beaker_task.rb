require 'rake'
require 'rototiller/task/flags/cli_flags'

module Rototiller
  module Task
    class BeakerTask

      # Beaker CLI flags are stored on a module and mixed in
      include CLIFlags
      @@cli_flag_names.each do |flag|
        attr_accessor flag
      end

      include ::Rake::DSL if defined?(::Rake::DSL)
      include EnvVar

      def initialize(*args, &task_block)
        @name          = args.shift
        @ruby_opts     = nil
        @verbose       = true
        @fail_on_error = true

        define(args, &task_block)
      end

      # define_task is included to allow task to work like Rake::Task
      # using .define_task or .new is appropriate
      def self.define_task(*args, &task_block)
        self.new(*args, &task_block)
      end

      def run_task(verbose)
        command = beaker_command
        puts command if verbose

        # currently this does not execute
        # as a Demo this should not actually run beaker
      end

      private

      def define(args, &task_block)
        # Default task description
        # can be overridden with 'desc' method
        desc "A Beaker Task" unless ::Rake.application.last_comment

        task(@name, *args) do |_, task_args|
          RakeFileUtils.__send__(:verbose, verbose) do
            task_block.call(*[self, task_args].slice(0, task_block.arity)) if task_block
            run_task(verbose)
          end
        end
      end

      def beaker_command
        beaker = "beaker "
        beaker += " --xml" if @xml
        beaker += " --debug" if @debug
        beaker += " --root-keys" if @root_keys
        beaker += " --repo-proxy" if @repo_proxy
        beaker += " --preserve-hosts #{@preserve_hosts}" if @preserve_hosts
        beaker += " --config #{@helper}" if @helper
        beaker += " --type #{@type}" if @type
        beaker += " --keyfile #{@keyfile}" if @keyfile
        beaker += " --options-file #{@options_file}" if @options_file
        beaker += " --load-path #{@load_path}" if @load_path
        beaker += " --pre-suite #{@pre_suite}" if @pre_suite
        beaker += " --post-suite #{@post_suite}" if @post_suite
        beaker += " --tests #{@tests}" if @tests
        #beaker += " #{ENV["BEAKER_OPTS"]}" if o
        return beaker
      end

    end
  end
end
