require "spec_helper"

describe Endpoints::Databases do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  it "GET /databases" do
    get "/databases"
    last_response.status.should eq(200)
    last_response.body.should eq("[]")
  end

  it "POST /databases/:id" do
    post "/databases"
    last_response.status.should eq(201)
    last_response.body.should eq("{}")
  end

  it "GET /databases/:id" do
    get "/databases/123"
    last_response.status.should eq(200)
    last_response.body.should eq("{}")
  end

  it "PATCH /databases/:id" do
    patch "/databases/123"
    last_response.status.should eq(200)
    last_response.body.should eq("{}")
  end

  it "DELETE /databases/:id" do
    delete "/databases/123"
    last_response.status.should eq(200)
    last_response.body.should eq("{}")
  end
end
