require 'spec_helper'

describe EnvVar do

  before(:all) do
    # add method to clean out class variable
    module EnvVar
      def self.clear_vars
        @@vars = []
      end
    end

  end

  before(:each) do
    # reset between tests
    EnvVar.clear_vars
    @var_one   = random_string
    @var_two   = random_string
    @var_three = random_string
  end

  # tasks would have the EnvVar class mixed into them
  let(:dummy_task_one)    { Class.new { extend EnvVar }}
  let(:dummy_task_two)    { Class.new { extend EnvVar }}
  let(:final_task)        { Class.new { extend EnvVar }}

  context 'Tracking Environment Variables' do

    it 'with one task' do
      default_value = 'foobar'
      expected_output =<<-EOS
\e[33mWARNING: the variable #{@var_one} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
\e[33mWARNING: the variable #{@var_two} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
\e[33mWARNING: the variable #{@var_three} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
EOS

      dummy_task_one.track_env_var(@var_one, "This is the message for #{@var_one}", default_value)
      dummy_task_one.track_env_var(@var_two, "This is the message for #{@var_two}", default_value)
      dummy_task_one.track_env_var(@var_three, "This is the message for #{@var_three}", default_value)
      expect{final_task.check_env_vars}.to output(expected_output).to_stdout
    end

    it 'with two tasks' do
      default_value = 'foobar'
      expected_output =<<-EOS
\e[33mWARNING: the variable #{@var_one} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
\e[33mWARNING: the variable #{@var_two} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
\e[33mWARNING: the variable #{@var_three} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
EOS

      dummy_task_one.track_env_var(@var_one, "This is the message for #{@var_one}", default_value)
      dummy_task_two.track_env_var(@var_two, "This is the message for #{@var_two}", default_value)
      dummy_task_one.track_env_var(@var_three, "This is the message for #{@var_three}", default_value)
      expect{final_task.check_env_vars}.to output(expected_output).to_stdout
    end
  end

  context 'Checking' do
    it 'raises an error without a default and no env set' do
      expected = /environment variable #{@var_two} is required. This is the message for #{@var_two}/
      dummy_task_one.track_env_var(@var_two, "This is the message for #{@var_two}")
      expect{final_task.check_env_vars}.to raise_error(expected)
    end
  end

end
