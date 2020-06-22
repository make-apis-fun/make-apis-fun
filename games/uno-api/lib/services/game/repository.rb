require 'redis'

module MakeApisFun
  module UnoApi
    module Services
      class GameService
        class Repository
          class << self
            def get(id)
              redis_client.get(id)
            end

            def save(id, payload, opt={ ex: 300 })
              redis_client.set(id, payload.to_json, opt)
            end

            private

            def redis_client
              @client ||= Redis.new(host: 'redis', port: 6380)
            end
          end
        end
      end
    end
  end
end