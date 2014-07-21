module Endpoints
  class Databases < Base
    namespace "/databases" do
      before do
        content_type :json, charset: 'utf-8'
        unless request.request_method == 'OPTIONS'
          authenticate!
        end
      end

      get do
        "[]"
      end

      post do
        status 201
        "{}"
      end

      get "/:id" do
        "{}"
      end

      patch "/:id" do |id|
        "{}"
      end

      delete "/:id" do |id|
        "{}"
      end

      private
      def authenticate!
        auth = Rack::Auth::Basic::Request.new(request.env)
        throw(:halt, [401, "Not Authorized\n"]) unless auth.provided? && auth.basic? && auth.credentials
        token = auth.credentials.last
        verifier = Fernet.verifier(Config.pgperf_auth_secret, token)
        unless verifier.valid?
          throw(:halt, [401, "Not authorized\n"])
        end
      end

    end
  end
end
