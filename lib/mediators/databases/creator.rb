module Mediators::Databases
  class Creator < Mediators::Base
    def initialize(args={})
      @shogun_release  = args[:shogun_release]
      @resource_url    = args[:resource_url]
      @admin_url       = args[:admin_url]
      @heroku_id       = args[:heroku_id]
      @plan            = args[:plan]
      @app             = args[:app]
      @email           = args[:email]
      @attachment_name = args[:attachment_name]
      @description     = args[:description]
    end

    def call
      check_admin_url_format!
      check_resource_url_format!

      database = find_or_create_database
      database.enqueue_benchmark
      database
    end

    private
    def check_admin_url_format!
      return if @admin_url =~ /^postgres:\/\//

      raise ArgumentError, "admin_url is not a postgres uri"
    end

    def check_resource_url_format!
      return if @resource_url =~ /^postgres:\/\//

      raise ArgumentError, "resource_url is not a postgres uri"
    end

    def shogun_name
      if m = @attachment_name.match(/\AHEROKU_POSTGRESQL_([^_]*)_[^\Z]*\Z/)
        "shogun-#{m[1].downcase}"
      else
        "shogun"
      end
    end

    def find_or_create_database
      Database.find_or_create(heroku_id: @heroku_id) do |db|
        db.shogun_name = shogun_name
        db.shogun_release = @shogun_release
        db.resource_url = @resource_url
        db.admin_url = @admin_url
        db.plan = @plan,
        db.app = @app,
        db.email = @email,
        db.attachment_name = @attachment_name,
        db.description = @description
      end
    end
  end
end
