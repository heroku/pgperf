module Endpoints
  module Serializer
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def serialize_with(klass)
        @serializer_class = klass
        @serializers = {}
      end

      def serializer(flavor)
        @serializers[flavor] ||= @serializer_class.new(flavor)
      end
    end

    def serialize(result, flavor: :default)
      unless result.nil?
        self.class.serializer(flavor).serialize(result)
      end
    end
  end
end