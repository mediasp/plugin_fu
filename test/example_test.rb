require 'test/helpers'

describe 'PluginFu' do
  include ExecHelper

  def exec_project(options, exitstatus=0)
    Dir.chdir 'test/example_project' do
      begin
        exec "ruby -r rubygems -I../../lib project.rb " + options || '', exitstatus
      rescue => e
        puts all_output
        raise
      end
    end
  end

  describe '#configure!' do
    it "finds *.plugin_fu files on the root of load path entries, parses " +
      "them, and builds a plugin objects, queryable via the plugins method" do

      exec_project '--dump-plugins'

      assert_stdout_matches 'plugin_a.plugin_fu,PluginA'
      assert_stdout_matches 'plugin_b.plugin_fu,PluginB'
      assert_stdout_matches 'plugin_broken.plugin_fu,PluginBroken'
    end
  end

  describe '#config_meta' do
    it 'can return information about config that plugin expects' do

      exec_project '--config-help'

      assert_stdout_matches 'PluginA - name_of_cat - The name of the cat'
      assert_stdout_matches 'PluginA - age_of_cat - How old is the cat'
      assert_stdout_matches 'PluginB - server_precision - spline calculation precision'
    end
  end

  describe '#build_config' do
    it 'returns nil if everything is ok' do
      exec_project '--validate-config'
      assert_stdout_matches 'name_of_cat="jess"'
      assert_stdout_matches 'age_of_cat=12'
      assert_stdout_matches 'server_precision=nil'
    end

    it 'can accept non default config values' do
      exec_project '--validate-config --config=name_of_cat=peter'
      assert_stdout_matches 'name_of_cat="peter"'
      assert_stdout_matches 'age_of_cat=12'
      assert_stdout_matches 'server_precision=nil'
    end

    it 'barfs if you supply a value that can not be coerced' do
      exec_project '--validate-config --config=age_of_cat=bryan', 4
      assert_stderr_matches "Could not coerce \"bryan\" to type integer for age_of_cat"
    end

    it 'returns a list of error messages if something fails' do
      exec_project '--validate-config --config=does_not_exist=bah', 4
      assert_stderr_matches "did not expect values for: does_not_exist"
    end
  end
end
