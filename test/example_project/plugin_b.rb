
module PluginB

  def self.define_config(c)
    c.float :server_precision, 'spline calculation precision'
  end

  def self.add_services_to_application(app, config)
    app.add AnimalServer
  end

  class AnimalServer
  end
end
