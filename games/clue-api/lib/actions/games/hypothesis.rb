require_relative '../../services/game_service'

module MakeApisFun
  module ClueApi
    module Actions
      module Games
        class Hypothesis 
          class << self
            def do(game_id:, player_id:, cards:)
              player_with_card = run_hypothesis_for(game_id, player_id, cards)
              update_turn(game_id)
              perform_bots_actions_for(game_id)

              player_with_card
            rescue => e
              { error: e.message }
            end

            private

            def run_hypothesis_for(game_id, player_id, cards)
              Services::GameService.run_hypothesis_for(id: game_id, requester_id: player_id, cards: cards)
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

