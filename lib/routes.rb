require 'sidekiq/web'
require 'rack/fernet'

Routes = Rack::Builder.new do
  use Pliny::Middleware::RescueErrors, raise: Config.raise_errors?
  use Pliny::Middleware::CORS
  use Pliny::Middleware::RequestID
  use Pliny::Middleware::RequestStore, store: Pliny::RequestStore
  use Pliny::Middleware::Timeout, timeout: Config.timeout.to_i if Config.timeout.to_i > 0
  use Pliny::Middleware::Versioning,
      default: Config.versioning_default,
      app_name: Config.versioning_app_name if Config.versioning?
  use Rack::Deflater
  use Rack::MethodOverride
  use Rack::SSL if Config.force_ssl?

  use Rack::Session::Cookie, key: 'rack.session',
    secret: Config.session_secret

  use Heroku::Bouncer, oauth: { id: Config.heroku_oauth_id, secret: Config.heroku_oauth_secret },
    secret: Config.heroku_bouncer_secret,
    herokai_only: true,
    allow_anonymous: lambda { |req| !/\A\/sidekiq/.match(req.fullpath) }

  map '/sidekiq' do
    run Sidekiq::Web
  end

  use Rack::Auth::Fernet, Config.shogun_shared_key
  use Rack::Fernet, Config.shogun_shared_key

  use Pliny::Router do
    mount Endpoints::Databases
  end

  # root app; but will also handle some defaults like 404
  run Endpoints::Root
end
