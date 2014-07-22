module Endpoints
  class Databases < Base
    include Serializer

    serialize_with Serializers::Database

    namespace "/databases" do
      before do
        content_type :json, charset: 'utf-8'
      end

      before "/:id" do |id|
        @database = Database.present.first(uuid: id) || raise(Pliny::Errors::NotFound)
      end

      get do
        databases = Database.present.all
        respond serialize(databases)
      end

      post do
        database = Mediators::Databases::Creator.run({
          shogun_name: body_params["shogun_name"],
        })
        respond serialize(database), status: 201
      end

      get "/:id" do
        respond serialize(@database)
      end

      patch "/:id" do |id|
        "{}"
      end

      delete "/:id" do
        Mediators::Databases::Destroyer.run({
          database: @database
        })
        respond serialize(@database)
      end
    end
  end
end
