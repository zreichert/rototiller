require 'spec_helper'
require 'rototiller/task/block_handling'

shared_examples_for Rototiller::Task::BlockHandling do
  context 'with_an_instance' do
    before(:each) do
      @obj = described_class.new({:name => 'blah'})
    end

    it 'should pull 2 params from 2 param block and return a hash' do
      block = Proc.new { |b| b.name = 'default value'
                         b.message  = 'This is the message'}
      expected_hash = {:name=>"default value", :message=>"This is the message"}
      params = expected_hash.keys
      expect(@obj.pull_params_from_block(params,&block)).to eq expected_hash
    end

    it 'should pull 2 params from 2 param block if given 3 params' do
      block = Proc.new { |b| b.name = 'default value'
                         b.message  = 'This is the message'}
      expected_hash = {:name=>"default value", :message=>"This is the message"}
      params = expected_hash.keys << :nopull
      expect(@obj.pull_params_from_block(params,&block)).to eq expected_hash
    end

    it 'should handle params with numbers in their names' do
      block = Proc.new { |b| b.n2me = 'value' }
      expected_hash = {:'n2me'=>"value"}
      params = expected_hash.keys
      expect(@obj.pull_params_from_block(params,&block)).to eq expected_hash
    end

    it 'should handle params with punctuation ending their names' do
      pending("hmmm, hopefully we'll just never need methods using [?!=] ending their names?")
      #block = Proc.new { |b| b.name! = 'value'}
      #expected_hash = {:name!=>'value'}
      #params = expected_hash.keys
      expect(@obj.pull_params_from_block(params,&block)).to eq expected_hash
    end

    it 'should not pull 2 params from 3 param block and raise' do
      block = Proc.new { |b| b.name = 'default value'
                         b.nonesuch = 'notgonnawork'
                         b.message  = 'This is the message'}
      expected_hash = {:name=>"default value", :message=>"This is the message"}
      params = expected_hash.keys
      expect{ @obj.pull_params_from_block(params,&block) }.to raise_error(NoMethodError)
    end

    it 'should not handle params with "@" in their names' do
      pending("dunno why this won't work??")
      block = Proc.new { |b| b.n@me = 'value' }
      expected_hash = {:'n@me'=>"value"}
      params = expected_hash.keys
      expect(@obj.pull_params_from_block(params,&block)).to raise_error(NameError)
    end

  end

end

describe Rototiller::Task::EnvVar do
  it_behaves_like Rototiller::Task::BlockHandling
end

describe Rototiller::Task::Command do
  it_behaves_like Rototiller::Task::BlockHandling
end
