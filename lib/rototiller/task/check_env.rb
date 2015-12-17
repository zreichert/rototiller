require 'rototiller/utilities/env_var_checker.rb'

task :check_env do |t|
  include EnvVar
  t.check_env_vars
end

