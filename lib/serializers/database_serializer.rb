module Serializers
  class Database < Base
    structure(:default) do |database|
      {
        uuid: database.uuid
      }
    end
  end
end
