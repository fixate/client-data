module ClientData
  class Builder
    attr_accessor :controller

    def initialize(controller = nil)
      @controller = controller
    end
  end
end

