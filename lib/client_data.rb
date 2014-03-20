require 'active_support/core_ext/hash'

require 'client_data/configuration'
require 'client_data/methods'
require 'client_data/builder'
require 'client_data/adapters'

require 'client_data/railtie' if defined?(Rails)

module ClientData
  class Error < StandardError; end

  @@configuration = nil

  def self.configure
    yield configuration
  end

  def self.configuration
    @@configuration ||= Configuration.new
  end

  def self.load_builders!
    raise Error, 'Client data builder_root is not set.' if configuration.builder_root.nil?

    Dir[File.join(configuration.builder_root, '**/*_builder.rb')].each do |f|
      load f
    end
  end
end
