source 'https://rubygems.org'

# place all development, system_test, etc dependencies here

group :system_tests do
  #gem 'beaker', :path => "../../beaker/"
  gem 'beaker'               ,'~> 2.22'
  gem 'beaker-hostgenerator'
end

group :development do
  gem 'rspec'                ,'~> 3.1.0'
  gem 'simplecov'
  #Documentation dependencies
  gem 'yard'                 ,'~> 0'
  gem 'markdown'             ,'~> 0'
  # restrict version to enable ruby 1.9.3
  gem 'mime-types'           ,'~> 2.0'
end

local_gemfile = "#{__FILE__}.local"
if File.exists? local_gemfile
  eval(File.read(local_gemfile), binding)
end

user_gemfile = File.join(Dir.home,'.Gemfile')
if File.exists? user_gemfile
  eval(File.read(user_gemfile), binding)
end

# Specify your gem's dependencies in rototiller.gemspec
gemspec
