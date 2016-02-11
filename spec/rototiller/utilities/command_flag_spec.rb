require 'spec_helper'

describe CommandFlag do

  subject       { CommandFlag.new(*args)}
  let(:flag)    { "--#{random_string}"}
  let(:message) { "This is the message provided by the user #{random_string}"}
  let(:value)   { random_string }

  context 'no value provided' do

    let(:args) {[flag, message]}

    it { is_expected.to respond_to(:value).with(0).arguments }
    it { is_expected.to respond_to(:flag).with(0).arguments }
    it { is_expected.to respond_to(:message).with(0).arguments}
    it { is_expected.not_to respond_to(:value).with(1).arguments }
    it { is_expected.not_to respond_to(:flag).with(1).arguments }
    it { is_expected.not_to respond_to(:message).with(1).arguments}

    it 'should report the value' do
      expect(subject.value).to be(nil)
    end

    it 'should report the flag' do
      expect(subject.flag).to eq(flag)
    end

    it 'should message with supplied message' do
      expect(subject.message).to match(/#{message}/)
    end

    it 'should message with information about value' do
      expected_message = /The CLI flag #{flag} will be used, no value was provided./
      expect(subject.message).to match(expected_message)
    end

    it 'should message in the color green' do
      green_color_code = /32m/
      expect(subject.message).to match(green_color_code)
    end
  end

  context 'value provided' do

    let(:args) {[flag, message, value]}

    it { is_expected.to respond_to(:value).with(0).arguments }
    it { is_expected.to respond_to(:flag).with(0).arguments }
    it { is_expected.to respond_to(:message).with(0).arguments}
    it { is_expected.not_to respond_to(:value).with(1).arguments }
    it { is_expected.not_to respond_to(:flag).with(1).arguments }
    it { is_expected.not_to respond_to(:message).with(1).arguments}

    it 'should report the value' do
      expect(subject.value).to be(value)
    end

    it 'should report the flag' do
      expect(subject.flag).to eq(flag)
    end

    it 'should message with supplied message' do
      expect(subject.message).to match(/#{message}/)
    end

    it 'should message with information about value' do
      expected_message = /The CLI flag #{flag} will be used with value #{value}./
      expect(subject.message).to match(expected_message)
    end

    it 'should message in the color green' do
      green_color_code = /32m/
      expect(subject.message).to match(green_color_code)
    end
  end
end