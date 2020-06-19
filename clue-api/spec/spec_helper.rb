require 'rspec'
require 'rack/test'
require 'app'

ENV['RACK_ENV'] = 'test'
require_relative '../config/boot'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def app
  Application
end