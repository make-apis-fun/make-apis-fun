require_relative '../../services/game_service'

module MakeApisFun
  module ClueApi
    module Actions
      module Games
        class Create 
          class << self
            def do(num_players:, against_machine:)
              new_game_id = create_game(num_players)['id']

              join_bots_to(new_game_id) if against_machine.nil? || against_machine.to_s.downcase == 'true'

              fetch_by(new_game_id)
            rescue => e
              { error: e.message }
            end

            private

            def create_game(num_players)
              Services::GameService.create(num_players: num_players)
            end

            def join_bots_to(game_id)
              Services::GameService.join_bots_to(id: game_id)
            end

            def fetch_by(game_id)
              Services::GameService.fetch_by(id: game_id)
            end
          end
        end
      end
    end
  end
end