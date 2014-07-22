require "spec_helper"

describe Mediators::Databases::Destroyer do
  before do
    @database = Fabricate(:database)
    @destroyer = Mediators::Databases::Destroyer.new(database: @database)
  end

  it "marks the database as deleted" do
    @database.destroy
    expect(@database.deleted?).to eq(true)
  end
end