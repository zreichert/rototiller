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
          task.command = 'ruby -e "exit(2);" ;#'
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
            task.command = 'exit 2'
            described_verbose(true)
            expect { described_run_task }.to output(/failed/).to_stderr
            described_verbose(false)
          end
        end
        it 'doesn\'t print if fail_on_error is false' do
          expect(task).to_not receive(:exit)
          task.fail_on_error = false
          task.command = 'exit 2'
          expect { described_run_task }.to output("").to_stderr
        end
      end

      # TODO: reduce repetition
      context 'with flags' do
        let(:command) {'nonesuch'}
        let(:flag1) {'--flagoner'}
        it "renders cli for '#{init_method}' with one flag" do
          task.command = command
          task.add_flag(flag1, 'description')
          expect(task).to receive(:system).with("#{command} #{flag1}").and_return(true)
          silence_output do
            described_run_task
          end
        end
        it "renders cli for '#{init_method}' with multiple flags" do
          task.command = command
          task.add_flag(flag1, 'other description')
          task.add_flag('-t', '-t description', 'tvalue')
          expect(task).to receive(:system).with("#{command} #{flag1} -t -t description").and_return(true)
          silence_output do
            described_run_task
          end
        end
        it "prints messages for '#{init_method}' with single nonvalue CLI flag" do
          task.add_flag('-t', '-t description')
          expect{ described_run_task }
            .to output(/CLI flag -t will be used, no value was provided/)
            .to_stdout
        end
        it "prints messages for '#{init_method}' with single value CLI flag" do
          task.add_flag('-t', '-t description', 'tvalue2')
          expect{ described_run_task }
            .to output(/CLI flag -t will be used with value -t description/)
            .to_stdout
        end
        it "raises argument error for too many flag args" do
          expect{ task.add_flag('-t', '-t description', 'tvalue2', 'someother') }.to raise_error(ArgumentError)
        end
      end
      context 'with env vars' do
      # add_env(EnvVar.new(), EnvVar.new(), EnvVar.new())
      # add_env('FOO', 'This is how you use FOO', 'default_value')
        #def initialize(var, message, default=false)
        let(:env_name) {'VAR'}
        let(:env_desc) {'used in some task for some purpose'}
        let(:env_default) {'default_value'}
        it "prints error about missing environment variable created via EnvVar.new()" do
          task.add_env(EnvVar.new(env_name, env_desc))
          expect(task).to receive(:exit)
          expect{ described_run_task }
            .to output(/The ENV #{env_name} is required, #{env_desc}/)
            .to_stdout
        end
        it "prints description about missing environment variable with default created via EnvVar.new()" do
          task.add_env(EnvVar.new(env_name, env_desc, env_default))
          expect{ described_run_task }
            .to output(/WARNING: the ENV #{env_name} is not set.*default value: used in some/)
            .to_stdout
        end
        it "prints error about missing environment variable created via add_env" do
          task.add_env(env_name, env_desc)
          expect(task).to receive(:exit)
          expect{ described_run_task }
            .to output(/The ENV #{env_name} is required, #{env_desc}/)
            .to_stdout
        end
        it "prints description about missing environment variable with default created via add_env" do
          task.add_env(env_name, env_desc, env_default)
          expect{ described_run_task }
            .to output(/WARNING: the ENV #{env_name} is not set.*default value: used in some/)
            .to_stdout
        end
        it "raises argument error for too many env string args" do
          expect{ task.add_env('-t', '-t description', 'tvalue2', 'someother') }.to raise_error(ArgumentError)
        end
        it "add_env can take 4 EnvVar args" do
          task.add_env(EnvVar.new(env_name,env_desc),EnvVar.new('VAR2',env_desc),
                       EnvVar.new('VAR3',  env_desc),EnvVar.new(env_name,env_desc))
          expect(task).to receive(:exit)
          expect{ described_run_task }
            .to output(/The ENV #{env_name} is required, #{env_desc}.*VAR2.*#{env_desc}.*#{env_name}/m)
            .to_stdout
        end
      end
    end

  end
end
