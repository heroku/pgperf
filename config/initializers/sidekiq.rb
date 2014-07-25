require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'sidekiq' }
end

Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'sidekiq' }
end

Sidekiq.logger.formatter = proc do |severity, datetime, progname, msg|
  "#{msg}\n"
end