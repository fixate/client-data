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
        options = build_keys.extract_options!
        self.__cs_builders ||= {}
        build_keys.each do |key|
          self.__cs_builders[key] = options
        end
      end
    end

    def builders
      @builders ||= begin
        builders_hash = {}
        builder_options_hash.each do |key, options|
          name = options[:as].nil? ? key : options[:as]
          builders_hash[name] = create_builder(key)
        end
        builders_hash
      end
    end

    protected

    def client_data_builder_filter
      builder_options_hash.each do |key, options|
        name = options[:as].nil? ? key : options[:as]
        builder = builders[name]
        provider.set(name.to_s, builder.build) if should_build_for?(key)
      end
    end

    def condition_satisfied?(options)
      if cond = options[:if]
        if cond.respond_to?(:call)
          cond.call(self)
        else
          cond
        end
      else
        true
      end
    end

    def should_build_for?(key)
      options = builder_options_hash[key] || {}
      return false unless condition_satisfied?(options)
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
        klass = key
        if klass.is_a?(Symbol) || klass.is_a?(String)
          klass = "#{builder_namespace}#{key.to_s.camelize}Builder"
          klass = klass.constantize
        end
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
