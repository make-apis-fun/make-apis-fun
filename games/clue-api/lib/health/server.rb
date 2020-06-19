require 'sinatra'
require 'socket'
require 'json'

module MakeApisFun
  module ClueApi
    module Health
      class Controller < Sinatra::Base
        get '/' do
          response = {
            node_name: node_name,
            services_health: {
              application: application_health
            }
          }

          json(response)
        end

        def application_health
          'ok'
        end

        def node_name
          Socket.gethostname
        end

        def json(something)
          JSON.dump(something)
        end
      end

      Server = Rack::Builder.app do
        map '/' do
          run Health::Controller.new
        end
      end
    end
  end
end

