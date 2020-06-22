require_relative '../../services/game_service'

module MakeApisFun
  module UnoApi
    module Actions
      module Games
        class Join 
          class << self
            def do(game_id:, player_name:)
              new_user = join_to(game_id, player_name)

              if should_start?(game_id)
                start(game_id)
                perform_bots_actions_for(game_id)
              end

              new_user
            rescue => e
              { error: e.message }
            end

            private

            def join_to(game_id, player_name)
              Services::GameService.join_to(id: game_id, player_name: player_name)
            end

            def should_start?(game_id)
              Services::GameService.all_players_joined?(id: game_id)
            end

            def start(game_id)
              Services::GameService.start(id: game_id)
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