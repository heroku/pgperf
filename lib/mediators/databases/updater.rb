module Mediators::Databases
  class Updater < Mediators::Base
    def initialize(options={})
      @database = options[:database]
      @resource_url = options[:resource_url]
      @admin_url = options[:admin_url]
    end

    def call
      @database.update(resource_url: @resource_url,
        admin_url: @admin_url)
      @database
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
  end
end
