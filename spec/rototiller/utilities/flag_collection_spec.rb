require 'spec_helper'

# TODO this is copy pasta from EnvVar class

describe FlagCollection do

  let(:flag_collection)          { FlagCollection.new }
  let(:flag_1_with_default)      { CommandFlag.new({:name => random_string, :message => 'description', :default => 'devault value'}) }
  let(:flag_2_with_default)      { CommandFlag.new({:name => random_string, :message => 'description', :default => 'devault value'}) }
  #let(:flag_1_no_default)        { CommandFlag.new({:name => random_string, :message => 'description'}) }
  #let(:flag_2_no_default)        { CommandFlag.new({:name => random_string, :message => 'description'}) }

  subject { flag_collection.push(*args); flag_collection }

  shared_examples 'a flag collection' do
    it 'reports the message' do
      args.each do |arg|
        expect(subject.format_messages).to match(/#{arg.flag}/)
      end
    end
  end

  context 'all envs' do

    #let(:args) { [flag_1_no_default, flag_1_with_default, flag_2_no_default, flag_2_with_default] }
    let(:args) { [flag_1_with_default, flag_2_with_default] }


    it_behaves_like 'a flag collection'
  end

  context 'with defaults' do

    let(:args) { [flag_1_with_default, flag_2_with_default] }

    it_behaves_like 'a flag collection'
  end

  #context 'no defaults' do

   # let(:args)  { [flag_1_no_default, flag_2_no_default] }

    #pending
    #it_behaves_like 'a flag collection'
  #end

  context 'method signatures' do

    subject { EnvCollection.new }

    it 'should not push classes that are not EnvVar' do
      expect{ flag_collection.push('foobar') }.to raise_error ArgumentError
      expect{ flag_collection.push(EnvVar.new('foo', 'bar'))}.to raise_error ArgumentError
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
