require 'spec_helper'
require 'stringio'

module Rototiller::Task
  describe RototillerTask do

    #[:new, :define_task].each do |init_method|
    [:new].each do |init_method|
      let(:task) { described_class.send(init_method) }
      context "new: no args, no block" do
        it "inits members with '#{init_method}' method" do
          expect(task.name).to be nil
          expect(task.fail_on_error).to eq true
        end
        it "renders cli for '#{init_method}' method" do
          expect(task.command).to eq('echo empty RototillerTask. You should define a command, send a block, or EnvVar to track.')
        end

        def described_define
          task.__send__(:define, nil)
        end
        it 'registers the task' do
          expect(described_define).to be_an_instance_of(Rake::Task)
        end
      end

      context "with a name passed to the '#{init_method}' constructor" do
        task_named = described_class.send(init_method, :task_name)
        # using the let, spews the system call on stdout??
        #let(:task_named) { described_class.send(init_method,:task_name) }

        it "correctly sets the name" do
          expect(task_named.name).to eq :task_name
        end

        it "creates a default description with '#{init_method}'" do
          expect(task_named).to receive(:run_task) { true }
          expect(Rake.application.invoke_task("task_name")).to be_an(Array)
          # this will fail if previous tests don't adequately clear the desc stack
          # http://apidock.com/ruby/v1_9_3_392/Rake/TaskManager/get_description
          expect(Rake.application.last_comment).to eq 'RototillerTask: A Task with optional environment variable and command flag tracking'
        end
        #TODO override comment
      end

      context "with args passed to the '#{init_method}' rake task" do
        it "correctly passes along task arguments" do
          task_w_args = described_class.send(init_method, :rake_task_args, :files) do |t, args|
            expect(args[:files]).to eq "first"
          end

          expect(task_w_args).to receive(:run_task) { true }
          expect(Rake.application.invoke_task("rake_task_args[first]")).to be_an(Array)
        end
      end

      def described_run_task
        task.__send__(:run_task)
      end
      def silence_output(&block)
        expect(&block).to output(anything).to_stdout.and output(anything).to_stderr
      end
      context "when `failure_message` is configured" do
        before do
          allow(task).to receive(:exit)
          task.failure_message = "Bad news"
        end

        it 'prints it if the command run failed' do
          task.command = 'exit 1'
          expect { described_run_task }.to output(/Bad news/).to_stdout
        end

        it 'does not print it if the command run succeeded' do
          task.command = 'echo'
          expect { described_run_task }.not_to output(/Bad/).to_stdout
        end
      end

      context 'with custom exit status' do
        it 'returns the correct status on exit', :slow do
          expect(task).to receive(:exit).with(2)

          silence_output do
            task.command = 'ruby -e "exit(2);" ;#'
            described_run_task
          end
        end
      end

      context 'verbose and fail_on_error' do
        def described_verbose(verbose)
          task.__send__(:set_verbose,verbose)
        end
        it 'prints command failed' do
          expect(task).to receive(:exit).with(127)

          silence_output do
            task.command = 'exit 2'
            described_verbose(true)
            expect { described_run_task }.to output(/failed/).to_stderr
            described_verbose(false)
          end
        end
        it 'doesn\'t print if fail_on_error is false' do
          expect(task).to_not receive(:exit)

          silence_output do
            task.fail_on_error = false
            task.command = 'exit 2'
            expect { described_run_task }.to output("").to_stderr
          end
        end
      end

      context 'with flags' do
        it "renders cli for '#{init_method}' with one flag" do
          task.command = 'nocommand'
          task.add_flag('--yeshello')
          expect(described_run_task).to receive(:system).with('nocommand --yeshello')
        end
        it "renders cli for '#{init_method}' with multiple flags" do
          task.command = 'nocommand'
          task.add_flag('--yeshello')
          task.add_flag('-t')
          expect(described_run_task).to receive(:system).with('nocommand --yeshello -t')
        end
      end
    end

  end
end
