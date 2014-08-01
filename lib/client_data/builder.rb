module ClientData
  class Builder
    attr_accessor :controller

    def initialize(controller = nil)
      @controller = controller
    end

    def self.properties(*props)
      props.each do |m|
        property m
      end
    end

    def self.property(prop)
      define_method(m) do
        if controller.respond_to?(m)
          controller.send(m)
        else
          controller.instance_variable_get(:"@#{m}")
        end
      end
    end
  end
end

