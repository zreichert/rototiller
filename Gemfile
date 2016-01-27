source 'https://rubygems.org'

group :system_tests do
  #gem 'beaker', :path => "../../beaker/"
  gem 'beaker', '~> 2.22.0'
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
