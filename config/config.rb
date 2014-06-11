require "pliny/config_helpers"

# Access all config keys like the following:
#
#     Config.database_url
#
# Each accessor corresponds directly to an ENV key, which has the same name
# except upcased, i.e. `DATABASE_URL`.
#
# Note that *all* keys will come out as strings even if the override was a
# different type. Make sure to typecast any values that need to be something
# else (i.e. `.to_i`).
module Config
  extend Pliny::ConfigHelpers

  # Mandatory -- exception is raised for these variables when missing.
  mandatory \
    :session_secret,
    :heroku_oauth_id,
    :heroku_oauth_secret,
    :heroku_bouncer_secret,
    :heroku_app_name,
    :heroku_platform_api_token,
    :database_url

  # Optional -- value is returned or `nil` if it wasn't present.
  optional \
    :redis_url,
    :placeholder

  # Override -- value is returned or the set default. Remember to typecast.
  override \
    db_pool:          5,
    port:             5000,
    puma_max_threads: 16,
    puma_min_threads: 1,
    puma_workers:     3,
    rack_env:         "development"
end
