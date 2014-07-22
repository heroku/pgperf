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
      expect(last_response.status).to eq(200)
    end
  end

  describe "GET /databases/:id" do
    it "list existing databases" do
      get "/databases/#{@database.uuid}"
      expect(last_response.status).to eq(200)
    end
  end

  describe "POST /databases/:id" do
    it "creates a database" do
      header "Content-Type", "application/json"
      data = JSON.generate({
        shogun_name: "shogun-perf"
      })
      post "/databases", data
      expect(last_response.status).to eq(201)
    end
  end

  describe "DELETE /databases/:id" do
    it "deletes a database by uuid" do
      delete "/databases/#{@database.uuid}"
      expect(last_response.status).to eq(200)
    end
  end
end
