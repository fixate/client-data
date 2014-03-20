module ClientData
  class Builder
    attr_accessor :controller

    def initialize(controller)
      @controller = controller
    end
  end
end

