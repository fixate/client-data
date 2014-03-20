module ClientData
  module Methods
    def self.included(klass)
      klass.send(:before_filter, :client_data_filter) if klass.respond_to?(:before_filter)
      klass.class_eval %(
          class << self; attr_accessor :__cs_builders; end
      )
      klass.send(:include, InstanceMethods)
      klass.send(:extend, ClassMethods)
    end

    module ClassMethods
      def client_data(*configs)
        self.__cs_builders ||= []
        self.__cs_builders.concat(configs).uniq!
      end
    end

    module InstanceMethods
      def client_data_filter
        config_keys.each do |key|
          begin
            klass = "#{builder_namespace}#{key.to_s.capitalize}Builder"
            klass = klass.constantize
          rescue ::NameError => e
            raise ClientData::Error, "Unable to find constant #{klass}, " \
              "has ClientData.load_resources! been called? " \
              "Error: #{e.message}"
          end

          data = build_data(klass)
          provider.set(key, data)
        end
      end

      protected

      def build_data(klass)
        arity = klass.instance_method(:initialize).arity
        builder = arity == 0 ?  klass.new : klass.new(self)
        builder.build
      end

      def builder_namespace
        ClientData.configuration.builder_namespace
      end

      def provider
        @provider ||= Adapters.factory(self)
      end

      def config_keys
        @keys ||= begin
          keys = []
          klass = self.class
          loop do
            keys += klass.__cs_builders || [] if klass.respond_to?(:__cs_builders)
            break keys unless klass.respond_to?(:superclass) && klass = klass.superclass
          end
        end
      end
    end
  end
end
