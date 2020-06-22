require_relative '../../services/game_service'

module MakeApisFun
  module UnoApi
    module Actions
      module Games
        class Fetch 
          class << self
            def do(game_id:)
              Services::GameService.fetch_by(id: game_id)
            rescue => e
              { error: e.message }
            end
          end
        end
      end
    end
  end
end