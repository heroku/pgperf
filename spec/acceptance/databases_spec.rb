require "spec_helper"

describe Endpoints::Databases do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  it "GET /databases without auth" do
    get "/databases"
    last_response.status.should eq(401)
  end

  it "GET /databases" do
    authorize 'user', Fernet.generate(Config.pgperf_auth_secret, 'user')
    get "/databases"
    last_response.status.should eq(200)
    last_response.body.should eq("[]")
  end

  it "POST /databases/:id" do
    authorize 'user', Fernet.generate(Config.pgperf_auth_secret, 'user')
    post "/databases"
    last_response.status.should eq(201)
    last_response.body.should eq("{}")
  end

  it "GET /databases/:id" do
    authorize 'user', Fernet.generate(Config.pgperf_auth_secret, 'user')
    get "/databases/123"
    last_response.status.should eq(200)
    last_response.body.should eq("{}")
  end

  it "PATCH /databases/:id" do
    authorize 'user', Fernet.generate(Config.pgperf_auth_secret, 'user')
    patch "/databases/123"
    last_response.status.should eq(200)
    last_response.body.should eq("{}")
  end

  it "DELETE /databases/:id" do
    authorize 'user', Fernet.generate(Config.pgperf_auth_secret, 'user')
    delete "/databases/123"
    last_response.status.should eq(200)
    last_response.body.should eq("{}")
  end
end
