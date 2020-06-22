require_relative '../../../services/game_service'

module MakeApisFun
  module UnoApi
    module Actions
      module Games
        module Players
          class FetchCards
            class << self
              def do(game_id:, player_id:)
                cards = Services::GameService.fetch_cards_for(id: game_id, player_id: player_id)

                { cards: cards }
              rescue => e
                { error: e.message }
              end
            end
          end
        end
      end
    end
  end
end