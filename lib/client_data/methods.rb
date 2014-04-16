module ClientData
  module Methods
    extend ActiveSupport::Concern

    included do
      send(:include, ClientData::BeforeRender) unless respond_to?(:before_render)
      before_render :client_data_builder_filter

      class_eval %(
        class << self; attr_accessor :__cs_builders; end
      )
    end

    module ClassMethods
      def client_data(*build_keys)
        opts = build_keys.extract_options!
        self.__cs_builders ||= {}
        build_keys.each do |key|
          self.__cs_builders[key] = opts
        end
      end
    end

    def builders
      @builders ||= begin
        builders_hash = {}
        builder_options_hash.keys.each do |key|
          builders_hash[key] = create_builder(key)
        end
        builders_hash
      end
    end

    protected

    def client_data_builder_filter
      builders.each do |key, builder|
        provider.set(key, builder.build) if should_build_for?(key)
      end
    end

    def should_build_for?(key)
      options = builder_options_hash[key] || {}
      action = self.action_name.to_sym
      only = options[:only]
      if only.nil?
        true
      else
        if only.is_a?(Symbol)
          only = [only]
        end
        only.include?(action)
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
      @_builder_provider ||= Adapters.factory(self)
    end

    def builder_options_hash
      @_builder_options_hash ||= begin
        keys = {}
        klass = self.class
        loop do
          keys.merge!(klass.__cs_builders || {}) if klass.respond_to?(:__cs_builders)
          break keys unless klass.respond_to?(:superclass) && klass = klass.superclass
        end
      end
    end
  end
end
