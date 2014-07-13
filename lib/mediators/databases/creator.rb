module Mediators::Databases
  class Creator < Mediators::Base
    def initialize(args={})
      @shogun_name     = args[:shogun_name]
      @shogun_release  = args[:shogun_release]
      @resource_url    = args[:resource_url]
      @admin_url       = args[:admin_url]
      @heroku_id       = args[:heroku_id]
      @plan            = args[:plan]
      @app             = args[:app]
      @email           = args[:email]
      @attachment_name = args[:attachment_name]
      @db_created_at   = args[:db_created_at]
      @db_details      = args[:db_details]
      @tests           = args[:tests]
    end

    def call
      check_admin_url_format!
      check_resource_url_format!

      create_system
      enqueue_benchmark_create if @tests
    end

    private

    def check_admin_url_format!
      return if @admin_url =~ /^postgres:\/\//

      raise ArgumentError "admin_url is not a postgres uri"
    end

    def check_resource_url_format!
      return if @resource_url =~ /^postgres:\/\//

      raise ArgumentError "resource_url is not a postgres uri"
    end

    def create_system
      self.system = System.new(
        shogun_name: @shogun_name,
        shogun_release: @shogun_release,
        resource_url: @resource_url,
        admin_url: @admin_url,
        heroku_id: @heroku_id,
        plan: @plan,
        app_name: @app,
        email: @email,
        attachment_name: @attachment_name,
        db_created_at: @db_created_at,
        db_details: @db_details
      )

  end
end
