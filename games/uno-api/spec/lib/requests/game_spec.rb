require_relative '../../spec_helper'
require 'controllers/games'

describe MakeApisFun::ClueApi::Controllers::Games do
  describe 'POST /games' do
    it 'creates a new game with 4 players and agains machine mode by default' do
      expected_response = {
        'id' => anything,
        'num_players' => 4,
        'status' => 'waiting_for_players',
        'created_at' => anything,
        'started_at' => nil,
        'finished_at' => nil,
        '_metadata' => {
          '_logs' => anything,
          '_players' => anything,
          '_turn' => 0,
          '_winner' => nil
        }
      }

      post '/games'

      response = JSON.parse(last_response.body)
      expect(last_response.status).to eq(200)
      expect(response).to include(expected_response)
    end

    context 'when number of players is provided' do
      it 'creates a new game with the number of players' do
        expected_response = {
          'id' => anything,
          'num_players' => 5,
          'status' => 'waiting_for_players',
          'created_at' => anything,
          'started_at' => nil,
          'finished_at' => nil,
          '_metadata' => {
            '_logs' => anything,
            '_players' => anything,
            '_turn' => 0,
            '_winner' => nil
          }
        }

        post '/games', { num_players: 5 }.to_json

        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)
        expect(response).to include(expected_response)
      end
    end

    context 'when against machine mode false is provided' do
      it 'creates a new game without including bots' do
        expected_response = {
          'id' => anything,
          'num_players' => 4,
          'status' => 'waiting_for_players',
          'created_at' => anything,
          'started_at' => nil,
          'finished_at' => nil,
          '_metadata' => {
            '_logs' => [],
            '_players' => [],
            '_turn' => 0,
            '_winner' => nil
          }
        }

        post '/games', { against_machine: false }.to_json

        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(200)
        expect(response).to include(expected_response)
      end
    end
  end

  describe 'POST /games/:game_id/join' do
    it 'adds an user to an existing game and return the information for that user' do
      game_id = create_game['id']
      player_name = 'Wadus'

      expected_response = {
        'id' => anything,
        'name' => player_name,
        'turn' => 0,
        'cards' => anything,
        'playing' => true,
        'game_id' => game_id
      }

      post "/games/#{game_id}/join", { player_name: player_name }.to_json

      response = JSON.parse(last_response.body)
      expect(last_response.status).to eq(200)
      expect(response).to include(expected_response)
    end

    context 'when the provided game id does not exist' do
      it 'returns a 404 error with Invalid or expired game id message' do
        post '/games/UNKNOWN_GAME_ID/join', { player_name: 'anything' }.to_json

        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(404)
        expect(response['error']).to eq('Invalid or expired game id')
      end
    end
    
    context 'when the provided game id is already started' do
      it 'returns a 422 error with game already started error' do
        game_id = create_game(num_players: 3)['id']
        join_player(game_id, 'player_one')
        join_player(game_id, 'player_two')
        join_player(game_id, 'player_three')

        post "/games/#{game_id}/join", { player_name: 'anything' }.to_json

        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(422)
        expect(response['error']).to eq('Game already started')
      end
    end

    context 'when a player is trying to join using an existing user name for that game' do
      it 'returns a 422 error with name already in use' do
        game_id = create_game(num_players: 3)['id']
        join_player(game_id, 'player_one')
        join_player(game_id, 'player_two')

        post "/games/#{game_id}/join", { player_name: 'player_one' }.to_json

        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(422)
        expect(response['error']).to eq('There is another player with the same name. Use a different one.')
      end
    end
  end

  describe 'GET /games/:game_id' do
    it 'returns all the information of the game without the solution and the cards of the players' do
      game = create_game(num_players: 3)
      game_id = game['id']
      join_player(game_id, 'player_one')
      join_player(game_id, 'player_two')
      join_player(game_id, 'player_three')

      expected_game = game.merge({'started_at' => anything, 'status' => 'started', '_metadata' => anything})

      get "/games/#{game_id}"

      response = JSON.parse(last_response.body)
      expect(last_response.status).to eq(200)
      expect(response).to include(expected_game)
    end

    context 'when the provided game id does not exist' do
      it 'returns a 404 error with Invalid or expired game id message' do
        get '/games/UNKNOWN_GAME_ID'

        response = JSON.parse(last_response.body)
        expect(last_response.status).to eq(404)
        expect(response['error']).to eq('Invalid or expired game id')
      end
    end
  end

  private

  def create_game(num_players: 4)
    post '/games', { num_players: num_players, against_machine: false }.to_json

    response = JSON.parse(last_response.body)

    response
  end

  def join_player(game_id, player_name)
    post "/games/#{game_id}/join", { player_name: player_name }.to_json

    response = JSON.parse(last_response.body)

    response
  end

  def retrieve_game_info(game_id)
    get "/games/#{game_id}"

    response = JSON.parse(last_response.body)

    response
  end
end
