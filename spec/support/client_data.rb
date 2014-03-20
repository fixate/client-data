ClientData.configure do |c|
	c.builder_root = File.expand_path('../builders/', __FILE__)
	c.builder_namespace = 'Dummy::'
end

ClientData.load_builders!
