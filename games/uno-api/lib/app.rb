require 'sinatra'
require 'json'
require_relative 'health/server'
require_relative 'controllers/index'
require_relative 'controllers/games'

Application = Rack::Builder.app do
  map '/health' do
    run MakeApisFun::UnoApi::Health::Controller.new
  end

  map '/' do
    run MakeApisFun::UnoApi::Controllers::Index.new
  end

  map '/games' do
    run MakeApisFun::UnoApi::Controllers::Games.new
  end
end
