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

  context '.push_params' do

    it 'adds a single ENV' do
      expect{ param_collection.push_params(set_env_1_no_default) }.not_to raise_error
      expect(param_collection).to include(set_env_1_no_default)
    end

    it 'adds multiple ENVs' do
      expect{ param_collection.push_params(set_env_1_no_default, unset_env_1_with_default, set_env_1_with_default) }.not_to raise_error
      expect(param_collection).to include(set_env_1_no_default)
      expect(param_collection).to include(unset_env_1_with_default)
      expect(param_collection).to include(set_env_1_with_default)
    end

    it 'fails if argument is not an EnvVar' do
      expect{ param_collection.push_params('foobar')}.to raise_error(ArgumentError)
    end
  end

  context '.stop?' do

    it 'should not stop' do
      param_collection.push_params(set_env_1_with_default)
      param_collection.push_params(set_env_2_with_default)
      param_collection.push_params(set_env_1_no_default)
      param_collection.push_params(set_env_2_no_default)
      param_collection.push_params(unset_env_1_with_default)
      param_collection.push_params(unset_env_2_with_default)

      expect(param_collection.stop?).to be_falsey
    end

    it 'should stop' do
      param_collection.push_params(set_env_1_with_default)
      param_collection.push_params(set_env_2_with_default)
      param_collection.push_params(set_env_1_no_default)
      param_collection.push_params(set_env_2_no_default)
      param_collection.push_params(unset_env_1_with_default)
      param_collection.push_params(unset_env_2_with_default)
      param_collection.push_params(unset_env_1_no_default)
      param_collection.push_params(unset_env_2_no_default)

      expect(param_collection.stop?).to be_truthy
    end
  end

  context '.format_messages' do

    it 'should work with no arguments' do
      vars = [
          set_env_1_with_default, set_env_2_with_default, set_env_1_no_default,
          unset_env_2_no_default, unset_env_2_with_default, set_env_2_no_default,
          unset_env_1_no_default, unset_env_1_with_default, set_env_1_with_default
      ]
      param_collection.push_params(*vars)

      messages = param_collection.format_messages

      vars.each do |var|
        expect(messages).to match(/#{var.var}/)
      end
    end

    it 'should work with one filter' do
      vars = [
          set_env_1_with_default, set_env_2_with_default, set_env_1_no_default,
          unset_env_2_no_default, unset_env_2_with_default, set_env_2_no_default,
          unset_env_1_no_default, unset_env_1_with_default, set_env_1_with_default
      ]
      param_collection.push_params(*vars)

      [unset_env_1_no_default, unset_env_2_no_default].each do |var|
        expected_message = /31mThe ENV #{var.var} is required, description/
        expect(param_collection.format_messages({:stop => true})).to match(expected_message)
      end
    end

    it 'should work with two filters' do
      vars = [
          set_env_1_with_default, set_env_2_with_default, set_env_1_no_default,
          unset_env_2_no_default, unset_env_2_with_default, set_env_2_no_default,
          unset_env_1_no_default, unset_env_1_with_default
      ]
      param_collection.push_params(*vars)

      [
          set_env_1_no_default, set_env_2_no_default
      ].each do |var|
        expected_message = /32mThe ENV #{var.var} was found in the environment with the value #{var.value}/
        expect(param_collection.format_messages({:default => false, :message_level => :info})).to match(expected_message)
      end
    end
  end

end
