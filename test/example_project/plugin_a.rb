module PluginA

  def self.define_config(c)
    c.string  :name_of_cat, 'The name of the cat', :default => 'jess'
    c.integer :age_of_cat,  'How old is the cat',  :default => 12
  end

  def self.add_services_to_application(app, config)
    if config[:name_of_cat] != 'jess'
      app.add CatStroker, :features => [:stroker]
    end
  end

  class CatStroker ; end

end
