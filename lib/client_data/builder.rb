module ClientData
  class Builder
    attr_accessor :controller

    def initialize(controller = nil)
      @controller = controller
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
  end
end

