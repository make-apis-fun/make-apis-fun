require_relative '../../spec_helper'
require 'controllers/cards'

describe MakeApisFun::ClueApi::Controllers::Cards do
  describe 'GET /' do
    it 'returns all the cards' do
      expected_response = {
        'murderers' => anything,
        'weapons' => anything,
        'rooms' => anything
      }

      get '/cards'

      response = JSON.parse(last_response.body)
      expect(last_response.status).to eq(200)
      expect(response).to include(expected_response)
    end
  end
end
