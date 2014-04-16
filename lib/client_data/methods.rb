module ClientData
  module Methods
    extend ActiveSupport::Concern

    included do
      send(:include, ClientData::BeforeRender) unless respond_to?(:before_render)
      before_render :client_data_filter

      class_eval %(
        class << self; attr_accessor :__cs_builders; end
      )
    end

    module ClassMethods
      def client_data(*builders)
        self.__cs_builders ||= []
        self.__cs_builders.concat(builders).uniq!
      end
    end

    def builders
      @builders ||= begin
        builders_hash = {}
        config_keys.each do |key|
          builders_hash[key] = create_builder(key)
        end
        builders_hash
      end
    end

    protected

    def client_data_filter
      config_keys.each do |key|
        provider.set(key, builders[key].build)
      end
    end

    def create_builder(key)
      begin
        klass = "#{builder_namespace}#{key.to_s.capitalize}Builder"
        klass = klass.constantize
      rescue ::NameError => e
        raise ClientData::Error, "Unable to find constant #{klass}, " \
          "has ClientData.load_resources! been called? " \
          "Error: #{e.message}"
      end

      klass.new.tap { |o| o.controller = self }
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
