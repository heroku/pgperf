require "spec_helper"

describe Endpoints::Databases do
  include Rack::Test::Methods

  def app
    Endpoints::Databases
  end

  before do
    @database = Fabricate(:database)
  end

  describe "GET /databases" do
    it "list existing databases" do
      get "/databases"
      last_response.status.should eq(200)
    end
  end
end
