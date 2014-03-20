module Dummy
	class TestBuilder
		class << self; attr_accessor :return; end

		def initialize(controller)
			@controller = controller
		end

		def build
			self.class.return || {}
		end
	end
end
