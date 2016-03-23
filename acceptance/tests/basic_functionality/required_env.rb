#init
task_name = 'Provide_a_default'
path_to_rakefile = '/root/Rakefile'

env_name = 'FOOBAR'
env_description = "This is a helpful description of #{env_name}"

command_output = "When pigs fly!!!"
test_command = "echo '#{command_output}'"

sut = find_only_one('agent')

rototiller_output_regex = /The ENV #{env_name} is required, #{env_description}/

teardown do

  step 'Remove Rakefile on SUT'
  on(sut, "rm -f #{path_to_rakefile}" )
end

rakefile = <<-EOS
$LOAD_PATH.unshift('/root/rototiller/lib')
require 'rototiller'

Rototiller::Task::RototillerTask.define_task :#{task_name} do |t|
  t.add_env('#{env_name}', '#{env_description}')
  t.command = "#{test_command}"
end
EOS

step 'Copy rake file to SUT'
create_remote_file(sut, path_to_rakefile, rakefile)

step 'Execute task defined in rake task'
on(sut, "rake #{task_name}", :accept_all_exit_codes => true) do |result|

  # exit code & no error in output
  assert(result.exit_code == 0, 'The expected exit code 0 was not observed')
  assert_no_match(/error/i, result.output, 'An unexpected error was observed')

  # validate notification to user of ENV value
  assert_match(rototiller_output_regex, result.stdout, 'The expected messaging was not observed')

  # Use test command output to validate that Rototiller will stop the rake task
  error = 'The task did not stop, when it encountered an unset ENV without a default'
  assert_no_match(/#{command_output}/, result.stdout, error)
end
