# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift('lib')

require 'plugin_fu/version'

Gem::Specification.new do |s|
  s.name = 'plugin_fu'
  s.version = PluginFu::VERSION
  s.authors = ['Nick Griffiths']
  s.email = ["nicobrevin@gmail.com"]
  s.summary = "Plugin code-loading framework"

  s.add_development_dependency('rake')
  s.add_development_dependency('minitest', '~> 2.1.0')
  s.add_development_dependency('mocha', '~> 0.9.12')

  s.files = Dir.glob("lib/**/*")
end
