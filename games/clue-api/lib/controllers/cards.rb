require 'sinatra'
require 'json'
require_relative '../services/cards_service'

module MakeApisFun
  module ClueApi
    module Controllers
      class Cards < Sinatra::Base
        before do
          content_type :json
        end

        get '/' do
          response = Services::CardsService.fetch_all

          response.to_json
        end
      end
    end
  end
end