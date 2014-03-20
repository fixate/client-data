module ClientData
  module Adapters
    class GonAdapter
      def initialize(controller)
        @controller = controller
      end

      def set(name, value)
        @controller.gon.send("#{name}=", value)
      end
    end
  end
end
