require "spec_helper"

describe Endpoints::Databases do
  include Rack::Test::Methods

  def app
    Endpoints::Databases
  end

  describe "GET /databases" do
    it "succeeds" do
      authorize 'user', Fernet.generate(Config.pgperf_auth_secret, 'user')
      get "/databases"
      last_response.status.should eq(200)
    end

    it "fails without auth" do
      get "/databases"
      last_response.status.should eq(401)
    end
  end
end
