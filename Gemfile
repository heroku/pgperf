source "https://rubygems.org"
ruby "2.1.2"

gem "platform-api"
gem "heroku-bouncer"
gem "hiredis"
gem "redis", ">= 2.2.0", :require => ["redis/connection/hiredis", "redis"]
gem "sidekiq"
gem "clockwork"

gem "multi_json"
gem "oj"
gem "pg"
gem "pliny", git: "https://github.com/interagent/pliny.git"
gem "puma"
gem "rack-ssl"
gem "rake"
gem "rollbar"
gem "sequel"
gem "sequel-paranoid"
gem "sequel_pg", require: "sequel"
gem "sinatra", require: "sinatra/base"
gem "sinatra-contrib", require: ["sinatra/namespace", "sinatra/reloader"]
gem "sinatra-router"
gem "sucker_punch"

group :development do
  gem "foreman"
end

group :test do
  gem "committee"
  gem "database_cleaner"
  gem "rack-test"
  gem "rr", require: false
  gem "rspec-core"
  gem "rspec-expectations"
end
