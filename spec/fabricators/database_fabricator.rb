Fabricator(:database, from: Database) do
  uuid { SecureRandom.uuid }
  shogun_name "shogun-perf"
  resource_url "postgres://user:password@localhost:5432/perf"
  admin_url "postgres://admin:password@localhost:5432/perf"
  heroku_id { sequence(:heroku_id) { |s| "resource#{s}@herokutest.com" } }
  plan "standard-ika"
  app "perf"
  email "purple@rain.com"
  attachment_name "HEROKU_POSTGRESQL_PERF_PURPLE"
  description "Make it better, or cheaper, or both"
end
