require 'spec_helper'
require 'stringio'

module Rototiller::Task
  include CLIFlags

  describe AcceptanceTask do

    before(:all) do
      $stdout = StringIO.new
      $stderr = StringIO.new
    end
    after(:all) do
      $stdout = STDOUT
      $stderr = STDERR
    end

    [:new, :define_task].each do |init_method|
      let(:task) { described_class.send(init_method) }

      #__send__ doesn't care about public/private methods, so we can test...
      def generate_command
        task.__send__(:generate_command)
      end

      context "default" do
        it "renders cli" do
          expect(generate_command).to eq('beaker ')
        end
      end

      context "all cli flags" do
        @@cli_flag_names.each do |flag|
          it "sets #{flag} properly" do

            the_task = described_class.send(init_method, :a_task_name)
            def generate_command(task)
              task.__send__(:generate_command)
            end
            the_task.instance_variable_set("@#{flag}", "abc#{flag}value")

            expect(the_task.instance_variable_get("@#{flag}")).to eq("abc#{flag}value")
            expect(generate_command(the_task)).to eq("beaker --#{flag} abc#{flag}value")
          end
        end
      end

    end

    context "with a block" do
      let(:task_name) {'ima_task'}
      let(:task_name2) {'ima_task_also'}
      let(:task_name3) {'ima_task_too'}
      it "calls run_task when using the Class" do
        the_task = AcceptanceTask.new(task_name) do |t|
          t.tests = "test_this"
          #no idea why this has to be in here?
          expect(t).to receive(:run_task) { true }
        end

        expect(Rake.application.invoke_task(task_name)).to be_truthy
      end

      # TODO: with dsl, but maybe move that to own test file
      # TODO with/without verbose, other instance vars
      it "calls beaker" do
        the_task = AcceptanceTask.new(task_name3) do |t|
          t.tests = "test_this"
        end

        expect(the_task).to receive(:system).with("beaker --tests test_this")
        expect(Rake.application.invoke_task(task_name3)).to be_truthy
      end

      it "calls run_task when using the DSL" do
        the_task = acceptance_task task_name2 do |t|
          t.tests = "test_this"
          expect(t).to receive(:run_task) { true }
          #no idea why this has to be in here?
          expect(Rake.application.invoke_task(task_name2)).to be_truthy
        end

      end

    end


    context "true flags" do
      # ensure flags set with true are stripped properly
    end

  end

end
