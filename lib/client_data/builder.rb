module ClientData
  class Builder
    attr_accessor :controller
    attr_reader :options

    def initialize(controller = nil, options = {})
      @controller = controller
      @options = options
    end

    def self.properties(*props)
      props.each do |m|
        property(m)
      end
    end

    def self.property(prop)
      define_method(prop) do
        if controller.respond_to?(prop)
          controller.send(prop)
        else
          controller.instance_variable_get(:"@#{prop}")
        end
      end
    end

    def self.builder_name
      self.name.split('::').last.chomp('Builder').underscore
    end
  end
end

