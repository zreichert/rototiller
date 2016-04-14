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

task :generate_host_config => [:check_acceptance]do |t, args|

  target = ENV["TEST_TARGET"] || 'centos7-64'
  generate = "bundle exec beaker-hostgenerator"
  generate += " #{target}"
  generate += " > acceptance/hosts.cfg"
  sh generate
  sh "cat acceptance/hosts.cfg"
end

desc 'Run acceptance tests for Rototiller'
task :acceptance => [:check_acceptance, :generate_host_config]do |t, args|

  config = ENV["BEAKER_CONFIG"]

  preserve_hosts = ENV["BEAKER_PRESERVEHOSTS"]
  keyfile = ENV["BEAKER_KEYFILE"]
  load_path = ENV["BEAKER_LOADPATH"]
  pre_suite = ENV["BEAKER_PRESUITE"]
  test_suite = ENV["BEAKER_TESTSUITE"]

  beaker = "bundle exec beaker "
  beaker += " --debug"
  beaker += " --preserve-hosts #{preserve_hosts}" if preserve_hosts != ''
  beaker += " --hosts #{config}" if config != ''
  beaker += " --keyfile #{keyfile}" if keyfile != ''
  beaker += " --load-path #{load_path}" if load_path != ''
  beaker += " --pre-suite #{pre_suite}" if pre_suite != ''
  beaker += " --tests #{test_suite}" if test_suite != ''
  sh beaker
end

Rototiller::Task::RototillerTask.define_task :check_acceptance do |t|
  # with a hash
  t.add_env({:name => 'TEST_TARGET',:default => 'centos7-64', :message => 'The argument to pass to beaker-hostgenerator'})

  # with new block syntax
  t.add_env do |env|
    env.name = 'BEAKER_CONFIG'
    env.default = 'acceptance/hosts.cfg'
    env.message = 'The configuration file that Beaker will use'
  end
  t.add_env do |env|
    env.name = 'BEAKER_PRESERVEHOSTS'
    env.default = 'never'
    env.message = 'The beaker setting to preserve a provisioned host'
  end
  t.add_env do |env|
    env.name = 'BEAKER_KEYFILE'
    env.default ="#{ENV['HOME']}/.ssh/id_rsa-acceptance"
    env.message = 'The SSH key used to access a SUT'
  end
  t.add_env do |env|
    env.name ="BEAKER_LOADPATH"
    env.default = 'acceptance/lib'
    env.message = 'The load path Beaker will use'
  end
  t.add_env do |env|
    env.name = "BEAKER_PRESUITE"
    env.default = 'acceptance/pre-suite'
    env.message = 'THe path to a directory containing pre-suites'
  end
  t.add_env do |env|
    env.name = 'BEAKER_TESTSUITE'
    env.default = 'acceptance/tests'
    env.message = 'The path to the tests you want beaker to run'
  end
end

Rototiller::Task::RototillerTask.define_task :check_test do |t|
  t.add_env(:name => 'SPEC_PATTERN', :default => 'spec/', :message => 'The pattern RSpec will use to find tests')
end

