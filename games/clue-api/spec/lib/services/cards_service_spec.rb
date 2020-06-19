require 'redis'
require_relative '../../spec_helper'
require 'services/game_service'

describe MakeApisFun::ClueApi::Services::CardsService do
  let(:murderers_cards) do
    [
        { 'id' => 0, 'name' => 'James'},
        { 'id' => 1, 'name' => 'Violet'},
        { 'id' => 2, 'name' => 'Matthew'},
        { 'id' => 3, 'name' => 'Sophie'},
        { 'id' => 4, 'name' => 'Adam'},
        { 'id' => 5, 'name' => 'Lewis'}
      ]
  end
  let(:weapons_cards) do
    [
      { 'id' => 6, 'name' => 'Bottle'},
      { 'id' => 7, 'name' => 'Knife'},
      { 'id' => 8, 'name' => 'Poison'},
      { 'id' => 9, 'name' => 'Keyboard'},
      { 'id' => 10, 'name' => 'Guitar'},
      { 'id' => 11, 'name' => 'Shoe'}
    ]
  end
  let(:rooms_cards) do
    [
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
  end

  describe '.random_murderer_card' do
    it 'return one of the murderer cards' do
      response = described_class.random_murderer_card

      expect(murderers_cards).to include(response)
    end
  end

  describe '.random_weapon_card' do
    it 'return one of the weapon cards' do
      response = described_class.random_weapon_card

      expect(weapons_cards).to include(response)
    end
  end

  describe '.random_room_card' do
    it 'return one of the room cards' do
      response = described_class.random_room_card

      expect(rooms_cards).to include(response)
    end
  end

  describe '.get_cards_for_player_by' do
    context 'when the game has been created for 3 players' do
      context 'and there are no players joined yet' do
        it 'return 6 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 3,
            '_metadata' => {
              '_players' => [],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(6)
        end
      end

      context 'and there is 1 player joined' do
        it 'return 6 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 3,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' },
                    { 'id' => 7, 'name' => 'card_name' },
                    { 'id' => 8, 'name' => 'card_name' },
                    { 'id' => 9, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(6)
        end
      end

      context 'and there are 2 players joined yet' do
        it 'return 6 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 3,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' },
                    { 'id' => 7, 'name' => 'card_name' },
                    { 'id' => 8, 'name' => 'card_name' },
                    { 'id' => 9, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_two_id', 
                  'name' => 'player_two',
                  'turn' => 1,
                  'cards' => [
                    { 'id' => 10, 'name' => 'card_name' },
                    { 'id' => 11, 'name' => 'card_name' },
                    { 'id' => 12, 'name' => 'card_name' },
                    { 'id' => 13, 'name' => 'card_name' },
                    { 'id' => 14, 'name' => 'card_name' },
                    { 'id' => 15, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(6)
        end
      end
    end

    context 'when the game has been created for 4 players' do
      context 'and there are no players joined yet' do
        it 'return 4 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 4,
            '_metadata' => {
              '_players' => [],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(4)
        end
      end

      context 'and there is 1 player joined' do
        it 'return 4 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 4,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' },
                    { 'id' => 7, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(4)
        end
      end

      context 'and there are 2 players joined yet' do
        it 'return 5 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 4,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' },
                    { 'id' => 7, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_two_id', 
                  'name' => 'player_two',
                  'turn' => 1,
                  'cards' => [
                    { 'id' => 8, 'name' => 'card_name' },
                    { 'id' => 9, 'name' => 'card_name' },
                    { 'id' => 10, 'name' => 'card_name' },
                    { 'id' => 11, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(5)
        end
      end

      context 'and there are 3 players joined yet' do
        it 'return 6 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 4,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' },
                    { 'id' => 7, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_two_id', 
                  'name' => 'player_two',
                  'turn' => 1,
                  'cards' => [
                    { 'id' => 8, 'name' => 'card_name' },
                    { 'id' => 9, 'name' => 'card_name' },
                    { 'id' => 10, 'name' => 'card_name' },
                    { 'id' => 11, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_three_id', 
                  'name' => 'player_three',
                  'turn' => 2,
                  'cards' => [
                    { 'id' => 12, 'name' => 'card_name' },
                    { 'id' => 13, 'name' => 'card_name' },
                    { 'id' => 14, 'name' => 'card_name' },
                    { 'id' => 15, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(6)
        end
      end
    end

    context 'when the game has been created for 5 players' do
      context 'and there are no players joined yet' do
        it 'return 3 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 5,
            '_metadata' => {
              '_players' => [],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(3)
        end
      end

      context 'and there is 1 player joined' do
        it 'return 3 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 5,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(3)
        end
      end

      context 'and there are 2 players joined yet' do
        it 'return 4 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 5,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_two_id', 
                  'name' => 'player_two',
                  'turn' => 1,
                  'cards' => [
                    { 'id' => 7, 'name' => 'card_name' },
                    { 'id' => 8, 'name' => 'card_name' },
                    { 'id' => 9, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(4)
        end
      end

      context 'and there are 3 players joined yet' do
        it 'return 4 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 5,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' },
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_two_id', 
                  'name' => 'player_two',
                  'turn' => 1,
                  'cards' => [
                    { 'id' => 7, 'name' => 'card_name' },
                    { 'id' => 8, 'name' => 'card_name' },
                    { 'id' => 9, 'name' => 'card_name' },
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_three_id', 
                  'name' => 'player_three',
                  'turn' => 2,
                  'cards' => [
                    { 'id' => 10, 'name' => 'card_name' },
                    { 'id' => 11, 'name' => 'card_name' },
                    { 'id' => 12, 'name' => 'card_name' },
                    { 'id' => 13, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(4)
        end
      end

      context 'and there are 4 players joined yet' do
        it 'return 4 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 5,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_two_id', 
                  'name' => 'player_two',
                  'turn' => 1,
                  'cards' => [
                    { 'id' => 7, 'name' => 'card_name' },
                    { 'id' => 8, 'name' => 'card_name' },
                    { 'id' => 9, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_three_id', 
                  'name' => 'player_three',
                  'turn' => 2,
                  'cards' => [
                    { 'id' => 10, 'name' => 'card_name' },
                    { 'id' => 11, 'name' => 'card_name' },
                    { 'id' => 12, 'name' => 'card_name' },
                    { 'id' => 13, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_four_id', 
                  'name' => 'player_three',
                  'turn' => 2,
                  'cards' => [
                    { 'id' => 14, 'name' => 'card_name' },
                    { 'id' => 15, 'name' => 'card_name' },
                    { 'id' => 16, 'name' => 'card_name' },
                    { 'id' => 17, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(4)
        end
      end
    end

    context 'when the game has been created for 6 players' do
      context 'and there are no players joined yet' do
        it 'return 3 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 6,
            '_metadata' => {
              '_players' => [],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(3)
        end
      end

      context 'and there is 1 player joined' do
        it 'return 3 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 6,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(3)
        end
      end

      context 'and there are 2 players joined yet' do
        it 'return 3 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 6,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_two_id', 
                  'name' => 'player_two',
                  'turn' => 1,
                  'cards' => [
                    { 'id' => 7, 'name' => 'card_name' },
                    { 'id' => 8, 'name' => 'card_name' },
                    { 'id' => 9, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(3)
        end
      end

      context 'and there are 3 players joined yet' do
        it 'return 3 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 6,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' },
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_two_id', 
                  'name' => 'player_two',
                  'turn' => 1,
                  'cards' => [
                    { 'id' => 7, 'name' => 'card_name' },
                    { 'id' => 8, 'name' => 'card_name' },
                    { 'id' => 9, 'name' => 'card_name' },
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_three_id', 
                  'name' => 'player_three',
                  'turn' => 2,
                  'cards' => [
                    { 'id' => 10, 'name' => 'card_name' },
                    { 'id' => 11, 'name' => 'card_name' },
                    { 'id' => 12, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(3)
        end
      end

      context 'and there are 4 players joined yet' do
        it 'return 3 cards' do
          game = {
            'id' => 'existing_id',
            'num_players' => 6,
            '_metadata' => {
              '_players' => [
                { 
                  'id' => 'player_one_id', 
                  'name' => 'player_one',
                  'turn' => 0,
                  'cards' => [
                    { 'id' => 4, 'name' => 'card_name' },
                    { 'id' => 5, 'name' => 'card_name' },
                    { 'id' => 6, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_two_id', 
                  'name' => 'player_two',
                  'turn' => 1,
                  'cards' => [
                    { 'id' => 7, 'name' => 'card_name' },
                    { 'id' => 8, 'name' => 'card_name' },
                    { 'id' => 9, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_three_id', 
                  'name' => 'player_three',
                  'turn' => 2,
                  'cards' => [
                    { 'id' => 10, 'name' => 'card_name' },
                    { 'id' => 11, 'name' => 'card_name' },
                    { 'id' => 12, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                },
                { 
                  'id' => 'player_four_id', 
                  'name' => 'player_three',
                  'turn' => 2,
                  'cards' => [
                    { 'id' => 13, 'name' => 'card_name' },
                    { 'id' => 14, 'name' => 'card_name' },
                    { 'id' => 15, 'name' => 'card_name' }
                  ], 
                  'playing' => true
                }
              ],
              '_solution' => {
                '_murderer' => { 'id' => 1, 'name' => 'card_name' },
                '_weapon' => { 'id' => 2, 'name' => 'card_name' },
                '_room' => { 'id' => 3, 'name' => 'card_name' }
              }
            }
          }
          response = described_class.get_cards_for_player_by(game)

          expect(response.size).to eq(3)
        end
      end
    end
  end

  describe '.validate!' do
    context 'when invalid names are provided for the card' do
      it 'raises an error' do
        expect{
          described_class.validate!([{'id' => 0, 'name' => 'Invalid Name'}])
        }.to raise_error('The provided card 0 does not have a valid name')
      end
    end

    context 'when not one of each type has been provided' do
      it 'raises an error' do
        expect{
          described_class.validate!(murderers_cards.sample(3))
        }.to raise_error('Weapon card must be provided in the second position')
      end
    end

    context 'when names and one card of each type has been prrovided correctly' do
      it 'do nothing' do
        expect{described_class.validate!([
          murderers_cards.first,
          weapons_cards.first,
          rooms_cards.first
        ])}.to_not raise_error
      end
    end
  end
end