require_relative '../../services/game_service'

module MakeApisFun
  module ClueApi
    module Actions
      module Games
        class Resolve 
          class << self
            def do(game_id:, player_id:, cards:)
              if valid_solution?(game_id, player_id, cards)
                update_winner(game_id, player_id)
                finish_game(game_id)

                return { status: 'OK', message: 'Congratulations, you are the winner of this game!'}
              else
                disable_user(game_id, player_id)
                update_turn(game_id)
                perform_bots_actions_for(game_id)

                return { status: 'WRONG', message: 'Sorry, your solution was not valid. You cannot continue playing :(' }
              end
            rescue => e
              { error: e.message }
            end

            private

            def valid_solution?(game_id, player_id, cards)
              Services::GameService.valid_solution?(id: game_id, player_id: player_id, cards: cards)
            end

            def update_winner(game_id, player_id)
              Services::GameService.update_winner_for(id: game_id, winner_id: player_id)
            end

            def finish_game(game_id)
              Services::GameService.finish_game(id: game_id)
            end

            def disable_user(game_id, player_id)
              Services::GameService.disable_user(id: game_id, player_id: player_id)
            end

            def update_turn(game_id)
              Services::GameService.update_turn_for(id: game_id)
            end

            def perform_bots_actions_for(game_id)
              Services::GameService.perform_bots_actions_for(id: game_id)
            end
          end
        end
      end
    end
  end
end

