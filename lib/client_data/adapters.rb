module ClientData
  module Adapters
    def self.factory(controller)
      provider = ClientData.configuration.provider
      return provider unless provider.is_a?(Symbol) || provider.is_a?(String)
      require "client_data/adapters/#{provider.downcase}_adapter"
      "ClientData::Adapters::#{provider.to_s.capitalize}Adapter".constantize.new(controller)
    end
  end
end
