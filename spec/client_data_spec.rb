require 'spec_helper'

class DoubleController
	def self.before_filter(callback = nil, &block)
		@@before_callback = callback
		@@before_callback = block if block_given?
	end

	def do_callbacks
		send(@@before_callback) if @@before_callback
	end

	def params
		{controller: 'double'}
	end

	# Make public
	def provider
		super
	end
end

describe ClientData do
	before(:each) {
		DoubleController.__cs_builders = nil if DoubleController.respond_to?(:__cs_builders)
	}

	before {
		DoubleController.send(:include, described_class::Methods)
		ClientData.configure do |c|
			c.provider = double(:provider)
		end
	}

	subject {
		DoubleController.new
	}

	context '#Methods' do
		it 'calls the correct class methods when included' do
			expect(DoubleController).to receive(:before_filter)
				.with(:client_data_filter)

			expect(DoubleController).to receive(:extend)
				.with(described_class::Methods::ClassMethods)

			DoubleController.send(:include, described_class::Methods)

			expect(DoubleController).to respond_to(:__cs_builders)
		end

		it 'adds builders to __cs_builders' do
			DoubleController.client_data :dummy, :foo, :other_foo
			DoubleController.client_data :bar

			expect(DoubleController.__cs_builders).to eq(
				{ "DoubleController" => [:dummy, :foo, :other_foo, :bar] }
			)
		end

		it 'calls the builder classes when callbacks are fired' do
			Dummy::FooBuilder.return = { foo: 'bar' }
			Dummy::TestBuilder.return = { bar: 'baz', foo: 1 }

			expect(subject.provider).to receive(:set).with(:foo, Dummy::FooBuilder.return)
			expect(subject.provider).to receive(:set).with(:test, Dummy::TestBuilder.return)

			DoubleController.client_data :foo, :test
			subject.do_callbacks
		end
	end
end
