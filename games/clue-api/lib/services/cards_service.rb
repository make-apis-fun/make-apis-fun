module MakeApisFun
  module ClueApi
    module Services
      class CardsService
        GAME_CARDS = {
          'murderers' => [
            { 'id' => 0, 'name' => 'James'},
            { 'id' => 1, 'name' => 'Violet'},
            { 'id' => 2, 'name' => 'Matthew'},
            { 'id' => 3, 'name' => 'Sophie'},
            { 'id' => 4, 'name' => 'Adam'},
            { 'id' => 5, 'name' => 'Lewis'}
          ],
          'weapons' => [
            { 'id' => 6, 'name' => 'Bottle'},
            { 'id' => 7, 'name' => 'Knife'},
            { 'id' => 8, 'name' => 'Poison'},
            { 'id' => 9, 'name' => 'Keyboard'},
            { 'id' => 10, 'name' => 'Guitar'},
            { 'id' => 11, 'name' => 'Shoe'}
          ],
          'rooms' => [
            { 'id' => 12, 'name' => "Study"},
            { 'id' => 13, 'name' => "Hall"},
            { 'id' => 14, 'name' => "Lounge"},
            { 'id' => 15, 'name' => "Library"},
            { 'id' => 16, 'name' => "Billard Room"},
            { 'id' => 17, 'name' => "Dinning Room"},
            { 'id' => 18, 'name' => "Kitchen"},
            { 'id' => 19, 'name' => "Ball Room"},
            { 'id' => 20, 'name' => "Conservatory"}
          ]
        }

        class << self
          def random_murderer_card
            random_card_by(path: 'murderers')
          end

          def random_weapon_card
            random_card_by(path: 'weapons')
          end

          def random_room_card
            random_card_by(path: 'rooms')
          end

          def get_cards_for_player_by(game)
            available_cards = available_cards_for_this(game)

            pending_players_to_be_assigned = game['num_players'] - game['_metadata']['_players'].size
            number_of_cards_for_player = (available_cards.size / pending_players_to_be_assigned).round

            available_cards.sample(number_of_cards_for_player)
          end

          def validate!(cards)
            validate_names!(cards)
            validate_one_of_each_type!(cards)
          end

          private

          def random_card_by(path:)
            GAME_CARDS[path].sample
          end

          def available_cards_for_this(game)
            all_cards.reject { |card| assigned_cards_for_this(game).any?(card['id']) }
          end

          def all_cards
            GAME_CARDS['murderers'] + GAME_CARDS['weapons'] + GAME_CARDS['rooms']
          end

          def assigned_cards_for_this(game)
            assigned_cards = []
            assigned_cards << game['_metadata']['_solution']['_murderer']
            assigned_cards << game['_metadata']['_solution']['_weapon']
            assigned_cards << game['_metadata']['_solution']['_room']

            game['_metadata']['_players'].each do |player|
              assigned_cards = assigned_cards.concat(player['cards'])
            end

            assigned_cards.map { |card| card['id'] }.uniq
          end

          def card_by_id(id)
            all_cards.find { |card| card['id'] == id }
          end

          def validate_names!(cards)
            cards.each do |card|
              valid_card = card_by_id(card['id'])
              raise "The provided card #{card['id']} does not have a valid name" unless valid_card['name'] == card['name']
            end
          end

          def validate_one_of_each_type!(cards)
            murderer_card = GAME_CARDS['murderers'].find { |murderer_card| murderer_card['id'] == cards[0]['id'] }
            raise 'Murderer card must be provided in the first position' unless murderer_card

            weapon_card = GAME_CARDS['weapons'].find { |weapon_card| weapon_card['id'] == cards[1]['id'] }
            raise 'Weapon card must be provided in the second position' unless weapon_card

            room_card = GAME_CARDS['rooms'].find { |room_card| room_card['id'] == cards[2]['id'] }
            raise 'Room card must be provided in the third position' unless room_card          
          end
        end
      end
    end
  end
end