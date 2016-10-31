gem_name = "rototiller-#{Rototiller::Version::STRING}.gem"
teardown do
  `rm #{gem_name}`
end

sut = find_only_one('agent')

`gem build rototiller.gemspec`
scp_to(sut, gem_name, gem_name)

# use force, as we may have to clobber system rake
on(sut, "gem install --force ./#{gem_name}")
