require '../../utilities/env_var_checker'

Rake::TaskManager.record_task_metadata = true

task :parse_env do |t|
  # This task is used by other tasks
  include EnvVar
  t.check_env_vars
end

task :beaker  => [:parse_env] do
  puts 'Using BEAKER'
end

task :beaker_rspec => [:parse_env] do
  puts 'Using BEAKER-RSPEC'
end
