require "spec_helper"

describe Mediators::Databases::Destroyer do
  let(:database) do
    Fabricate(:database)
  end

  let(:destroyer) do
    Mediators::Databases::Destroyer.new(database: database)
  end

  it "marks the database as deleted" do
    destroyer.call
    expect(database.deleted?).to eq(true)
  end
end