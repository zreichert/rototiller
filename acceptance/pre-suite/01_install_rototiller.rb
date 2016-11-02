test_name 'install rototiller and rake in a bundle' do
  sut = find_only_one('agent')

  `gem build rototiller.gemspec`
  gem_name = Dir.glob('rototiller-*.gem').first
  teardown do
    `rm #{gem_name}`
  end
  scp_to(sut, gem_name, gem_name)

  rake_version = `rake --version`.split[2]
  # <sigh> we need to use bundler here to avoid conflicts when installing
  #   older versions of rake
  #   holy hell, this is painful
  on(sut, 'gem install --force bundler')
  # fetch rake so we can install from local cache
  on(sut, "gem fetch rake -v #{rake_version}")
  step 'create a Gemfile using local rototiller and rake version' do
    create_remote_file(sut, 'Gemfile', <<-GEMFILE)
      source 'https://rubygems.org'
      gem 'rake', '~> #{rake_version}'
      gem 'rototiller'
    GEMFILE
    on(sut, 'cat Gemfile')
  end
  # config local cache to find the two gems
  on(sut, 'bundle config cache_path ./ && bundle install --local')
end
