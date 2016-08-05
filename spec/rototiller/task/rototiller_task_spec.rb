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
          expect(Rake.application.last_description).to eq 'RototillerTask: A Task with optional environment-variable and command-flag tracking'
        end
        #TODO override comment
        it "doesn't say last_comment is deprecated '#{init_method}'" do
          expect { described_run_task }.not_to output(/\[DEPRECATION\] `last_comment`/).to_stdout
        end
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
          task.add_command({:name => 'exit 1'})
          expect { described_run_task }.to output(/Bad news/).to_stderr
        end

        it 'does not print it if the command run succeeded' do
          task.add_command({:name =>  'echo'})
          expect { described_run_task }.not_to output(/Bad/).to_stderr
        end
      end

      context 'with custom exit status' do
        it 'returns the correct status on exit', :slow do
          expect(task).to receive(:exit).with(2)
          task.add_command({:name => 'ruby -e "exit(2);" ;#'})
          described_run_task
        end
      end

      context 'verbose and fail_on_error' do
        def described_verbose(verbose)
          task.__send__(:set_verbose,verbose)
        end
        it 'prints command failed' do
          # argh!  (facepalm)
          if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.0.0')
            expect(task).to receive(:exit).with(127)
          else
            expect(task).to receive(:exit).with(2)
          end

          #FIXME: despite the silence_output some of these are spewing
          #  this is because we set command to "echo empty RototillerTask. You should define a command, send a block, or EnvVar to track."
          #  so any of these that run system spews that to the output.  We should probably not set that as the default command.  it's a bit verbose and pedantic.
          #  it doesn't check if there are any envs or other tasks, and there are good reasons to not have a command, in some cases
          silence_output do
            task.add_command({:name => 'exit 2'})
            described_verbose(true)
            expect { described_run_task }.to output(/failed/).to_stderr
            described_verbose(false)
          end
        end
        it 'doesn\'t print if fail_on_error is false' do
          expect(task).to_not receive(:exit)
          task.fail_on_error = false
          task.add_command({:name =>  'exit 2'})
          expect { described_run_task }.to output("").to_stderr
        end
      end

      context 'with env vars' do
      # add_env(EnvVar.new(), EnvVar.new(), EnvVar.new())
      # add_env('FOO', 'This is how you use FOO', 'default_value')
        #def initialize(var, message, default=false)
        let(:env_name) {unique_env}
        let(:env_desc) {'used in some task for some purpose'}
        let(:env_default) {'default_value'}
        let(:env_message_header) {"The environment variable: '#{env_name}'"}
        it "prints error about missing environment variable created via EnvVar.new()" do
          task.add_env({:name => env_name, :message => env_desc})
          expect(task).to receive(:exit)
          expect{ described_run_task }
            .to output(/ERROR: #{env_message_header} is required: #{env_desc}/)
            .to_stdout
        end
        #TODO: add warning case
        it "prints description about missing environment variable with default created via block syntax" do
          task.add_env do |env|
            env.name = env_name
            env.default = env_default
            env.message = env_desc
          end
          expect{ described_run_task }
            .to output(/INFO: #{env_message_header} was found with value: '#{env_default}': #{env_desc}/)
            .to_stdout
        end
        it "prints error about missing environment variable created via add_env" do
          task.add_env({:name => env_name, :message => env_desc})
          expect(task).to receive(:exit)
          expect{ described_run_task }
            .to output(/ERROR: #{env_message_header} is required: #{env_desc}/)
            .to_stdout
        end
        it "prints description about missing environment variable with default created via add_env" do
          task.add_env({:name => env_name,:default => env_default, :message => env_desc})
          expect{ described_run_task }
            .to output(/INFO: #{env_message_header} was found with value: '#{env_default}': #{env_desc}/)
            .to_stdout
        end
        #TODO add INFO case
        #TODO add expect to raise with other case, if possible
        it "raises argument error for too many env string args" do
          expect{ task.add_env('-t', '-t description', 'tvalue2', 'someother') }.to raise_error(ArgumentError)
        end
        it "add_env can take 4 EnvVar args" do
          task.add_env({:name => env_name, :message => env_desc},{:name => 'VAR2', :message => env_desc},
                       {:name => 'VAR3',:message => env_desc},{:name => env_name,:message => env_desc})
          expect(task).to receive(:exit)
          expect{ described_run_task }
            .to output(/ERROR: #{env_message_header} is required: #{env_desc}.*VAR2.*VAR3.*#{env_name}/m)
            .to_stdout
        end
      end
    end

  end
end
