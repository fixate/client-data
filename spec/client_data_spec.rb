require 'spec_helper'

class DoubleController
  attr_accessor :action_name

  def initialize(*args)
    @action_name = 'dummy'
  end

	def self.before_render(callback = nil, &block)
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

	subject { DoubleController.new }

	context '#Methods' do
		it 'calls the correct class methods when included' do
			expect(DoubleController).to receive(:before_render)
				.with(:client_data_builder_filter)

			expect(DoubleController).to receive(:extend)
				.with(described_class::Methods::ClassMethods)

			DoubleController.send(:include, described_class::Methods)

			expect(DoubleController).to respond_to(:__cs_builders)
		end

		it 'adds builders to __cs_builders' do
			DoubleController.client_data :dummy, :foo, :other_foo
			DoubleController.client_data :bar

			expect(DoubleController.__cs_builders).to eq(
				[:dummy, :foo, :other_foo, :bar]
			)
		end

    it 'conditionally builds' do
      DoubleController.client_data :dummy, if: -> { false }

      expect(subject.provider).to_not receive(:set)
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

  context 'Inherited controller' do
    before(:each) do
      class BaseController
        include ClientData::Methods
        client_data :dummy
      end
      class InheritedController < BaseController
        client_data :foo
      end
    end

    subject { InheritedController.new }

    it 'runs builders of parent class' do
      expect(subject.send(:config_keys).sort).to eq(
        [:dummy, :foo]
      )
    end
  end
end
