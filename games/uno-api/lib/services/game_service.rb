require_relative 'cards_service'
require_relative 'game/log_service'
require_relative 'game/repository'

module MakeApisFun
  module UnoApi
    module Services
      class GameService
        WAITING_FOR_PLAYERS = 'waiting_for_players'.freeze
        STARTED = 'started'.freeze
        FINISHED = 'finished'.freeze

        BOT_NAMES = ['Millard', 'Margot', 'Valarie', 'Charlsie', 'Maren', 'Myra', 'Chang', 'Margaret', 'Deangelo', 
          'Lenore', 'Afton', 'Ardell', 'Jim', 'Marilynn', 'Roberta', 'Calvin', 'Alix', 'Corey', 'Johnetta', 'Shaunna',
          'Scot', 'Jame', 'Asha', 'Ginny', 'Tonya', 'Lauran', 'Doloris', 'Codi', 'Eloy', 'Shalonda', 'Fransisca', 'Tanna',
          'Breann', 'Refugia', 'Emilia', 'Ocie', 'Armando', 'Johna', 'Florine', 'Lucius', 'Lawrence', 'Artie', 'Pamela',
          'Selina', 'Kimberli', 'Lemuel', 'Junko', 'Hermina', 'Drusilla', 'Elijah'].freeze

        DRAW_ACTION = 'draw'.freeze

        class << self
          def fetch_by(id:)
            stored_game = Repository.get(id)
            raise 'Invalid or expired game id' unless stored_game

            JSON.parse(stored_game)
          end

          def create(num_players: 6)
            num_players = 3 if num_players < 3
            num_players = 10 if num_players > 10

            create_game(num_players)
          end

          def join_to(id:, player_name:, bot: false)
            existing_game = fetch_by(id: id)
            
            validate_game_already_started!(existing_game)
            validate_not_finished!(existing_game)
            validate_no_more_players_allowed!(existing_game)
            validate_not_empty!(player_name, 'name')
            validate_repeated_names!(existing_game, player_name)

            new_player = new_player_with_cards_and_turn(player_name, existing_game, bot)
            players_for(existing_game) << new_player
            update(id, existing_game)
            new_player[:game_id] = id

            LogService.log_join(game: existing_game, player: new_player)

            new_player
          end

          def join_bots_to(id:)
            existing_game = fetch_by(id: id)

            validate_game_already_started!(existing_game)
            validate_not_finished!(existing_game)
            validate_no_more_players_allowed!(existing_game)

            bots_to_add = existing_game['num_players'] - 1

            bots_to_add.times do |bot|
              join_to(id: id, player_name: random_player_name_for(id), bot: true)
            end
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

          def play(id:, requester_id:, action:, card:)
            existing_game = fetch_by(id: id)

            validate_game_is_started!(existing_game)
            validate_not_finished!(existing_game)
            validate_not_empty!(requester_id, 'requester_id')
            validate_turn!(requester_id, existing_game)

            player = player_by(requester_id, existing_game)
            raise 'User not found' unless player

            if card
              validate_card!(card)

              metadata = existing_game['_metadata']
              metadata['_players'].map do |player|
                if player['id'] == requester_id
                  player['cards'].delete_if { |player_card| player_card['id'] == card['id'] }
                end
              end

              metadata['_used_cards'] << card

              existing_game['_metadata'] = metadata
              update(id, existing_game)
            else
              #draw
            end

            # LogService.log_hypotheshis(
            #   game: existing_game,
            #   requester: player_by(requester_id, existing_game),
            #   cards: cards,
            #   player_with_card: player_with_card
            # )

            fetch_by(id: id)
          end

          def perform_bots_actions_for(id:)
            game = fetch_by(id: id)
            next_player = next_player_for(game)

            return unless next_player['bot']

            random_card = next_player['cards'].sample
            random_card.delete('id')

            play(id: id, requester_id: next_player['id'], action: 'play', card: random_card)

            update_turn_for(id: id)

            perform_bots_actions_for(id: id)
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

            next_turn
          end

          def update_winner_for(id:, winner_id:)
            existing_game = fetch_by(id: id)

            validate_game_is_started!(existing_game)
            validate_not_finished!(existing_game)

            player = player_by(winner_id, existing_game)
            raise 'User not found' unless player

            existing_game['_metadata']['_winner'] = player['name']
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

          def fetch_cards_for(id:, player_id:)
            existing_game = fetch_by(id: id)

            validate_not_empty!(player_id, 'player_id')

            player = player_by(player_id, existing_game)
            raise 'User not found' unless player

            player['cards']
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
                '_turn' => 0,
                '_direction' => 'asc',
                '_current_color' => nil,
                '_players' => [],
                '_logs' => [],
                '_used_cards' => [],
                '_action_pending' => nil,
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

          def new_player_with_cards_and_turn(name, game, bot)
            {
              'id' => SecureRandom.alphanumeric(7),
              'name' => name,
              'turn' => next_turn_for(game),
              'cards' => CardsService.get_initial_cards_for_player_by(game),
              'bot' => bot
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

          def validate_repeated_names!(game, player_name)
            raise 'The name cannot have more than 12 characters. Use a different one.' if player_name.size > 12

            all_players = players_for(game)
            players_with_same_name = all_players.select do |player|
              player['name'].downcase == player_name.downcase
            end

            raise 'There is another player with the same name. Use a different one.' unless players_with_same_name.empty?
          end

          def validate_card!(card)
            CardsService.validate!(card)
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

          def next_player_for(game)
            turn = current_turn_for(game)

            player = player_by_turn_for(game, turn)

            player
          end

          def now
            Time.now.strftime("%d/%m/%Y %H:%M:%S")
          end

          def random_player_name_for(game_id)
            candidate = BOT_NAMES.sample(1).first

            game = fetch_by(id: game_id)
            current_players = players_for(game)

            same_name_player = current_players.find { |player| player['name'] == candidate }
            return random_player_name_for(game_id) if same_name_player

            candidate
          end
        end
      end
    end
  end
end