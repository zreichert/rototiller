require 'rototiller/version'

gem_name = "rototiller-#{Rototiller::Version::STRING}.gem"
teardown do
  `rm #{gem_name}`
end

sut = find_only_one('agent')

`gem build rototiller.gemspec`
scp_to(sut, gem_name, '/root')

on(sut, "gem install #{gem_name}")
