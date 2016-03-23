require "bundler/gem_tasks"
require 'rspec/core/rake_task'

task :default => :test

desc "Run spec tests"
RSpec::Core::RakeTask.new(:test) do |t|
  t.rspec_opts = ['--color']
  t.pattern = 'spec/'
end

task :generate_host_config do |t, args|
  if ENV["BEAKER_CONFIG"]
    next
  end

  target = ENV["TEST_TARGET"] || 'centos7-64'
  generate = "bundle exec beaker-hostgenerator"
  generate += " #{target}"
  generate += " > acceptance/hosts.cfg"
  sh generate
  sh "cat acceptance/hosts.cfg"
end

task acceptance: :generate_host_config

desc 'Run acceptance tests for Rototiller'
task :acceptance do |t, args|

  config = ENV["BEAKER_CONFIG"] || 'acceptance/hosts.cfg'

  preserve_hosts = ENV["BEAKER_PRESERVEHOSTS"] || 'never'
  type = 'pe'
  keyfile = ENV["BEAKER_KEYFILE"] || "#{ENV['HOME']}/.ssh/id_rsa-acceptance"
  load_path = ENV["BEAKER_LOADPATH"] || 'acceptance/lib'
  pre_suite = ENV["BEAKER_PRESUITE"] || 'acceptance/pre-suite'
  post_suite = ENV["BEAKER_POSTSUITE"] || ''
  test_suite = ENV["BEAKER_TESTSUITE"] || 'acceptance/tests'
  opts = ENV["BEAKER_OPTS"] || ''

  beaker = "bundle exec beaker "
  beaker += " --xml"
  beaker += " --debug"
  beaker += " --root-keys"
  beaker += " --repo-proxy"
  beaker += " --preserve-hosts #{preserve_hosts}" if preserve_hosts != ''
  beaker += " --config #{config}" if config != ''
  beaker += " --type #{type}" if type != ''
  beaker += " --keyfile #{keyfile}" if keyfile != ''
  beaker += " --load-path #{load_path}" if load_path != ''
  beaker += " --pre-suite #{pre_suite}" if pre_suite != ''
  beaker += " --post-suite #{post_suite}" if post_suite != ''
  beaker += " --tests #{test_suite}" if test_suite != ''
  beaker += " #{opts}" if opts != ''
  sh beaker
end
