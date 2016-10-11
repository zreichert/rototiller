require 'beaker/hosts'
require 'rakefile_tools'
require 'test_utilities'

test_name 'C97824: can set command arguments and overrides in a RototillerTask' do
  pending_test 'this is borken, probably always has been'
  #FIXME: when args and add_env are re-added
  extend Beaker::Hosts
  extend RakefileTools
  extend TestUtilities

  step 'Test command argument with an override_env that has a value' do
    argument_override_env = unique_env_on(sut)
    argument_env_value = 'THIS_WAS_THE_ARG_IN_THE_ENV'
    default_arg = 'HANKVENTURE'
    task_name    = 'command_with_args_and_defaults'

    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
rototiller_task :#{task_name} do |t|
    t.add_command({:name => 'echo', :argument => '#{default_arg}', :argument_override_env => '#{argument_override_env}'})
end
    EOS

    rakefile_path = create_rakefile_on(sut, rakefile_contents)
    sut.add_env_var(argument_override_env, argument_env_value)

    execute_task_on(sut, task_name, rakefile_path) do |result|
      assert_match(/^#{argument_env_value}/, result.stdout, 'The correct command was not observed')
    end
  end

  step 'Add Command argument with block syntax and unset override_env' do
    argument_override_env2 = unique_env_on(sut)
    argument_env_value2 = "ENV_VALUE#{random_string}"
    default_arg2        = 'HANKVENTURE'
    task_name2          = 'command_with_args_and_defaults2'

    rakefile_contents = <<-EOS
#{rototiller_rakefile_header}
rototiller_task :#{task_name2} do |t|
    t.add_command do |c|
      c.name = 'echo'
      c.argument = '#{default_arg2}'
      c.argument_override_env = '#{argument_override_env2}'
    end
end
    EOS
    rakefile_path = create_rakefile_on(sut, rakefile_contents)

    execute_task_on(sut, task_name2, rakefile_path) do |result|
      command_regex = /^#{argument_env_value2}/
      assert_match(command_regex, result.stdout, 'The correct command was not observed')
    end
  end
end
