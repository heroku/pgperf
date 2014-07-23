require "spec_helper"

describe Endpoints::Databases do
  include Committee::Test::Methods
  include Rack::Test::Methods

  def app
    Routes
  end

  let(:database) do
    Fabricate(:database)
  end

  before do
    authorize nil, Fernet.generate(Config.pgperf_auth_secret, 'pgperf')
  end

  it "POST /databases" do
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

  it "PATCH /databases/:id" do
    header "Content-Type", "application/json"
    data = JSON.generate({
      admin_url: "postgres://admin@localhost/new",
      resource_url: "postgres://user@localhost/new"
    })
    patch "/databases/#{database.uuid}", data
    expect(last_response.status).to eq(200)
  end

  it "DELETE /databases/:id" do
    delete "/databases/#{database.uuid}"
    expect(last_response.status).to eq(200)
  end
end
