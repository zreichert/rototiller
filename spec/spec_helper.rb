if ENV["COVERAGE"]
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '.bundle/gems'
  end
end

require 'rspec'
require 'rototiller'

def random_string
  (0...10).map { ('a'..'z').to_a[rand(26)] }.join
end

RSpec.configure do |config|
  config.include Rake::DSL
end
