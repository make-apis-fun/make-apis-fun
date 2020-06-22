require 'sinatra'

module MakeApisFun
  module UnoApi
    module Controllers
      class Index < Sinatra::Base
        get '*' do
          "Welcome to the Uno API. Let's start creating a game. We encourage you to read the documentation about how to play."
        end
      end
    end
  end
end
