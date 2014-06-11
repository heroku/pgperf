Routes = Rack::Builder.new do
  use Pliny::Middleware::RescueErrors unless Config.rack_env == "development"
  use Honeybadger::Rack
  use Pliny::Middleware::CORS
  use Pliny::Middleware::RequestID
  use Pliny::Middleware::RequestStore, store: Pliny::RequestStore
  use Pliny::Middleware::Timeout, timeout: 45
  use Rack::Deflater
  use Rack::MethodOverride
  use Rack::SSL if Config.rack_env == "production"

  use Rack::Session::Cookie, key: 'rack.session',
    secret: Config.session_secret

  use Heroku::Bouncer, oauth: { id: Config.heroku_oauth_id, secret: Config.heroku_oauth_secret },
    secret: Config.heroku_bouncer_secret,
    herokai_only: true,
    allow_anonymous: lambda { |req| !/\A\/sidekiq/.match(req.fullpath) }

  map '/sidekiq' do
    run Sidekiq::Web
  end

  use Pliny::Router do
    # mount all endpoints here
  end

  # root app; but will also handle some defaults like 404
  run Endpoints::Root
end
