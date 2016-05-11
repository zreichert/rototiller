require 'spec_helper'

describe CommandFlag do

  let(:flag)    { "--#{random_string}"}
  let(:message) { "This is the message provided by the user #{random_string}"}
  let(:value)   { random_string }
  let(:is_boolean)   { false }
  let(:override_env) { random_string.upcase }

  context 'initialize' do

    subject   { CommandFlag }

    it 'should work with correct arguments' do
      expect{subject.new({:name => flag, :default => value, :message => message, :is_boolean => is_boolean})}.not_to raise_error
    end
    it 'should error with required and is_boolean' do
      expect{subject.new({:name => flag, :default => value, :is_boolean => true, :required => true})}.to raise_error
    end
    # FIXME: this is bad.  i should be able to add a flag with just its (i suppose is_boolean)
    it 'should error without one of default or override_env' do
      expect{subject.new({:name => flag})}.to raise_error
    end
  end

  context 'Instance methods' do

    subject   { CommandFlag.new(args)}

    shared_examples 'a Command Flag object' do

      it { is_expected.to respond_to(:value).with(0).arguments }
      it { is_expected.to respond_to(:flag).with(0).arguments }
      it { is_expected.to respond_to(:message).with(0).arguments}
      it { is_expected.to respond_to(:required).with(0).arguments}
      it { is_expected.to respond_to(:is_boolean).with(0).arguments}
      it { is_expected.not_to respond_to(:value).with(1).arguments }
      it { is_expected.not_to respond_to(:flag).with(1).arguments }
      it { is_expected.not_to respond_to(:message).with(1).arguments}
      it { is_expected.not_to respond_to(:required).with(1).arguments}
      it { is_expected.not_to respond_to(:is_boolean).with(1).arguments}

      it 'should report the flag' do
        expect(subject.flag).to eq(flag)
      end

      it 'should set is_boolean' do
        expect(subject.is_boolean).to eq(is_boolean)
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
        expect(subject.value).to eq(nil)
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
        expect(subject.value).to eq(value)
      end

      it 'should message with information about value' do
        expected_message = /The CLI flag '#{flag}' will be used with value '#{value}'./
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
        expected_message = /The CLI flag '#{flag}' will be used with value '#{value}'./
        expect(subject.message).to match(expected_message)
      end
    end

    # default takes precedence in case the default state is "off" aka: empty
    context 'with is_boolean' do

      context 'should set switch to :name with no default and env_override not passed' do
        let(:args) { {:name => flag, :is_boolean => true} }

        it 'should report the switch name' do
          expect(subject.flag).to eq(flag)
        end
        it 'should message with information about flag' do
          expected_message = /The CLI switch '#{flag}' will be used./
          expect(subject.message).to match(expected_message)
        end
        it 'should not have stop set to true' do
          expect(subject.stop).to be_falsey
        end
      end

      context 'should set switch to :name with no default and env_override passed but not set' do
        let(:args) { {:name => flag, :is_boolean => true, :override_env => override_env} }

        it 'should report the switch name' do
          expect(subject.flag).to eq(flag)
        end
        it 'should message with information about flag' do
          expected_message = /The CLI switch '#{flag}' will be used./
          expect(subject.message).to match(expected_message)
        end
        it 'should not have stop set to true' do
          expect(subject.stop).to be_falsey
        end
      end

      context 'should set switch to :override_env with no default and env_override passed and set' do
        let(:args) { {:name => flag, :is_boolean => true, :override_env => override_env} }

        it 'should report the switch name' do
          ENV[override_env] = value
          expect(subject.flag).to eq(value)
        end

        # FIXME: repeated ENV setting here is problematic
        #   doesn't work in before nor let.
        it 'should message with information about flag' do
          ENV[override_env] = value
          expected_message = /The CLI switch '#{value}' will be used./
          expect(subject.message).to match(expected_message)
        end
        it 'should not have stop set to true' do
          expect(subject.stop).to be_falsey
        end
      end

      context 'should set switch to :default over :name when env is not set so it can default to "off"' do
        let(:args) { {:name => flag, :is_boolean => true, :default => value} }

        it 'should report the switch name' do
          expect(subject.flag).to eq(value)
        end
        it 'should message with information about flag' do
          expected_message = /The CLI switch '#{value}' will be used./
          expect(subject.message).to match(expected_message)
        end
        it 'should not have stop set to true' do
          expect(subject.stop).to be_falsey
        end
      end

      context 'should set switch to :default of ""' do
        let(:args) { {:name => flag, :is_boolean => true, :default => ''} }

        it 'should report the switch name' do
          expect(subject.flag).to eq('')
        end
        it 'should message with information about flag' do
          expected_message = /The CLI switch '#{flag}' will NOT be used./
          expect(subject.message).to match(expected_message)
        end
        it 'should not have stop set to true' do
          expect(subject.stop).to be_falsey
        end
      end

      context 'should set switch to env_override when env is set with a :default' do
        let(:args) { {:name => flag, :is_boolean => true, :default => value, :override_env => override_env} }
        let(:env_val) { "env_#{value}" }

        it 'should report the switch name' do
          ENV[override_env] = env_val
          expect(subject.flag).to eq(env_val)
        end

        # FIXME: repeated ENV setting here is problematic
        #   doesn't work in before nor let.
        it 'should message with information about flag' do
          ENV[override_env] = env_val
          expected_message = /The CLI switch '#{env_val}' will be used./
          expect(subject.message).to match(expected_message)
        end
        it 'should not have stop set to true' do
          expect(subject.stop).to be_falsey
        end
      end

    end

  end
end
