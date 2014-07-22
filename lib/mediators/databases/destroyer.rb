module Mediators::Databases
  class Destroyer < Mediators::Base
    def initialize(options={})
      @database = options[:database]
    end

    def call
      @database.destroy
    end
  end
end
