require "spec_helper"

describe Endpoints::Databases do
  include Rack::Test::Methods

  def app
    Endpoints::Databases  end

  describe "GET /databases" do
    it "succeeds" do
      get "/databases"
      last_response.status.should eq(200)
    end
  end
end
