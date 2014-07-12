Sequel.migration do
  change do
    create_table(:systems) do
      uuid         :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at
      timestamptz  :deleted_at
      text         :credentials
      json         :details
    end
  end
end
