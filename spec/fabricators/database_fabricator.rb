Fabricator(:database, from: Database) do
  uuid { SecureRandom.uuid }
  shogun_name "shogun-perf"
  resource_url "postgres://user:password@localhost/perf"
  admin_url "postgres://admin:password@localhost/perf"
  heroku_id { sequence(:heroku_id) { |s| "resource#{s}@herokutest.com" } }
  plan "standard-ika"
  app "perf"
  email "purple@rain.com"
  attachment_name "HEROKU_POSTGRESQL_PURPLE"
  db_created_at Time.now
end