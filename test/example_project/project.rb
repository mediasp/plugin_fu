require 'plugin_fu'

module Project

  def run
    PluginFu.configure!(:logger => $stdout)

    PluginFu.plugins.each do |plugin|
      plugin.activate!
      puts plugin
    end
  end

  extend self
end

Project.run

