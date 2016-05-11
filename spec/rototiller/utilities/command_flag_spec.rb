require 'spec_helper'

describe CommandFlag do

  let(:flag)    { "--#{random_string}"}
  let(:message) { "This is the message provided by the user #{random_string}"}
  let(:value)   { random_string }

  context 'initialize' do

    subject   { CommandFlag }

    it 'should work with correct arguments' do
      expect{subject.new({:name => flag, :default => value, :message => message})}.not_to raise_error
    end
  end

  context 'Instance methods' do

    subject   { CommandFlag.new(args)}

    shared_examples 'a Command Flag object' do

      it { is_expected.to respond_to(:value).with(0).arguments }
      it { is_expected.to respond_to(:flag).with(0).arguments }
      it { is_expected.to respond_to(:message).with(0).arguments}
      it { is_expected.not_to respond_to(:value).with(1).arguments }
      it { is_expected.not_to respond_to(:flag).with(1).arguments }
      it { is_expected.not_to respond_to(:message).with(1).arguments}

      it 'should report the flag' do
        expect(subject.flag).to eq(flag)
      end

      it 'should message with supplied message' do
        expect(subject.message).to match(/#{message}/)
      end

      it 'should message in the color green' do
        green_color_code = /32m/
        expect(subject.message).to match(green_color_code)
      end
    end

    context 'no value provided' do

      let(:args) { {:name => flag, :message => message} }

      # Disabled because pending
      #it_behaves_like 'a Command Flag object'

      it 'should report the value' do
        pending 'this functionality has been temporarily removed'
        expect(subject.value).to be(nil)
      end

      it 'should message with information about value' do
        pending 'this functionality has been temporarily removed'
        expected_message = /The CLI flag #{flag} will be used, no value was provided./
        expect(subject.message).to match(expected_message)
      end
    end

    context 'default provided' do

      let(:args) { {:name => flag, :default => value, :message => message} }

      it_behaves_like 'a Command Flag object'

      it 'should report the value' do
        expect(subject.value).to be(value)
      end

      it 'should message with information about value' do
        expected_message = /The CLI flag #{flag} will be used with value #{value}./
        expect(subject.message).to match(expected_message)
      end
    end

    context 'not required, no value provided' do
      override_env_val = random_string
      let(:args) { {:name => flag, :override_env => override_env_val, :message => message, :required => false} }

      it 'should report that the flag will not be used' do
        expected_message = /The CLI flag #{flag} has no value assigned and will not be included./
        expect(subject.message).to match(expected_message)
      end
    end

    context 'not required, value provided, override value to nothing' do
      override_env_val = random_string
      let(:args) { {:name => flag, :override_env => override_env_val, :default => 'foo', :message => message, :required => false} }
      ENV[override_env_val] = ''

      it 'should report that the flag will not be used' do
        expected_message = /The CLI flag #{flag} has no value assigned and will not be included./
        expect(subject.message).to match(expected_message)
      end
    end

    context 'not required, value provided, override value' do
      override_env_val = random_string
      value = random_string
      let(:args) { {:name => flag, :override_env => override_env_val, :default => 'foo', :message => message, :required => false} }
      ENV[override_env_val] = value

      it 'should report that the flag will not be used' do
        expected_message = /The CLI flag #{flag} will be used with value #{value}./
        expect(subject.message).to match(expected_message)
      end
    end
  end
end
