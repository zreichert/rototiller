# coding: utf-8
# place ONLY runtime dependencies in here (in addition to metadata)
require File.expand_path('../lib/rototiller/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'rototiller'
  s.authors       = ["Puppet, Inc.", 'Zach Reichert', 'Eric Thompson']
  s.email         = ["qa@puppet.com"]
  s.summary       = 'Puppet Labs rake tool'
  s.description   = 'Puppet Labs tool for building rake tasks'
  s.homepage      = "https://github.com/puppetlabs/rototiller"
  s.version       = Rototiller::Version::STRING
  s.license       = 'Apache-2.0'
  s.files = Dir['CONTRIBUTING.md', 'LICENSE.md', 'MAINTAINERS', 'README.md',
                'lib/**/*', 'docs/**/*']

  #Run time dependencies
  rake_version = ENV['RAKE_VER'] || '11.0'
  # RAKE_VER=0.9, 10.0, 11.0
  #   don't use 11.0.0, which probably installs 11.0.1 which has issues
  s.add_runtime_dependency 'rake', "~> #{rake_version}"
end
