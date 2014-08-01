Sequel.migration do
  change do
    alter_table(:testset) do
      add_foreign_key :database_uuid, :databases, type: :uuid
    end
  end
end
