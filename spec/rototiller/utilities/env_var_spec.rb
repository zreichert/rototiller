require 'spec_helper'

describe EnvVar do

  @count = 0
  ['with_default', 'without_default'].each do |method_signature|

    context method_signature do

      ['ENV set', 'ENV not set'].each do |env_set|

        context env_set do

          let (:var_name)       { "VARNAME_#{(0...8).map { (65 + rand(26)).chr }.join}" }
          let (:var_message)    { "This is how you use #{var_name}" }
          let (:var_default)    { "VARDEFAULT_#{(0...8).map { (65 + rand(26)).chr }.join}" }
          let (:var_env_value)  { "VARENVVALUE_#{(0...8).map { (65 + rand(26)).chr }.join}" }

          before(:each) do
            if env_set == 'ENV set'
              ENV[var_name] = var_env_value
              @var_value = var_env_value
            else
              ENV[var_name] = nil
              @var_value = method_signature == 'with_default' ? var_default : false
            end

            args = [var_name, var_message]
            args.insert(1, var_default) if method_signature == 'with_default'
            @env_var = EnvVar.new(*args)

            @expected_var_default = var_default
            @expected_var_default = false if (method_signature == 'without_default' && env_set == 'ENV not set')
            @expected_var_default = false if (method_signature == 'without_default' && env_set == 'ENV set')

            # validation
            if (method_signature == 'with_default' && env_set == 'ENV not set')
              @formatted_message = "\e[33mWARNING: the ENV #{var_name} is not set, proceeding with default value: #{var_default}\e[0m"
              @expected_stop = nil
            elsif (method_signature == 'without_default' && env_set == 'ENV not set')
              @formatted_message = "\e[31mThe ENV #{var_name} is required, #{var_message}\e[0m"
              @expected_stop = true
            #elsif (method_signature == 'without_default' && env_set == 'ENV set')
            elsif (env_set == 'ENV set')
              @formatted_message = "\e[32mThe ENV #{var_name} was found in the environment with the value #{var_env_value}\e[0m"
              @expected_stop = nil
            end


          end

          describe '.var' do

            it 'returns the var' do
              expect(@env_var.var).to eq(var_name)
            end
          end

          describe '.message' do

            it 'returns the formatted message' do
              expect(@env_var.message).to eq(@formatted_message)
            end
          end

          describe '.value' do

            it 'returns the value of the ENV' do
              expect(@env_var.value).to eq(@var_value)
            end
          end

          describe '.default' do

            it 'returns the default value' do
              expect(@env_var.default).to eq(@expected_var_default)
            end
          end

          describe '.stop' do

            it 'knows if it should stop' do
              expect(@env_var.stop).to eq(@expected_stop)
            end
          end
        end
      end
    end
  end
end
