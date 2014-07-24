source "https://rubygems.org"
ruby "2.1.2"

gem "multi_json"
gem "oj"
gem "pg"
gem "pliny"
gem "pry"
gem "pry-doc"
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

gem "platform-api"
gem "heroku-bouncer"
gem "hiredis"
gem "redis", ">= 2.2.0", :require => ["redis/connection/hiredis", "redis"]
gem "sidekiq"
gem "clockwork"
gem "attr_secure", git: "https://github.com/neilmiddleton/attr_secure", branch: "fernet_2_0"
gem "fernet"
gem "fernet-rack", "0.5"

group :development, :test do
  gem "pry-byebug"
end

group :development do
  gem "foreman"
end

group :test do
  gem "committee"
  gem "fabrication"
  gem "database_cleaner"
  gem "rack-test"
  gem "rspec"
  gem "codeclimate-test-reporter", require: nil
end
