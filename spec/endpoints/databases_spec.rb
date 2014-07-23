require "spec_helper"

describe Endpoints::Databases do
  include Rack::Test::Methods

  def app
    Endpoints::Databases
  end

  let(:database) do
    Fabricate(:database)
  end

  describe "POST /databases" do
    it "creates a database" do
      header "Content-Type", "application/json"
      data = JSON.generate({
        resource_url: "postgres://user@postgres/db",
        admin_url: "postgres://admin@postgres/db",
        heroku_id: "resource123@herokutest.com",
        plan: "standard-ika",
        app: "pgperf",
        email: "dod@herokumanager.com",
        attachment_name: "HEROKU_POSTGRESQL_PERF_PURPLE",
        description: "Make it better, or cheaper, or both"
      })
      post "/databases", data
      expect(last_response.status).to eq(201)
    end
  end

  describe "PATCH /databases/:id" do
    it "updates a database" do
      header "Content-Type", "application/json"
      data = JSON.generate({
        admin_url: "postgres://admin@localhost/new",
        resource_url: "postgres://user@localhost/new"
      })
      patch "/databases/#{database.uuid}", data
      expect(last_response.status).to eq(200)
    end
  end

  describe "DELETE /databases/:id" do
    it "deletes a database by uuid" do
      delete "/databases/#{database.uuid}"
      expect(last_response.status).to eq(200)
    end
  end
end
