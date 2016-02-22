require 'spec_helper'

describe EnvCollection do

  let(:env_collection)                { EnvCollection.new }
  let(:set_env_1_with_default)        { EnvVar.new(set_random_env, 'description', 'devault value') }
  let(:set_env_2_with_default)        { EnvVar.new(set_random_env, 'description', 'devault value') }
  let(:unset_env_1_with_default)      { EnvVar.new(unique_env, 'description', 'devault value') }
  let(:unset_env_2_with_default)      { EnvVar.new(unique_env, 'description', 'devault value') }
  let(:set_env_1_no_default)          { EnvVar.new(set_random_env, 'description') }
  let(:set_env_2_no_default)          { EnvVar.new(set_random_env, 'description') }
  let(:unset_env_1_no_default)        { EnvVar.new(unique_env, 'description') }
  let(:unset_env_2_no_default)        { EnvVar.new(unique_env, 'description') }


  subject { env_collection.push(*args); env_collection }

  shared_examples 'an env collection' do
    it 'reports the message' do
      args.each do |arg|
        expect(subject.format_messages).to match(/#{arg.var}/)
      end
    end

    it 'stops' do
      expect(subject.stop?).to eq(stop)
    end
  end

  context 'all envs' do

    let(:args) do
      [
          set_env_1_no_default, set_env_2_no_default, set_env_1_with_default, set_env_2_with_default,
          unset_env_2_with_default, unset_env_1_with_default, unset_env_1_no_default, unset_env_2_no_default
      ]
    end
    let(:stop) {true}

    it_behaves_like 'an env collection'
  end

  context 'with defaults' do

    let(:args) { [set_env_1_with_default, set_env_2_with_default, unset_env_1_with_default, unset_env_2_with_default] }
    let(:stop) { false }

    it_behaves_like 'an env collection'
  end

  context 'no defaults' do

    let(:args)  { [set_env_2_no_default, set_env_1_no_default, unset_env_2_no_default, unset_env_1_no_default] }
    let(:stop)  { true }

    it_behaves_like 'an env collection'
  end

  context 'method signatures' do

    subject { EnvCollection.new }

    it 'should not push classes that are not EnvVar' do
      expect{ env_collection.push('foobar') }.to raise_error ArgumentError
      expect{ env_collection.push(CommandFlag.new('foo', 'bar'))}.to raise_error ArgumentError
    end

    it { is_expected.to respond_to(:push).with(1).arguments }
    it { is_expected.to respond_to(:push).with(2).arguments }
    it { is_expected.to respond_to(:push).with(3).arguments }
    it { is_expected.to respond_to(:push).with(0).arguments }

    it { is_expected.not_to respond_to(:stop?).with(1).arguments }
    it { is_expected.to respond_to(:stop?).with(0).arguments }

    it { is_expected.to respond_to(:format_messages).with(0).arguments }
    it { is_expected.to respond_to(:format_messages).with(1).arguments }
  end
end
