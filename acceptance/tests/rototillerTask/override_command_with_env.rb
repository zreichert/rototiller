require 'beaker/hosts'
require 'rakefile_tools'

test_name 'C97827: can set envvar to override command name when using task.command' do
  extend Beaker::Hosts
  extend RakefileTools

  step 'Test command with an override_env that has a value' do

    override_env = 'BROCKSAMSON'
    env_key = 'THIS_WAS_IN_ENV'
    env_value = 'echo ' << env_key

    @task_name    = 'command_flags_with_override'
    rakefile_contents = <<-EOS
$LOAD_PATH.unshift('/root/rototiller/lib')
require 'rototiller'

Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    t.add_command({:name => 'echo', :override_env => '#{override_env}'})
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)
    sut.add_env_var(override_env, env_value)

    step 'Execute task defined in rake task' do
      on(sut, "rake #{@task_name}", :accept_all_exit_codes => true) do |result|
        # exit code & no error in output
        assert(result.exit_code == 0, 'The expected exit code 0 was not observed')
        assert_no_match(/error/i, result.output, 'An unexpected error was observed')

        # command was used that was supplied by the override_env
        assert_match(/^#{env_key}/, result.stdout, 'The correct command was not observed')
      end
    end
  end

  step 'Add Command with block syntax and unset override_env' do

    override_env = 'EMPTYENV'

    @task_name    = 'command_flags_with_override'

    validation_string = (0...10).map { ('a'..'z').to_a[rand(26)] }.join

    rakefile_contents = <<-EOS
$LOAD_PATH.unshift('/root/rototiller/lib')
require 'rototiller'

Rototiller::Task::RototillerTask.define_task :#{@task_name} do |t|
    t.add_command do |c|
      c.name = 'echo #{validation_string}'
      c.override_env = '#{override_env}'
    end
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    step 'Execute task defined in rake task' do
      on(sut, "rake #{@task_name}", :accept_all_exit_codes => true) do |result|

        assert(result.exit_code == 0, 'The expected exit code 0 was not observed')
        assert_no_match(/error/i, result.output, 'An unexpected error was observed')

        assert_match(/#{validation_string}/, result.stdout, 'The correct command was not observed')
      end
    end
  end
end
