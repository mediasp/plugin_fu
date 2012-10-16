require 'yaml'

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
    end

    private

    def find_plugins
      fu_files = $LOAD_PATH.map do |entry|
        Dir[File.join(entry, '*.plugin_fu')]
      end.flatten

      @plugins = fu_files.map do |fu_file|
        plugin_data = YAML.load_file(fu_file)
        begin
          Plugin.new(plugin_data)
        rescue => e
          log("[ERROR] could not build plugin from '#{fu_file}': #{e.message}")
        end
      end.compact
    end

    def log(message)
      @logger && @logger.puts(message)
    end

  end

  extend ClassMethods

  class Plugin

    attr_reader :module_name
    attr_reader :require_files

    def initialize(data)
      @module_name = data[:module] or raise 'no module name defined'
      @require_files = data[:require] or raise 'no files to require'
    end

    def activate!
      @require_files.each do |file|
        require file
      end

      @activated = true
    end

    def activated? ; !!@activated ; end

    def to_s
      "#<PluginFu::Plugin module_name='#@module_name' activated=#{activated?}>"
    end
  end

  class Loader

    # Build an instance of an application using the given config object
    def build_application(config)
    end

    # Return meta information about the configuration used and required
    # by applications built by this Loader
    def config_meta
    end

    # Return the module that corresponds to a given plugin.  This module
    # is expected to conform to the plugin module interface.
    def module_for_plugin(plugin)
    end

    # Returns a list of basic validation errors for the given set of
    # configuration if it were to be applied to a new application.
    def validate_config(config)
    end

  end


end
