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
          resource_url:  body_params["resource_url"],
          admin_url:  body_params["admin_url"],
          heroku_id: body_params["heroku_id"],
          plan: body_params["plan"],
          app: body_params["app"],
          email: body_params["email"],
          attachment_name: body_params["attachment_name"],
          description: body_params["description"]
        })
        respond serialize(database), status: 201
      end

      get "/:id" do
        respond serialize(@database)
      end

      patch "/:id" do
        @database = Mediators::Databases::Updater.run({
          database: @database,
          resource_url: body_params["resource_url"],
          admin_url: body_params["admin_url"],
        })
        respond serialize(@database)
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
