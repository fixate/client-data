module Dummy
	class FooBuilder < ClientData::Builder
		class << self; attr_accessor :return; end

		def build
			self.class.return || {}
		end
	end
end
