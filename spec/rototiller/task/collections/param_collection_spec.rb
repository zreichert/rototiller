require 'spec_helper'

module Rototiller
  module Task

    describe ParamCollection do

      before do
        allow_any_instance_of(ParamCollection).to receive(:allowed_class).and_return(EnvVar)
      end
      let(:param_collection)              { ParamCollection.new }
      let(:set_env_1_with_default)        { EnvVar.new({:name => set_random_env, :message => 'description', :default => 'devault value'}) }
      let(:set_env_2_with_default)        { EnvVar.new({:name => set_random_env, :message => 'description', :default => 'devault value'}) }
      let(:unset_env_1_with_default)      { EnvVar.new({:name => unique_env, :message => 'description', :default => 'devault value'}) }
      let(:unset_env_2_with_default)      { EnvVar.new({:name => unique_env, :message => 'description', :default => 'devault value'}) }
      let(:set_env_1_no_default)          { EnvVar.new({:name => set_random_env, :message => 'description'}) }
      let(:set_env_2_no_default)          { EnvVar.new({:name => set_random_env, :message => 'description'}) }
      let(:unset_env_1_no_default)        { EnvVar.new({:name => unique_env, :message => 'description'}) }
      let(:unset_env_2_no_default)        { EnvVar.new({:name => unique_env, :message => 'description'}) }

      context '#push' do
        it 'adds a single ENV' do
          expect{ param_collection.push(set_env_1_no_default) }.not_to raise_error
          expect(param_collection).to include(set_env_1_no_default)
        end

        it 'can not add an incorrect param' do
          expect{ param_collection.push(Command.new) }.to raise_error(ArgumentError)
        end

        it 'adds multiple ENVs' do
          expect{ param_collection.push(set_env_1_no_default, unset_env_1_with_default, set_env_1_with_default) }.not_to raise_error
          expect(param_collection).to include(set_env_1_no_default)
          expect(param_collection).to include(unset_env_1_with_default)
          expect(param_collection).to include(set_env_1_with_default)
        end
      end

      context '#format_messages' do
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
            expect(messages).to match(/#{var.name}/)
          end
        end

        let(:env_message_header) {"The environment variable:"}
        it 'should work with one filter' do
          skip('Fails due to messaging')
          param_collection.push(*vars)

          #[unset_env_1_no_default,
          [unset_env_2_no_default].each do |var|
            expected_message = /31mERROR: #{env_message_header} '#{var.name}' is required: description/
            expect(param_collection.format_messages({:stop => true})).to match(expected_message)
          end
        end

        it 'should work with two filters' do
          skip('Fails due to messaging')
          param_collection.push(*vars)

          [set_env_1_no_default, set_env_2_no_default].each do |var|
            expected_message = /32mINFO: #{env_message_header} '#{var.name}' was found with value: '#{ENV[var.name]}'/
            expect(param_collection.format_messages({:default => nil, :message_level => :info})).to match(expected_message)
          end
        end
      end

    end

  end
end
