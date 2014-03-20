require 'spec_helper'

describe ClientData::Adapters do
	def set_provider(provider)
		ClientData.configuration.provider = provider
	end

	let(:controller) { double(:controller) }

	it 'returns provider from a class' do
		provider = double(:provider)
		set_provider(provider)

		expect(described_class.factory(controller)).to be(provider)
	end

	it 'returns provider adapter from a symbol or string' do
		set_provider(:gon)
		expect(described_class.factory(controller)).to be_kind_of(described_class::GonAdapter)

		set_provider('Gon')
		expect(described_class.factory(controller)).to be_kind_of(described_class::GonAdapter)
	end
end
