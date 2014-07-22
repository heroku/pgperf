module Endpoints
  class Databases < Base
    include Serializer

    serialize_with Serializers::Database

    namespace "/databases" do
      before do
        content_type :json, charset: 'utf-8'
      end

      before "/:id" do |id|
        @database = Database[id] || raise(Pliny::Errors::NotFound)
      end

      get do
        databases = Database.all
        respond serialize(databases)
      end

      post do
        status 201
        "{}"
      end

      get "/:id" do
        respond serialize(@database)
      end

      patch "/:id" do |id|
        "{}"
      end

      delete "/:id" do
        respond serialize(@database)
      end
    end
  end
end
