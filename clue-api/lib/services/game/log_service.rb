require_relative 'repository'

module MakeApisFun
  module ClueApi
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

            def log_hypotheshis(game:, requester:, cards:, player_with_card:)
              question_msg = "#{requester['name']} says: I think the murderer was #{cards[0]['name']}, using the #{cards[1]['name']} in the #{cards[2]['name']}"
              log_for(game, question_msg)

              answer_msg = "No one gives a card to #{requester['name']}" unless player_with_card
              answer_msg = "#{player_with_card[:player][:name]} gives a card to #{requester['name']}" if player_with_card
              log_for(game, answer_msg)

              game
            end

            def log_resolve(game:, player:, cards:, valid:)
              question_msg = "#{player['name']} tries to solve the murder: I'm sure the murderer was #{cards[0]['name']}, using the #{cards[1]['name']} in the #{cards[2]['name']}"
              log_for(game, question_msg)

              answer_msg = "The solution proposed by #{player['name']} is not valid. #{player['name']} cannot continue playing, but the cards does." unless valid
              answer_msg = "Congratulations, #{player['name']} is the winner of this game!" if valid
              log_for(game, answer_msg)

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