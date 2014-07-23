Sequel.migration do
  change do
    create_table(:testset) do
      serial :set, primary_key: true
      text :info, unique: true, null: false
      text :testdb, null: false
      text :testuser, null: false
      text :testhost, null: false
      text :testport, null: false
      text :settings
      foreign_key :database_uuid, :databases, type: :uuid
    end
  end
end