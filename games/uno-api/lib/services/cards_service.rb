module MakeApisFun
  module UnoApi
    module Services
      class CardsService
        RED_COLOR = 'red'.freeze
        YELLOW_COLOR = 'yellow'.freeze
        GREEN_COLOR = 'green'.freeze
        BLUE_COLOR = 'blue'.freeze

        SKIP_ACTION = 'skip'.freeze
        CHANGE_DIRECTION_ACTION = 'change_direction'.freeze
        DRAW_TWO_ACTION = 'draw_two'.freeze
        CHANGE_COLOR_ACTION = 'change_color'.freeze
        DRAW_FOUR_ACTION = 'draw_four'.freeze

        GAME_CARDS = [
          { id: 0, name: '0', color: RED_COLOR },
          { id: 1, name: '1', color: RED_COLOR },
          { id: 2, name: '2', color: RED_COLOR },
          { id: 3, name: '3', color: RED_COLOR },
          { id: 4, name: '4', color: RED_COLOR },
          { id: 5, name: '5', color: RED_COLOR },
          { id: 6, name: '6', color: RED_COLOR },
          { id: 7, name: '7', color: RED_COLOR },
          { id: 8, name: '8', color: RED_COLOR },
          { id: 9, name: '9', color: RED_COLOR },
          { id: 10, name: SKIP_ACTION, color: RED_COLOR },
          { id: 11, name: CHANGE_DIRECTION_ACTION, color: RED_COLOR },
          { id: 12, name: DRAW_TWO_ACTION, color: RED_COLOR },
          { id: 13, name: CHANGE_COLOR_ACTION, color: nil },
          { id: 14, name: '0', color: YELLOW_COLOR },
          { id: 15, name: '1', color: YELLOW_COLOR },
          { id: 16, name: '2', color: YELLOW_COLOR },
          { id: 17, name: '3', color: YELLOW_COLOR },
          { id: 18, name: '4', color: YELLOW_COLOR },
          { id: 19, name: '5', color: YELLOW_COLOR },
          { id: 20, name: '6', color: YELLOW_COLOR },
          { id: 21, name: '7', color: YELLOW_COLOR },
          { id: 22, name: '8', color: YELLOW_COLOR },
          { id: 23, name: '9', color: YELLOW_COLOR },
          { id: 24, name: SKIP_ACTION, color: YELLOW_COLOR },
          { id: 25, name: CHANGE_DIRECTION_ACTION, color: YELLOW_COLOR },
          { id: 26, name: DRAW_TWO_ACTION, color: YELLOW_COLOR },
          { id: 27, name: CHANGE_COLOR_ACTION, color: nil },
          { id: 28, name: '0', color: GREEN_COLOR },
          { id: 29, name: '1', color: GREEN_COLOR },
          { id: 30, name: '2', color: GREEN_COLOR },
          { id: 31, name: '3', color: GREEN_COLOR },
          { id: 32, name: '4', color: GREEN_COLOR },
          { id: 33, name: '5', color: GREEN_COLOR },
          { id: 34, name: '6', color: GREEN_COLOR },
          { id: 35, name: '7', color: GREEN_COLOR },
          { id: 36, name: '8', color: GREEN_COLOR },
          { id: 37, name: '9', color: GREEN_COLOR },
          { id: 38, name: SKIP_ACTION, color: GREEN_COLOR },
          { id: 39, name: CHANGE_DIRECTION_ACTION, color: GREEN_COLOR },
          { id: 40, name: DRAW_TWO_ACTION, color: GREEN_COLOR },
          { id: 41, name: CHANGE_COLOR_ACTION, color: nil },
          { id: 41, name: '0', color: BLUE_COLOR },
          { id: 43, name: '1', color: BLUE_COLOR },
          { id: 44, name: '2', color: BLUE_COLOR },
          { id: 45, name: '3', color: BLUE_COLOR },
          { id: 46, name: '4', color: BLUE_COLOR },
          { id: 47, name: '5', color: BLUE_COLOR },
          { id: 48, name: '6', color: BLUE_COLOR },
          { id: 49, name: '7', color: BLUE_COLOR },
          { id: 50, name: '8', color: BLUE_COLOR },
          { id: 51, name: '9', color: BLUE_COLOR },
          { id: 51, name: SKIP_ACTION, color: BLUE_COLOR },
          { id: 53, name: CHANGE_DIRECTION_ACTION, color: BLUE_COLOR },
          { id: 54, name: DRAW_TWO_ACTION, color: BLUE_COLOR },
          { id: 55, name: CHANGE_COLOR_ACTION, color: nil },
          { id: 56, name: '1', color: RED_COLOR },
          { id: 57, name: '2', color: RED_COLOR },
          { id: 58, name: '3', color: RED_COLOR },
          { id: 59, name: '4', color: RED_COLOR },
          { id: 60, name: '5', color: RED_COLOR },
          { id: 61, name: '6', color: RED_COLOR },
          { id: 62, name: '7', color: RED_COLOR },
          { id: 63, name: '8', color: RED_COLOR },
          { id: 64, name: '9', color: RED_COLOR },
          { id: 65, name: SKIP_ACTION, color: RED_COLOR },
          { id: 66, name: CHANGE_DIRECTION_ACTION, color: RED_COLOR },
          { id: 67, name: DRAW_TWO_ACTION, color: RED_COLOR },
          { id: 68, name: DRAW_FOUR_ACTION, color: nil },
          { id: 69, name: '1', color: YELLOW_COLOR },
          { id: 70, name: '2', color: YELLOW_COLOR },
          { id: 71, name: '3', color: YELLOW_COLOR },
          { id: 72, name: '4', color: YELLOW_COLOR },
          { id: 73, name: '5', color: YELLOW_COLOR },
          { id: 74, name: '6', color: YELLOW_COLOR },
          { id: 75, name: '7', color: YELLOW_COLOR },
          { id: 76, name: '8', color: YELLOW_COLOR },
          { id: 77, name: '9', color: YELLOW_COLOR },
          { id: 78, name: SKIP_ACTION, color: YELLOW_COLOR },
          { id: 79, name: CHANGE_DIRECTION_ACTION, color: YELLOW_COLOR },
          { id: 80, name: DRAW_TWO_ACTION, color: YELLOW_COLOR },
          { id: 81, name: DRAW_FOUR_ACTION, color: nil },
          { id: 82, name: '1', color: GREEN_COLOR },
          { id: 83, name: '2', color: GREEN_COLOR },
          { id: 84, name: '3', color: GREEN_COLOR },
          { id: 85, name: '4', color: GREEN_COLOR },
          { id: 86, name: '5', color: GREEN_COLOR },
          { id: 87, name: '6', color: GREEN_COLOR },
          { id: 88, name: '7', color: GREEN_COLOR },
          { id: 89, name: '8', color: GREEN_COLOR },
          { id: 90, name: '9', color: GREEN_COLOR },
          { id: 91, name: SKIP_ACTION, color: GREEN_COLOR },
          { id: 92, name: CHANGE_DIRECTION_ACTION, color: GREEN_COLOR },
          { id: 93, name: DRAW_TWO_ACTION, color: GREEN_COLOR },
          { id: 94, name: DRAW_FOUR_ACTION, color: nil },
          { id: 95, name: '1', color: BLUE_COLOR },
          { id: 96, name: '2', color: BLUE_COLOR },
          { id: 97, name: '3', color: BLUE_COLOR },
          { id: 98, name: '4', color: BLUE_COLOR },
          { id: 99, name: '5', color: BLUE_COLOR },
          { id: 100, name: '6', color: BLUE_COLOR },
          { id: 101, name: '7', color: BLUE_COLOR },
          { id: 102, name: '8', color: BLUE_COLOR },
          { id: 103, name: '9', color: BLUE_COLOR },
          { id: 104, name: SKIP_ACTION, color: BLUE_COLOR },
          { id: 105, name: CHANGE_DIRECTION_ACTION, color: BLUE_COLOR },
          { id: 106, name: DRAW_TWO_ACTION, color: BLUE_COLOR },
          { id: 107, name: DRAW_FOUR_ACTION, color: nil }
        ]

        class << self
          def random_card
            GAME_CARDS[path].sample
          end

          def get_initial_cards_for_player_by(game)
            available_cards = available_cards_for_this(game)

            number_of_cards_for_player = 7

            available_cards.sample(number_of_cards_for_player)
          end

          def validate!(cards)
            nil
          end

          private

          def available_cards_for_this(game)
            GAME_CARDS.reject { |card| assigned_cards_for_this(game).any?(card['id']) }
          end

          def assigned_cards_for_this(game)
            assigned_cards = []

            game['_metadata']['_players'].each do |player|
              assigned_cards = assigned_cards.concat(player['cards'])
            end

            assigned_cards.map { |card| card['id'] }.uniq
          end

          def card_by_id(id)
            GAME_CARDS.find { |card| card['id'] == id }
          end
        end
      end
    end
  end
end