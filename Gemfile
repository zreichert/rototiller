source 'https://rubygems.org'

# place all development, system_test, etc dependencies here

# in the Rakefile, so we require it in all groups
rake_version = ENV['RAKE_VER'] || '11.0'
gem 'rake'                 , "~> #{rake_version}"
gem 'rototiller'           ,'~> 0.1.0'
gem 'rspec'                ,'~> 3.4.0'

group :system_tests do
  #gem 'beaker', :path => "../../beaker/"
  gem 'beaker'               ,'~> 2.22'
  gem 'beaker-hostgenerator'
  gem 'public_suffix', '<= 1.4.6'
end

group :development do
  gem 'simplecov'
  #Documentation dependencies
  gem 'yard'                 ,'~> 0'
  gem 'markdown'             ,'~> 0'
  # restrict version to enable ruby 1.9.3
  gem 'mime-types'           ,'~> 2.0'
  gem 'google-api-client','<= 0.9.4'
  gem 'activesupport'        ,'< 5.0.0'
end

local_gemfile = "#{__FILE__}.local"
if File.exists? local_gemfile
  eval(File.read(local_gemfile), binding)
end

user_gemfile = File.join(Dir.home,'.Gemfile')
if File.exists? user_gemfile
  eval(File.read(user_gemfile), binding)
end
