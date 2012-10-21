require 'plugin_fu'
require 'climate'

module Project

  def run
    PluginFu.configure!(:logger => $stdout)

    loader = PluginFu.create_loader(['PluginA', 'PluginB'])

    loader.build_application()
  end

  extend self
end

#Project.run

extend Climate::Script
description 'Example project for test cases'

opt :config, 'supply a config value', :multi => true, :type => :string
opt :plugin, 'enable a plugin', :multi => true, :default => %w(PluginA PluginB)

opt :dump_plugins, 'dump out plugin info'
opt :validate_config, 'validate given config'
opt :config_help, 'dump out help for config options in the plugins'


def build_config
  Hash[*options[:config].map {|given| given.split('=') }.flatten]
end

def run
  PluginFu.configure!(:logger => $stdout)

  if options[:dump_plugins]
    PluginFu.plugins.each do |plugin|
      puts [plugin.plugin_fu_file, plugin.module_name].join(',')
    end
  end

  plugins = options[:plugin]
  loader = PluginFu.create_loader(plugins)

  config = build_config

  if options[:config_help]
    loader.config_meta.map do |plugin, config_defns|
      config_defns.each do |config_defn|
        puts [plugin.module_name, config_defn.key, config_defn.description].join(' - ')
      end
    end
  end

  if options[:validate_config]
    loader.validate_config(config)
  end
end
