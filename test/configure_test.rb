require 'minitest/autorun'
require 'plugin_fu'
require 'open4'

require 'test/helpers'

describe 'PluginFu' do
  include ExecHelper

  describe '#configure!' do
    it "finds *.plugin_fu files on the root of load path entries, parses " +
      "them, and builds a plugin objects, queryable via the plugins method" do

      Dir.chdir 'test/example_project' do
        exec "ruby -r rubygems -I../../lib project.rb"
#        exec "ruby -r rubygems project.rb"
        puts all_output
      end

    end
  end
end
