require_relative 'helpers'

module Endpoints
  # The base class for all Sinatra-based endpoints. Use sparingly.
  class Base < Sinatra::Base
    register Pliny::Extensions::Instruments
    register Sinatra::Namespace

    helpers Pliny::Helpers::Params

    set :dump_errors, false
    set :raise_errors, true
    set :show_exceptions, false

    configure :development do
      register Sinatra::Reloader
    end

    not_found do
      content_type :json
      status 404
      "{}"
    end

    helpers do
      def respond(response, status: nil)
        status(status) unless status.nil?
        JSON.generate(response)
      end
    end
  end
end
