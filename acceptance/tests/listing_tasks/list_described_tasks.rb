#init
task_name = 'described'
description = 'This is a description added by a user'
path_to_rakefile = '/root/Rakefile'

sut = find_only_one('agent')

described_regex = /rake #{task_name}  # #{description}/

teardown do

  step 'Remove Rakefile on SUT'
  on(sut, "rm -f #{path_to_rakefile}" )
end

rakefile = <<-EOS
$LOAD_PATH.unshift('/root/rototiller/lib')
require 'rototiller'

desc '#{description}'
Rototiller::Task::RototillerTask.define_task :#{task_name} do |t|

end
EOS

step 'Copy rake file to SUT'
create_remote_file(sut, path_to_rakefile, rakefile)

on(sut, "rake -T --rakefile #{path_to_rakefile}", :accept_all_exit_codes => true) do |result|

  assert(result.exit_code == 0, 'The expected exit code 0 was not observed')
  assert_no_match(/error/i, result.output, 'An unexpected error was observed')
  assert_match(described_regex, result.stdout, 'The user supplied description was not observed')
end
