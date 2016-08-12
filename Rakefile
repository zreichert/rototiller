require "bundler/gem_tasks"
require 'rspec/core/rake_task'
require 'rototiller'

task :default => :test

desc "Run spec tests"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = ['--color']
  t.pattern = ENV['SPEC_PATTERN']
end

task :test => [:check_test]

task :generate_host_config do |t, args|

  target = ENV["TEST_TARGET"] || 'centos7-64'
  generate = "beaker-hostgenerator"
  generate += " #{target}"
  generate += " > acceptance/hosts.cfg"
  sh generate
  sh "cat acceptance/hosts.cfg"
end

rototiller_task :acceptance => [:generate_host_config] do |t|
  # with a hash
  t.add_env({:name => 'TEST_TARGET',:default => 'centos7-64', :message => 'The argument to pass to beaker-hostgenerator'})
  t.add_env({:name => 'RAKE_VER',   :default => '11.0',       :message => 'The rake version to use when running acceptance tests'})

  # with new block syntax
  t.add_flag do |flag|
    flag.name = '--log-level'
    flag.default ="verbose"
    flag.message = 'beaker log-level'
    flag.override_env = 'BEAKER_LOG_LEVEL'
  end
  t.add_flag do |flag|
    flag.name = '--hosts'
    flag.default = 'acceptance/hosts.cfg'
    flag.message = 'The configuration file that Beaker will use'
    flag.override_env = 'BEAKER_HOSTS'
  end
  t.add_flag do |flag|
    flag.name = '--preserve-hosts'
    flag.default = 'onfail'
    flag.message = 'The beaker setting to preserve a provisioned host'
    flag.override_env = 'BEAKER_PRESERVE_HOSTS'
  end
  t.add_flag do |flag|
    flag.name = '--keyfile'
    flag.default ="#{ENV['HOME']}/.ssh/id_rsa-acceptance"
    flag.message = 'The SSH key used to access a SUT'
    flag.override_env = 'BEAKER_KEYFILE'
  end
  t.add_flag do |flag|
    flag.name = '--load-path'
    flag.default = 'acceptance/lib'
    flag.message = 'The load path Beaker will use'
    flag.override_env = "BEAKER_LOAD_PATH"
  end
  t.add_flag do |flag|
    flag.name = '--pre-suite'
    flag.default = 'acceptance/pre-suite'
    flag.message = 'THe path to a directory containing pre-suites'
    flag.override_env = "BEAKER_PRE_SUITE"
  end
  t.add_flag do |flag|
    flag.name = '--tests'
    flag.default = 'acceptance/tests'
    flag.message = 'The path to the tests you want beaker to run'
    flag.override_env = 'BEAKER_TESTS'
  end

  t.add_command({:name => 'beaker --debug', :override_env => 'BEAKER_EXECUTABLE'})
end

rototiller_task :check_test do |t|
  t.add_env({:name => 'SPEC_PATTERN', :default => 'spec/', :message => 'The pattern RSpec will use to find tests'})
  t.add_env({:name => 'RAKE_VER',     :default => '11.0',  :message => 'The rake version to use when running unit tests'})
end
