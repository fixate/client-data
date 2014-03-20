require 'rails'

module Rails
  module ClientData
    class Railtie < ::Rails::Railtie
      initializer :include_client_data do |app|
        ActiveSupport.on_load(:action_controller) do
          ActionController::Base.send(:include, ClientData::Methods)
        end

        ::ClientData.configure do |c|
          c.builder_root = "#{app.root}/app/js_builders"
        end
      end

      config.after_initialize do
        ::ClientData.load_builders!
      end
    end
  end
end

