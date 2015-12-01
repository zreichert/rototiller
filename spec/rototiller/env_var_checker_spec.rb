require 'spec_helper'

describe EnvVar do

  def random_string
    (0...10).map { ('a'..'z').to_a[rand(26)] }.join
  end

  before(:all) do
    # add method to clean out class variable
    module EnvVar
      def self.clear_vars
        @@vars = []
      end
    end

  end

  # tasks would have the EnvVar class mixed into them
  let(:dummy_task_one)    { Class.new { extend EnvVar }}
  let(:dummy_task_two)    { Class.new { extend EnvVar }}
  let(:final_task)        { Class.new { extend EnvVar }}
  let(:var_one)           { random_string }
  let(:var_two)           { random_string }
  let(:var_three)         { random_string }

  context 'Checking Environment Variables with defaults' do

    after(:each) do
      # reset between tests
      EnvVar.clear_vars
    end

    it 'with one task' do
      default_value = 'foobar'
      expected_output =<<-EOS
\e[33mWARNING: the variable #{var_one} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
\e[33mWARNING: the variable #{var_two} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
\e[33mWARNING: the variable #{var_three} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
EOS

      dummy_task_one.track_env_var(var_one, "This is the message for #{var_one}", default_value)
      dummy_task_one.track_env_var(var_two, "This is the message for #{var_two}", default_value)
      dummy_task_one.track_env_var(var_three, "This is the message for #{var_three}", default_value)
      expect{final_task.check_env_vars}.to output(expected_output).to_stdout
    end

    it 'with two tasks' do
      default_value = 'foobar'
      expected_output =<<-EOS
\e[33mWARNING: the variable #{var_one} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
\e[33mWARNING: the variable #{var_two} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
\e[33mWARNING: the variable #{var_three} is not set, proceeding with default value: \e[0m\e[32m#{default_value}\e[0m
EOS

      dummy_task_one.track_env_var(var_one, "This is the message for #{var_one}", default_value)
      dummy_task_two.track_env_var(var_two, "This is the message for #{var_two}", default_value)
      dummy_task_one.track_env_var(var_three, "This is the message for #{var_three}", default_value)
      expect{final_task.check_env_vars}.to output(expected_output).to_stdout
    end
  end

  context 'Checking with and without defaults' do
    #TODO complete tests for EnvVar
  end

  context 'With and without defaults' do
    #TODO complete tests for EnvVar
  end
end
