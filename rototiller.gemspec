# coding: utf-8
# place ONLY runtime dependencies in here (in addition to metadata)
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rototiller/version'

Gem::Specification.new do |s|
  s.name          = 'rototiller'
  s.authors       = ["Puppet Labs", 'Zach Reichert', 'Eric Thompson']
  s.email         = ["qa@puppet.com"]
  s.summary       = 'Puppet Labs rake tool'
  s.description   = 'Puppet Labs tool for building rake tasks'
  s.homepage      = "https://github.com/puppetlabs/rototiller"
  s.version       = Rototiller::Version::STRING
  s.license       = 'Apache-2.0'
  s.files         = Dir['[A-Z]*[^~]'] + Dir['lib/**/*.rb'] + Dir['spec/*']

  #Run time dependencies
  rake_version = ENV['RAKE_VER'] || '11.0'
  # RAKE_VER=0.9, 10.0, 11.0
  #   don't use 11.0.0, which probably installs 11.0.1 which has issues
  s.add_runtime_dependency 'rake', "~> #{rake_version}"
end
