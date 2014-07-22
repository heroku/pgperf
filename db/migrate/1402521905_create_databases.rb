Sequel.migration do
  change do
    execute <<-SQL
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
    SQL
    create_table(:databases) do
      uuid         :uuid, default: Sequel.function(:uuid_generate_v4), primary_key: true
      timestamptz  :created_at, default: Sequel.function(:now), null: false
      timestamptz  :updated_at
      timestamptz  :deleted_at
      text         :shogun_name     , null: false
      text         :shogun_release
      text         :resource_url    , null: false
      text         :admin_url       , null: false
      text         :heroku_id       , null: false
      text         :plan            , null: false
      text         :app             , null: false
      text         :email           , null: false
      text         :attachment_name , null: false
      text         :description
    end
  end
end
