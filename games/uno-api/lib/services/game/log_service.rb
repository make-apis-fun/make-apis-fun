require_relative 'repository'

module MakeApisFun
  module UnoApi
    module Services
      class GameService
        class LogService
          class << self
            def log_join(game:, player:)
              msg = "Player #{player['name']} joined the game"
              log_for(game, msg)

              game
            end

            def log_start(game:)
              msg = "The game has started at #{game['started_at']}"
              log_for(game, msg)

              game
            end

            private

            def logs_for(game)
              game['_metadata']['_logs']
            end

            def log_for(game, msg)
              logs_for(game) << msg
              Repository.save(game['id'], game)
            end
          end
        end
      end
    end
  end
end