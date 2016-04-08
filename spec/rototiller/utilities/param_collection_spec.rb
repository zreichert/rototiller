require 'spec_helper'

describe ParamCollection do

  let(:param_collection)              { ParamCollection.new }
  let(:set_env_1_with_default)        { EnvVar.new(set_random_env, 'description', 'devault value') }
  let(:set_env_2_with_default)        { EnvVar.new(set_random_env, 'description', 'devault value') }
  let(:unset_env_1_with_default)      { EnvVar.new(unique_env, 'description', 'devault value') }
  let(:unset_env_2_with_default)      { EnvVar.new(unique_env, 'description', 'devault value') }
  let(:set_env_1_no_default)          { EnvVar.new(set_random_env, 'description') }
  let(:set_env_2_no_default)          { EnvVar.new(set_random_env, 'description') }
  let(:unset_env_1_no_default)        { EnvVar.new(unique_env, 'description') }
  let(:unset_env_2_no_default)        { EnvVar.new(unique_env, 'description') }

  context '.push' do

    it 'adds a single ENV' do
      expect{ param_collection.push(set_env_1_no_default) }.not_to raise_error
      expect(param_collection).to include(set_env_1_no_default)
    end

    it 'adds multiple ENVs' do
      expect{ param_collection.push(set_env_1_no_default, unset_env_1_with_default, set_env_1_with_default) }.not_to raise_error
      expect(param_collection).to include(set_env_1_no_default)
      expect(param_collection).to include(unset_env_1_with_default)
      expect(param_collection).to include(set_env_1_with_default)
    end
  end

  context '.format_messages' do

    let(:vars) do
      [
          set_env_1_with_default, set_env_2_with_default, set_env_1_no_default,
          unset_env_2_no_default, unset_env_2_with_default, set_env_2_no_default,
          unset_env_1_no_default, unset_env_1_with_default
      ]
    end

    it 'should work with no arguments' do
      param_collection.push(*vars)

      messages = param_collection.format_messages

      vars.each do |var|
        expect(messages).to match(/#{var.var}/)
      end
    end

    let(:env_message_header) {"The environment variable:"}
    it 'should work with one filter' do
      param_collection.push(*vars)

      [unset_env_1_no_default, unset_env_2_no_default].each do |var|
        expected_message = /31mERROR: #{env_message_header} '#{var.var}' is required: description/
        expect(param_collection.format_messages({:stop => true})).to match(expected_message)
      end
    end

    it 'should work with two filters' do
      param_collection.push(*vars)

      [set_env_1_no_default, set_env_2_no_default].each do |var|
        expected_message = /32mINFO: #{env_message_header} '#{var.var}' was found with value: '#{ENV[var.var]}'/
        expect(param_collection.format_messages({:default => nil, :message_level => :info})).to match(expected_message)
      end
    end
  end

end
