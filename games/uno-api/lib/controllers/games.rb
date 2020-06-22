require 'sinatra'
require 'json'
require_relative '../actions/games/create'
require_relative '../actions/games/fetch'
require_relative '../actions/games/join'
require_relative '../actions/games/players/fetch_cards'

module MakeApisFun
  module UnoApi
    module Controllers
      class Games < Sinatra::Base
        before do
          content_type :json
        end

        post '/' do
          body = request.body.read

          payload = {}
          payload = JSON.parse(body) unless body.empty?
          num_players = payload['num_players'] || 6
          against_machine = payload['against_machine']

          response = Actions::Games::Create.do(
            num_players: num_players,
            against_machine: against_machine
          )

          obfuscate_data(response)
          
          status_by(response)
          response.to_json
        end

        post '/:game_id/join' do
          body = request.body.read

          payload = {}
          payload = JSON.parse(body) unless body.empty?
          player_name = payload['player_name']

          response = Actions::Games::Join.do(
            game_id: params['game_id'],
            player_name: player_name
          )

          status_by(response)
          response.to_json
        end

        get '/:game_id' do
          response = Actions::Games::Fetch.do(
            game_id: params['game_id']
          )

          obfuscate_data(response)

          status_by(response)
          response.to_json
        end

        post '/:game_id/play' do
          body = request.body.read

          payload = {}
          payload = JSON.parse(body) unless body.empty?
          player_id = payload['player_id']
          action = payload['action']
          cards = payload['cards']

          response = Actions::Games::Play.do(
            game_id: params['game_id'],
            player_id: player_id,
            action: action,
            cards: cards
          )

          status_by(response)
          response.to_json
        end

        get '/:game_id/players/:player_id/cards' do
          response = Actions::Games::Players::FetchCards.do(
            game_id: params['game_id'],
            player_id: params['player_id']
          )

          status_by(response)
          response.to_json
        end

        private

        def obfuscate_data(response)
          return if response[:error]

          players = response['_metadata']['_players']
          players.each do |player|
            player['cards_count'] = player['cards'].size
            player.delete('cards')
            player.delete('id')
            player.delete('game_id')
          end if players.any?

          response
        end

        def status_by(response)
          if response[:error]
            return status 404 if response[:error] == 'Invalid or expired game id'

            status 422
          else
            status 200
          end
        end
      end
    end
  end
end

