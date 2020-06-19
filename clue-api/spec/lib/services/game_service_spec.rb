require 'redis'
require_relative '../../spec_helper'
require 'services/game_service'

describe MakeApisFun::ClueApi::Services::GameService do
  let(:structure_game) do
    {
      'id' => anything,
      'num_players' => anything,
      'status' => anything,
      'created_at' => anything,
      'started_at' => anything,
      'finished_at' => anything,
      '_metadata' => {
        '_logs' => anything,
        '_players' => anything,
        '_solution' => {
          '_murderer' => anything,
          '_weapon' => anything,
          '_room' => anything
        },
        '_turn' => anything,
        '_winner' => anything
      }
    }
  end

  let(:waiting_for_players_game) do
      {
        'id' => 'existing_id',
        'num_players' => 3,
        'status' => 'waiting_for_players',
        'created_at' => Time.now,
        'started_at' => nil,
        'finished_at' => nil,
        '_metadata' => {
          '_logs' => [],
          '_players' => [
            { 
              'id' => anything, 
              'name' => 'player_one',
              'turn' => 0,
              'cards' => [
                { 'id' => 4, 'name' => anything },
                { 'id' => 5, 'name' => anything },
                { 'id' => 6, 'name' => anything },
                { 'id' => 7, 'name' => anything },
                { 'id' => 8, 'name' => anything },
                { 'id' => 9, 'name' => anything }
              ], 
              'playing' => true
            }
          ],
          '_solution' => {
            '_murderer' => { 'id' => 1, 'name' => anything },
            '_weapon' => { 'id' => 2, 'name' => anything },
            '_room' => { 'id' => 3, 'name' => anything }
          },
          '_turn' => 0,
          '_winner' => nil
        }
      }
  end

  let(:started_game) do
    {
      'id' => 'existing_id',
      'num_players' => 3,
      'status' => 'started',
      'created_at' => Time.now,
      'started_at' => Time.now,
      'finished_at' => nil,
      '_metadata' => {
        '_logs' => [],
        '_players' => [
          { 
            'id' => 'player_one_id', 
            'name' => 'player_one',
            'turn' => 0,
            'cards' => [
              { 'id' => 4, 'name' => 'card_name' },
              { 'id' => 5, 'name' => 'card_name' },
              { 'id' => 6, 'name' => 'card_name' },
              { 'id' => 7, 'name' => 'card_name' },
              { 'id' => 8, 'name' => 'card_name' },
              { 'id' => 9, 'name' => 'card_name' }
            ], 
            'playing' => true
          },
          { 
            'id' => 'player_two_id',
            'name' => 'player_two',
            'turn' => 1,
            'cards' => [
              { 'id' => 10, 'name' => 'card_name' },
              { 'id' => 11, 'name' => 'card_name' },
              { 'id' => 12, 'name' => 'card_name' },
              { 'id' => 13, 'name' => 'card_name' },
              { 'id' => 14, 'name' => 'card_name' },
              { 'id' => 15, 'name' => 'card_name' }
            ], 
            'playing' => true
          },
          { 
            'id' => 'player_three_id',
            'name' => 'player_three',
            'turn' => 2,
            'cards' => [
              { 'id' => 16, 'name' => 'card_name' },
              { 'id' => 17, 'name' => 'card_name' },
              { 'id' => 18, 'name' => 'card_name' },
              { 'id' => 19, 'name' => 'card_name' },
              { 'id' => 20, 'name' => 'card_name' },
              { 'id' => 0, 'name' => 'card_name' }
            ], 
            'playing' => true
          }
        ],
        '_solution' => {
          '_murderer' => { 'id' => 1, 'name' => 'card_name' },
          '_weapon' => { 'id' => 2, 'name' => 'card_name' },
          '_room' => { 'id' => 3, 'name' => 'card_name' }
        },
        '_turn' => 0,
        '_winner' => nil
      }
    }
  end

  let(:finished_game) do
    started_game['status'] = 'finished'
    started_game['finished_at'] = Time.now

    started_game
  end

  describe '.fetch_by' do
    before do
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)
    end

    context 'when the provided id is for an existing game' do
      it 'retrieves all the information of the game' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(structure_game.to_json)

        result = described_class.fetch_by(id: 'existing_id')

        expect(result).to include(structure_game)
      end
    end

    context 'when the provided id does NOT exist' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('not_existing_id').and_return(nil)

        expect { described_class.fetch_by(id: 'not_existing_id') }.to raise_error(
          'Invalid or expired game id')
      end
    end
  end

  describe '.create' do
    it 'stores a new game in redis' do
      structure_game['num_players'] = 4

      expect(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)
          .with(structure_game['id'], structure_game)

      described_class.create(num_players: 4)
    end

    it 'assigns random cards to the solution' do
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)
      expect(MakeApisFun::ClueApi::Services::CardsService).to receive(:random_murderer_card).once
      expect(MakeApisFun::ClueApi::Services::CardsService).to receive(:random_weapon_card).once
      expect(MakeApisFun::ClueApi::Services::CardsService).to receive(:random_room_card).once

      described_class.create(num_players: 4)
    end

    context 'when provide less than 3 players' do
      it 'creates a game with 3 players' do
        structure_game['num_players'] = 3

        expect(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)
          .with(structure_game['id'], structure_game)

        described_class.create(num_players: 1)
      end
    end

    context 'when provide more than 6 players' do
      it 'creates a game with 6 players' do
        structure_game['num_players'] = 6

        expect(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)
          .with(structure_game['id'], structure_game)

        described_class.create(num_players: 10)
      end
    end
  end

  describe '.join_to' do
    it 'returns the new player added with cards and turn' do
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

      response = described_class.join_to(id: 'existing_id', player_name: 'wadus')

      expect(response['id']).to_not be nil
      expect(response['name']).to eq('wadus')
      expect(response['turn']).to eq(1)
      expect(response['cards'].size).to eq(6)
      expect(response['playing']).to be true
    end

    it 'updates the game including the new player' do
      allow(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_join)
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

      expect(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)

      described_class.join_to(id: 'existing_id', player_name: 'wadus')
    end

    it 'logs the join action' do
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

      expect(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_join).once

      described_class.join_to(id: 'existing_id', player_name: 'wadus')
    end

    context 'when the game already started' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.join_to(id: 'existing_id', player_name: 'wadus')
        }.to raise_error('Game already started')
      end
    end

    context 'when the game is finished' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(finished_game.to_json)

        expect {
          described_class.join_to(id: 'existing_id', player_name: 'wadus')
        }.to raise_error('Finished game')
      end
    end

    context 'when all the players are in the game' do
      it 'raise an error' do
        started_game['status'] = 'waiting_for_players'
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.join_to(id: 'existing_id', player_name: 'wadus')
        }.to raise_error('No more players allowed')
      end
    end

    context 'when the player provides an empty name' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

        expect {
          described_class.join_to(id: 'existing_id', player_name: nil)
        }.to raise_error('You must provide a name')
      end
    end

    context 'when the player provide a repeated name' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

        expect {
          described_class.join_to(id: 'existing_id', player_name: 'player_one')
        }.to raise_error('There is another player with the same name. Use a different one.')
      end
    end
  end

  describe '.start' do
    let(:ready_to_start_game) do
      started_game['status'] = 'waiting_for_players'
      started_game['started_at'] = nil

      started_game
    end
    it 'changes the status of the game to started and set the started_at date' do
      allow(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_start)
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(ready_to_start_game.to_json)

      expect(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)

      response = described_class.start(id: 'existing_id')
      expect(response['status']).to eq('started')
      expect(response['started_at']).to_not be nil
    end

    it 'logs the start action in the game' do
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(ready_to_start_game.to_json)

      expect(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_start)

      described_class.start(id: 'existing_id')
    end

    context 'when the game already started' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.start(id: 'existing_id')
        }.to raise_error('Game already started')
      end
    end

    context 'when the game is finished' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(finished_game.to_json)

        expect {
          described_class.start(id: 'existing_id')
        }.to raise_error('Finished game')
      end
    end

    context 'when not all the players are connected' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

        expect {
          described_class.start(id: 'existing_id')
        }.to raise_error('The game cannot start. We are waiting for players.')
      end
    end
  end

  describe '.run_hypothesis_for' do
    context 'when the game did NOT started yet' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

        expect {
          described_class.run_hypothesis_for(id: 'existing_id', requester_id: nil)
        }.to raise_error('The game is not started yet')
      end
    end

    context 'when the game finished' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(finished_game.to_json)

        expect {
          described_class.run_hypothesis_for(id: 'existing_id', requester_id: nil)
        }.to raise_error('Finished game')
      end
    end

    context 'when the requester_id is NOT provided' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.run_hypothesis_for(id: 'existing_id', requester_id: nil)
        }.to raise_error('You must provide a requester_id')
      end
    end

    context 'when is not the turn of the user' do
      it 'raise an error' do
        started_game['_metadata']['_turn'] = 1
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.run_hypothesis_for(id: 'existing_id', requester_id: 'player_three_id')
        }.to raise_error('Is not the turn of this player')
      end
    end

    context 'when 3 cards are NOT provided' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.run_hypothesis_for(id: 'existing_id', requester_id: 'player_one_id', cards: [anything])
        }.to raise_error('You must provide 3 cards to start an hypothesis')
      end
    end

    context 'when more than 3 cards are provided' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.run_hypothesis_for(id: 'existing_id', requester_id: 'player_one_id', cards: [anything, anything, anything, anything])
        }.to raise_error('You must provide 3 cards to start an hypothesis')
      end
    end

    context 'when the provided cards are NOT valid' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::CardsService).to receive(:validate!).and_raise('not_valid_cards')
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.run_hypothesis_for(id: 'existing_id', requester_id: 'player_one_id', cards: [anything, anything, anything])
        }.to raise_error('not_valid_cards')
      end
    end

    context 'when a player has any of the requested cards' do
      it 'returns the player that has a card and the card itself' do
        allow(MakeApisFun::ClueApi::Services::CardsService).to receive(:validate!)
        allow(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_hypotheshis)
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
            .with('existing_id').and_return(started_game.to_json)

        response = described_class.run_hypothesis_for(
          id: 'existing_id',
          requester_id: 'player_one_id',
          cards: [
            { 'id' => 10, 'name' => 'card_name' },
            { 'id' => 16, 'name' => 'card_name' },
            { 'id' => 17, 'name' => 'card_name' }
          ]
        )

        expect(response).to eq({
          player: { id: 'player_two_id', name: 'player_two'},
          card: { 'id' => 10, 'name' => 'card_name' }
        })
      end

      it 'logs an event about the hypothesis' do
        allow(MakeApisFun::ClueApi::Services::CardsService).to receive(:validate!)
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
            .with('existing_id').and_return(started_game.to_json)

        expect(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_hypotheshis).once

        described_class.run_hypothesis_for(
          id: 'existing_id',
          requester_id: 'player_one_id',
          cards: [
            { 'id' => 10, 'name' => 'card_name' },
            { 'id' => 16, 'name' => 'card_name' },
            { 'id' => 17, 'name' => 'card_name' }
          ]
        )
      end

      context 'but the player that has the card is in the right side of the player' do
        it 'returns the player that has a card and the card itself' do
          started_game['_metadata']['_turn'] = 2

          allow(MakeApisFun::ClueApi::Services::CardsService).to receive(:validate!)
          allow(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_hypotheshis)
          allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
              .with('existing_id').and_return(started_game.to_json)

          response = described_class.run_hypothesis_for(
            id: 'existing_id',
            requester_id: 'player_three_id',
            cards: [
              { 'id' => 10, 'name' => 'card_name' },
              { 'id' => 16, 'name' => 'card_name' },
              { 'id' => 17, 'name' => 'card_name' }
            ]
          )

          expect(response).to eq({
            player: { id: 'player_two_id', name: 'player_two'},
            card: { 'id' => 10, 'name' => 'card_name' }
          })
        end
      end
    end

    context 'when the other players does NOT have any of the requested cards' do
      it 'returns nil' do
        allow(MakeApisFun::ClueApi::Services::CardsService).to receive(:validate!)
        allow(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_hypotheshis)
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
            .with('existing_id').and_return(started_game.to_json)

        response = described_class.run_hypothesis_for(
          id: 'existing_id',
          requester_id: 'player_one_id',
          cards: [
            { 'id' => 1, 'name' => 'card_name' },
            { 'id' => 2, 'name' => 'card_name' },
            { 'id' => 3, 'name' => 'card_name' }
          ]
        )

        expect(response).to be nil
      end

      it 'logs an event about the hypothesis' do
        allow(MakeApisFun::ClueApi::Services::CardsService).to receive(:validate!)
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
            .with('existing_id').and_return(started_game.to_json)

        expect(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_hypotheshis).once

        described_class.run_hypothesis_for(
          id: 'existing_id',
          requester_id: 'player_one_id',
          cards: [
            { 'id' => 1, 'name' => 'card_name' },
            { 'id' => 2, 'name' => 'card_name' },
            { 'id' => 3, 'name' => 'card_name' }
          ]
        )
      end
    end
  end

  describe '.update_turn_for' do
    it 'updates the game with the next turn' do
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

      expect(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)

      response = described_class.update_turn_for(id: 'existing_id')

      expect(response).to eq(1)
    end

    context 'when the current turn is for the last user of the round' do
      it 'restart the turn to 0' do
        started_game['_metadata']['_turn'] = 2
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)

        response = described_class.update_turn_for(id: 'existing_id')

        expect(response).to eq(0)
      end
    end

    context 'when the next turn is for a disabled user' do
      it 'update the turn again' do
        started_game['_metadata']['_turn'] = 1
        started_game['_metadata']['_players'] = [
          {
            'id' => 'player_one_id',
            'name' => 'player_one',
            'turn' => 0,
            'cards' => anything,
            'playing' => true
          },
          {
            'id' => 'player_two_id',
            'name' => 'player_two',
            'turn' => 1,
            'cards' => anything,
            'playing' => true
          },
          {
            'id' => 'player_three_id',
            'name' => 'player_one',
            'turn' => 2,
            'cards' => anything,
            'playing' => false
          },
        ]
        started_game_updated = started_game
        started_game['_metadata']['_turn'] = 2
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json, started_game_updated.to_json)

        expect(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save)

        response = described_class.update_turn_for(id: 'existing_id')

        expect(response).to eq(0)
      end
    end

    context 'when the game is not started yet' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

        expect {
          described_class.update_turn_for(id: 'existing_id')
        }.to raise_error('The game is not started yet')
      end
    end

    context 'when the game is finished' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(finished_game.to_json)

        expect {
          described_class.update_turn_for(id: 'existing_id')
        }.to raise_error('Finished game')
      end
    end
  end

  describe '.valid_solution?' do
    context 'when the game did NOT started yet' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

        expect {
          described_class.valid_solution?(id: 'existing_id', player_id: nil)
        }.to raise_error('The game is not started yet')
      end
    end

    context 'when the game finished' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(finished_game.to_json)

        expect {
          described_class.valid_solution?(id: 'existing_id', player_id: nil)
        }.to raise_error('Finished game')
      end
    end

    context 'when the player_id is NOT provided' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.valid_solution?(id: 'existing_id', player_id: nil)
        }.to raise_error('You must provide a player_id')
      end
    end

    context 'when is not the turn of the user' do
      it 'raise an error' do
        started_game['_metadata']['_turn'] = 1
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.valid_solution?(id: 'existing_id', player_id: 'player_three_id')
        }.to raise_error('Is not the turn of this player')
      end
    end

    context 'when 3 cards are NOT provided' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.valid_solution?(id: 'existing_id', player_id: 'player_one_id', cards: [anything])
        }.to raise_error('You must provide 3 cards to start an hypothesis')
      end
    end

    context 'when more than 3 cards are provided' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.valid_solution?(id: 'existing_id', player_id: 'player_one_id', cards: [anything, anything, anything, anything])
        }.to raise_error('You must provide 3 cards to start an hypothesis')
      end
    end

    context 'when the provided cards are NOT valid because wrong names, wrong ids or wrong combination of types' do
      it 'raise an error' do
        allow(MakeApisFun::ClueApi::Services::CardsService).to receive(:validate!).and_raise('not_valid_cards')
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.valid_solution?(id: 'existing_id', player_id: 'player_one_id', cards: [anything, anything, anything])
        }.to raise_error('not_valid_cards')
      end
    end

    context 'when the provided cards are the solution' do
      let(:valid_solution_cards) do
        [
          { 'id' => 1, 'name' => 'card_name' },
          { 'id' => 2, 'name' => 'card_name' },
          { 'id' => 3, 'name' => 'card_name' }
        ]
      end

      it 'return true' do
        allow(MakeApisFun::ClueApi::Services::CardsService).to receive(:validate!)
        allow(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_resolve)
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        response = described_class.valid_solution?(id: 'existing_id', player_id: 'player_one_id', cards: valid_solution_cards)
        
        expect(response).to be true
      end

      it 'logs the event' do
        allow(MakeApisFun::ClueApi::Services::CardsService).to receive(:validate!)
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_resolve)

        described_class.valid_solution?(id: 'existing_id', player_id: 'player_one_id', cards: valid_solution_cards)
      end
    end

    context 'when the provided cards are NOT the solution' do
      let(:invalid_solution_cards) do
        [
          { 'id' => 10, 'name' => 'card_name' },
          { 'id' => 11, 'name' => 'card_name' },
          { 'id' => 12, 'name' => 'card_name' }
        ]
      end

      it 'return false' do
        allow(MakeApisFun::ClueApi::Services::CardsService).to receive(:validate!)
        allow(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_resolve)
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        response = described_class.valid_solution?(id: 'existing_id', player_id: 'player_one_id', cards: invalid_solution_cards)
        
        expect(response).to be false
      end

      it 'logs the events' do
        allow(MakeApisFun::ClueApi::Services::CardsService).to receive(:validate!)
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect(MakeApisFun::ClueApi::Services::GameService::LogService).to receive(:log_resolve)

        described_class.valid_solution?(id: 'existing_id', player_id: 'player_one_id', cards: invalid_solution_cards)
      end
    end
  end

  describe '.disable_user' do
    it 'disables the provided user' do
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)
      expected_body_payload = hash_including(
        '_metadata' => hash_including(
          '_players' => array_including(
            [ hash_including('playing' => false) ]
            )
          )
        )
      expect(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save).
        with('existing_id', expected_body_payload)

      response = described_class.disable_user(id: 'existing_id', player_id: 'player_one_id')

      expect(response).to eq(true)
    end

    context 'when the game is not started yet' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

        expect {
          described_class.disable_user(id: 'existing_id', player_id: 'player_one_id')
        }.to raise_error('The game is not started yet')
      end
    end

    context 'when the game is finished' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(finished_game.to_json)

        expect {
          described_class.disable_user(id: 'existing_id', player_id: 'player_one_id')
        }.to raise_error('Finished game')
      end
    end

    context 'when the provided user does NOT exist' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.disable_user(id: 'existing_id', player_id: 'UNKNOWN_PLAYER_ID')
        }.to raise_error('User not found')
      end
    end
  end

  describe '.update_winner_for' do
    it 'updates the winner of the game' do
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)
      expect(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save).
        with('existing_id', hash_including('_metadata' => hash_including(
          '_winner' => 'player_one_id'
        )))

      response = described_class.update_winner_for(id: 'existing_id', winner_id: 'player_one_id')

      expect(response).to eq(true)
    end

    context 'when the game is not started yet' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

        expect {
          described_class.update_winner_for(id: 'existing_id', winner_id: 'player_one_id')
        }.to raise_error('The game is not started yet')
      end
    end

    context 'when the game is finished' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(finished_game.to_json)

        expect {
          described_class.update_winner_for(id: 'existing_id', winner_id: 'player_one_id')
        }.to raise_error('Finished game')
      end
    end

    context 'when the provided user does NOT exist' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        expect {
          described_class.update_winner_for(id: 'existing_id', winner_id: 'UNKNOWN_PLAYER_ID')
        }.to raise_error('User not found')
      end
    end
  end

  describe '.finish_game' do
    it 'mark the game as finished' do
      allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)
      expect(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:save).
        with('existing_id', hash_including('status' => 'finished'))

      described_class.finish_game(id: 'existing_id')
    end

    context 'when the game is not started yet' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

        expect {
          described_class.finish_game(id: 'existing_id')
        }.to raise_error('The game is not started yet')
      end
    end

    context 'when the game is finished' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(finished_game.to_json)

        expect {
          described_class.finish_game(id: 'existing_id')
        }.to raise_error('Finished game')
      end
    end
  end

  describe '.all_players_joined?' do
    context 'when all the player have joined' do
      it 'return true' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(started_game.to_json)

        response = described_class.all_players_joined?(id: 'existing_id')

        expect(response).to eq(true)
      end
    end

    context 'when all the player do NOT have joined' do
      it 'return false' do
       allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(waiting_for_players_game.to_json)

        response = described_class.all_players_joined?(id: 'existing_id')

        expect(response).to eq(false)
      end
    end

    context 'when the game is finished' do
      it 'raises an error' do
        allow(MakeApisFun::ClueApi::Services::GameService::Repository).to receive(:get)
          .with('existing_id').and_return(finished_game.to_json)

        expect {
          described_class.all_players_joined?(id: 'existing_id')
        }.to raise_error('Finished game')
      end
    end
  end
end