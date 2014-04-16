module ClientData
  class Builder
    attr_accessor :controller

    def initialize(controller = nil)
      @controller = controller
    end

    def self.properties(*props)
      props.each do |m|
        define_method(m) { controller.instance_variable_get(:"@#{m}") }
      end
    end
  end
end

