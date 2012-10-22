require 'yaml'
require 'bigdecimal'

module PluginFu

  module ClassMethods

    # One-time set up method to configure how the global plugin-fu singleton
    # works.  Can only be called once, as it will call Kernel.require and mess
    # with $LOAD_PATH
    def configure!(config)
      @logger = config[:logger]
      find_plugins
    end

    # Return a list of plugin objects that have been sensed from the load path
    def plugins ; @plugins ; end

    # Create a new Loader object that builds applications with the given plugins
    def create_loader(enabled_plugins)
      enabled_plugins = enabled_plugins.map do |p|
        if p.is_a?(Plugin)
          p
        else
          plugins.find {|plugin| p == plugin.module_name }
        end
      end

      enabled_plugins.each do |p|
        log("activating #{p}")
        p.activate!
      end

      log("enabled_plugins: #{enabled_plugins.inspect}")

      Loader.new(enabled_plugins)
    end

    private

    def find_plugins
      fu_files = $LOAD_PATH.map do |entry|
        Dir[File.join(entry, '*.plugin_fu')]
      end.flatten

      @plugins = fu_files.map do |fu_file|
        plugin_data = YAML.load_file(fu_file)
        begin
          Plugin.new(plugin_data, fu_file)
        rescue => e
          log_error("could not build plugin from '#{fu_file}'", e)
        end
      end.compact
    end

    def log(message)
      @logger && @logger.puts(message)
    end

    def log_error(message, error=nil)
      log("[ERROR] #{message}" + error.nil?? '' : error.message)
      log(error.backtrace) if error
    end

  end

  extend ClassMethods

  # Meta information about a plugin
  class Plugin

    attr_reader :module_name
    attr_reader :require_files
    attr_reader :plugin_fu_file

    def initialize(data, plugin_fu_file=nil)
      @module_name = data[:module] or raise 'no module name defined'
      @require_files = data[:require] or raise 'no files to require'
      @plugin_fu_file = plugin_fu_file
    end

    def activate!
      return if activated?

      @require_files.each do |file|
        require file
      end

      @module = module_name.split('::').
        inject(Object) {|m, v| m.const_get(v) }

      @activated = true
    end

    def activated? ; !!@activated ; end

    def module ; @module ; end

    def config
      c = Config::Receiver.new
      @module.define_config(c)
      c.all
    end

    def to_s
      "#<PluginFu::Plugin module_name='#@module_name' activated=#{activated?}>"
    end
  end

  class Loader

    attr_reader :plugins

    def initialize(plugins)
      @plugins = plugins
    end

    # Build an instance of an application using the given hash of config values
    def build_application(config_hash)
      config = build_config(config_hash)
      app = Wirer::Container.new

      plugins.each do |plugin|
        plugin.add_services_to_application(app, config)
      end

      app
    end

    # Return meta information about the configuration used and required
    # by applications built by this Loader
    def config_meta
      Hash[*plugins.map {|p| [p, p.config] }.flatten(1) ]
    end

    # Attempts to build a config object that would be used within the
    # application for the given set of config values, raising any errors on the
    # way
    def build_config(config, allow_missing=false)
      all_definitions = config_meta.map {|p, l| l }.flatten
      Config.new(all_definitions, config, allow_missing)
    end

  end
end

require 'plugin_fu/config'
