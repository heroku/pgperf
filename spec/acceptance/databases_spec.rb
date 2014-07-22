require "spec_helper"

describe Endpoints::Databases do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  before do
    @database = Fabricate(:database)
    authorize nil, Fernet.generate(Config.pgperf_auth_secret, 'pgperf')
  end

  it "GET /databases" do
    get "/databases"
    last_response.status.should eq(200)
  end

  it "POST /databases/:id" do
    post "/databases"
    last_response.status.should eq(201)
  end

  it "GET /databases/:id" do
    get "/databases/#{@database.uuid}"
    last_response.status.should eq(200)
  end

  it "PATCH /databases/:id" do
    patch "/databases/#{@database.uuid}"
    last_response.status.should eq(200)
  end

  it "DELETE /databases/:id" do
    delete "/databases/#{@database.uuid}"
    last_response.status.should eq(200)
  end
end
