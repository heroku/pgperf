require "spec_helper"

describe Mediators::Databases::Updater do
  let(:database) do
    Fabricate(:database)
  end

  let(:updater) do
    Mediators::Databases::Updater.new(database: database,
      admin_url: admin_url, resource_url: resource_url)
  end

  let(:admin_url) do
    "postgres://admin@localhost/new"
  end

  let(:resource_url) do
    "postgres://user@localhost/new"
  end

  it "updates urls properly" do
    updater.call
    expect(database.resource_url).to eq(resource_url)
    expect(database.admin_url).to eq(admin_url)
  end
end