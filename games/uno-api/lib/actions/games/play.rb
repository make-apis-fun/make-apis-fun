require_relative '../../services/game_service'

module MakeApisFun
  module UnoApi
    module Actions
      module Games
        class Play 
          class << self
            def do(game_id:, player_id:, action:, card:)
              response = play(game_id, player_id, action, card)
              update_turn(game_id)
              perform_bots_actions_for(game_id)

              response
            rescue => e
              { error: e.message }
            end

            private

            def play(game_id, player_id, action, card)
              Services::GameService.play(id: game_id, requester_id: player_id, action: action, card: card)
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

