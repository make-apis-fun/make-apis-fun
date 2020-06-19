require_relative 'cards_service'
require_relative 'game/log_service'
require_relative 'game/repository'

module MakeApisFun
  module ClueApi
    module Services
      class GameService
        WAITING_FOR_PLAYERS = 'waiting_for_players'.freeze
        STARTED = 'started'.freeze
        FINISHED = 'finished'.freeze

        class << self
          def fetch_by(id:)
            stored_game = Repository.get(id)
            raise 'Invalid or expired game id' unless stored_game

            JSON.parse(stored_game)
          end

          def create(num_players:3)
            num_players = 4 if num_players == nil
            num_players = 3 if num_players < 3
            num_players = 6 if num_players > 6

            create_game(num_players)
          end

          def join_to(id:, player_name:)
            existing_game = fetch_by(id: id)
            
            validate_game_already_started!(existing_game)
            validate_not_finished!(existing_game)
            validate_no_more_players_allowed!(existing_game)
            validate_not_empty!(player_name, 'name')
            validate_repeated_names!(existing_game, player_name)

            new_player = new_player_with_cards_and_turn(player_name, existing_game)
            players_for(existing_game) << new_player
            update(id, existing_game)
            new_player[:game_id] = id

            LogService.log_join(game: existing_game, player: new_player)

            new_player
          end

          def start(id:)
            existing_game = fetch_by(id: id)
            validate_game_already_started!(existing_game)
            validate_not_finished!(existing_game)
            validate_all_players!(existing_game)

            existing_game['status'] = STARTED
            existing_game['started_at'] = now
            update(id, existing_game)

            LogService.log_start(game: existing_game)

            existing_game
          end

          def run_hypothesis_for(id:, requester_id:, cards:[])
            existing_game = fetch_by(id: id)

            validate_game_is_started!(existing_game)
            validate_not_finished!(existing_game)
            validate_not_empty!(requester_id, 'requester_id')
            validate_turn!(requester_id, existing_game)
            validate_cards_size!(cards)
            validate_hypothesis_cards!(cards)

            player_with_card = player_in_turn_order_with_any(cards, requester_id, existing_game)

            LogService.log_hypotheshis(
              game: existing_game,
              requester: player_by(requester_id, existing_game),
              cards: cards,
              player_with_card: player_with_card
            )

            player_with_card
          end

          def update_turn_for(id:)
            existing_game = fetch_by(id: id)

            validate_game_is_started!(existing_game)
            validate_not_finished!(existing_game)

            if (existing_game['_metadata']['_turn'] >= existing_game['num_players'] - 1)
              next_turn = 0
            else
              next_turn = existing_game['_metadata']['_turn'] + 1
            end

            existing_game['_metadata']['_turn'] =  next_turn
            update(id, existing_game)

            player = player_by_turn_for(existing_game, next_turn)
            return update_turn_for(id: id) unless player['playing']

            next_turn
          end

          def valid_solution?(id:, player_id:, cards:[])
            existing_game = fetch_by(id: id)

            validate_game_is_started!(existing_game)
            validate_not_finished!(existing_game)
            validate_not_empty!(player_id, 'player_id')
            validate_turn!(player_id, existing_game)
            validate_cards_size!(cards)
            validate_hypothesis_cards!(cards)

            solution_ids = solution_ids_for(existing_game)
            cards_ids = cards.map { |card| card['id'] }

            valid = solution_ids.sort == cards_ids.sort

            LogService.log_resolve(
              game: existing_game,
              player: player_by(player_id, existing_game),
              cards: cards,
              valid: valid
            )

            valid
          end

          def disable_user(id:, player_id:)
            existing_game = fetch_by(id: id)

            validate_game_is_started!(existing_game)
            validate_not_finished!(existing_game)

            player = player_by(player_id, existing_game)
            player['playing'] = false

            update(id, existing_game)

            true
          end

          def update_winner_for(id:, winner_id:)
            existing_game = fetch_by(id: id)

            validate_game_is_started!(existing_game)
            validate_not_finished!(existing_game)

            player = player_by(winner_id, existing_game)
            raise 'User not found' unless player

            existing_game['_metadata']['_winner'] = winner_id
            update(id, existing_game)

            true
          end

          def finish_game(id:)
            existing_game = fetch_by(id: id)

            validate_game_is_started!(existing_game)
            validate_not_finished!(existing_game)

            existing_game['status'] = FINISHED
            existing_game['finished_at'] = now
            update(id, existing_game)

            existing_game
          end

          def all_players_joined?(id:)
            existing_game = fetch_by(id: id)

            validate_not_finished!(existing_game)

            all_players?(existing_game)
          end

          private

          def create_game(num_players)
            id = SecureRandom.alphanumeric(7)
            game = {
              'id' => id,
              'num_players' => num_players,
              'status' => WAITING_FOR_PLAYERS,
              'created_at' => now,
              'started_at' => nil,
              'finished_at' => nil,
              '_metadata' => {
                '_logs' => [],
                '_players' => [],
                '_solution' => {
                  '_murderer' => CardsService.random_murderer_card,
                  '_weapon' => CardsService.random_weapon_card,
                  '_room' => CardsService.random_room_card
                },
                '_turn' => 0,
                '_winner' => nil
              }
            }
            Repository.save(id, game)

            game
          end

          def all_players?(game)
            game['num_players'] == players_for(game).size
          end

          def players_for(game)
            game['_metadata']['_players']
          end

          def new_player_with_cards_and_turn(name, game)
            {
              'id' => SecureRandom.alphanumeric(7),
              'name' => name,
              'turn' => next_turn_for(game),
              'cards' => CardsService.get_cards_for_player_by(game),
              'playing' => true
            }
          end

          def next_turn_for(game)
            players_for(game).size
          end

          def update(id, payload)
            Repository.save(id, payload)
          end

          def validate_not_finished!(game)
            raise 'Finished game' if finished?(game)
          end

          def validate_game_already_started!(game)
            raise 'Game already started' if started?(game)
          end

          def validate_game_is_started!(game)
            raise 'The game is not started yet' if waiting_for_players?(game)
          end

          def validate_no_more_players_allowed!(game)
            raise 'No more players allowed' if all_players?(game)
          end

          def validate_all_players!(game)
            raise 'The game cannot start. We are waiting for players.' unless all_players?(game)
          end

          def validate_not_empty!(to_validate, field)
            raise "You must provide a #{field}" if to_validate.nil? || to_validate.to_s.empty?
          end

          def validate_cards_size!(cards)
            raise 'You must provide 3 cards to start an hypothesis' unless cards.size == 3
          end

          def validate_repeated_names!(game, player_name)
            raise 'The name cannot have more than 12 characters. Use a different one.' if player_name.size > 12

            all_players = players_for(game)
            players_with_same_name = all_players.select do |player|
              player['name'].downcase == player_name.downcase
            end

            raise 'There is another player with the same name. Use a different one.' unless players_with_same_name.empty?
          end

          def validate_hypothesis_cards!(cards)
            CardsService.validate!(cards)
          end

          def validate_turn!(requester_id, game)
            player = player_by(requester_id, game)

            raise 'Is not the turn of this player' unless current_turn_for(game) == player['turn']
          end

          def waiting_for_players?(game)
            game['status'] == WAITING_FOR_PLAYERS
          end

          def started?(game)
            game['status'] == STARTED
          end

          def finished?(game)
            game['status'] == FINISHED
          end

          def player_in_turn_order_with_any(cards, requester_id, game)
            all_players = players_for(game)
            requester = all_players.find { |player| player['id'] == requester_id }

            raise 'Not existing user' unless requester

            players_on_requesters_right = []
            all_players.each do |player|
              next if player['id'] == requester_id

              if player['turn'] < requester['turn']
                players_on_requesters_right << player 
              else
                possible_cards_to_show = player['cards'].select do |card|
                  cards.map{ |card| card['id'] }.include?(card['id'])
                end

                if possible_cards_to_show.any?
                  return {
                    player: { id: player['id'], name: player['name']},
                    card: possible_cards_to_show.sample
                  }
                end
              end
            end

            players_on_requesters_right.each do |player|
              next if player['id'] == requester_id

              possible_cards_to_show = player['cards'].select do |card|
                cards.map{ |card| card['id'] }.include?(card['id'])
              end

              if possible_cards_to_show.any?
                return {
                  player: { name: player['name'] },
                  card: possible_cards_to_show.sample
                }
              end
            end

            nil
          end

          def player_by(player_id, game)
            all_players = players_for(game)
            player = all_players.find { |player| player['id'] == player_id }

            raise 'User not found' unless player

            player
          end

          def player_by_turn_for(game, turn)
            all_players = players_for(game)
            player = all_players.find { |player| player['turn'] == turn }

            raise 'User not found' unless player

            player
          end

          def current_turn_for(game)
            game['_metadata']['_turn']
          end

          def solution_ids_for(game)
            cards = []
            solution = game['_metadata']['_solution']

            cards << solution['_murderer']['id']
            cards << solution['_weapon']['id']
            cards << solution['_room']['id']

            cards
          end

          def now
            Time.now.strftime("%d/%m/%Y %H:%M:%S")
          end
        end
      end
    end
  end
end