# coding: utf-8
# place ONLY runtime dependencies in here (in addition to metadata)
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rototiller/version'

Gem::Specification.new do |s|
  s.name          = 'rototiller'
  s.authors       = ["Puppet Labs", 'Zach Reichert', 'Eric Thompson']
  s.email         = ["qa@puppetlabs.com"]
  s.summary       = 'Puppet Labs rake tool'
  s.description   = 'Puppet Labs tool for building rake tasks'
  s.homepage      = "https://github.com/puppetlabs/rototiller"
  s.version       = Rototiller::Version::STRING
  s.license       = 'Apache-2.0'
  s.files         = Dir['[A-Z]*[^~]'] + Dir['lib/**/*.rb'] + Dir['spec/*']

  #Run time dependencies
  s.add_runtime_dependency 'rake', '>= 0.9.0'
end
