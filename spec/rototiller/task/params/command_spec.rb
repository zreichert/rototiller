require 'spec_helper'

module Rototiller
  module Task

    # use each of these for the objects passed from it_behaves_like below
    #   (each of command from hash and command from block
    shared_examples "a Command object" do
      before(:each) do
        @arg_name      = "VARNAME_#{(0...8).map { (65 + rand(26)).chr }.join}"
        @command_name  = 'echo'
        @args = {:name => @command_name, :argument => @arg_name}
        @block = Proc.new { |b| b.name = @command_name; b.argument = @arg_name }
      end

      describe '#name' do
        it 'can directly set name' do
          expect{ command.name = 'wah' }.not_to raise_error
          expect(command.name).to eq('wah')
        end
        it 'returns the name' do
          expect(command.name).to eq(@command_name)
        end
      end

      describe '#result' do
        it 'can not directly set result' do
          expect{ command.result = 'wah' }.to raise_error(NoMethodError)
        end
        it 'has nil results prior to run' do
          expect( command.result ).to be_nil
        end
        it 'has results after successful run' do
          command.run
          expect( command.result.stdout.strip ).to eq(@arg_name)
          expect( command.result.stderr ).to be_empty
          expect( command.result.exit_code ).to eq(0)
        end
        it 'has results after failed run' do
          command.name = 'doesnotexist'
          command.run
          expect( command.result.stdout ).to be_empty
          expect( command.result.stderr.strip ).to match(/sh\: .*doesnotexist\: (command )?not found/)
          expect([2,127]).to include(command.result.exit_code)
        end
        context 'with a block' do
          it 'runs the block' do
            expect{ command.run { |result| puts "my exit_code: '#{result.exit_code}'" } }.to output("my exit_code: '0'\n").to_stdout
          end
        end
      end

      describe '#to_str' do
        #pending('FIXME: not important until we have a bunch of env_vars, options, etc')
        # it 'should retain order in which params are added, somehow... a map?'
      end

      describe '#message' do
        #it 'returns the formatted message' do
        #pending('FIXME: figure out if env should always be set')
        #expect(@command.message).to eq(@formatted_message)
        #end
      end
    end

    describe Command do

      it_behaves_like "a Command object" do
        let(:command)  { described_class.new(@args) }
      end
      it_behaves_like "a Command object" do
        let(:command)  { described_class.new(&@block) }
      end
    end

  end
end
