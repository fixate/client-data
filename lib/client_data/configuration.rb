module ClientData
  class Configuration
    attr_accessor :builder_root, :provider, :builder_namespace

    def initialize
      default!
    end

    def default!
      self.builder_root = nil
      self.builder_namespace = ''
      self.provider = :gon if defined?(Gon)
    end
  end
end
