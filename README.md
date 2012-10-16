# PluginFu

Brainstorming around PluginFu (working title) library


- MSP requires plugin_foo

Different phases

Basic plugin system config and code discovery

- find out what plugins on load path - maybe primarily just for benefit of nice help UI to show available plugins
- MSP instantiates/configures plugin_fu with basic config (load path conventions, module name convention, low-level debug logger, …, )

require 'plugin_fu'
PluginFu.configure!(basic_config)

- could look for files on the load path with a specific naming convention, such as
  `plugin-fu-description`.  This could be read to find out about what plugins are
  being kept in this location.
-- Would you use load(full_path) or require(relative_path)?  load would make it
   explicit where the code is coming from, with the risk of it being re-required
   by mistake.

List of enabled plugins specified for an application

loader = PluginFu.create_loader(enabled_plugins)

- Enabled plugin list could be gotten via a config file
- This static loader factory method loads code for enabled plugins (possible errors if not available on load path)
--- You could require user to explicitly load code for the plugins they want to enable, but shouldn't hurt to require them automatically
--- Loading code for a plugin should not have side-effects -- worst case if you load something and don't ever enable it, it'll use some memory up

- Loader asks plugins what config they accept: Plugin.define_config or whatever. Defines what hash keys it wants, with what defaults, what type of allowed values, ...
--- config keys specified would be (implicitly?) namespaced to the plugin's own config namespace
--- But plugins could (?maybe) also specify a dependence on config settings for others plugins on which they 'depend'
--- Or could just give all plugins access to all config, but being explicit could help catch problems early and be good documentation

- Loader can now be queried to find out what config is required it order to create an app (e.g. by a help command)

- Loader knows the ruby modules corresponding to the enabled plugins which it has loaded (you probably wouldn't usually need to directly access them, you'd use the loader to create an app)

- Loader can now validate a parsed config object, checking that required keys are present (or have defaults) and of correct type

- Can now ask loader to build an application given config

app = loader.build_application(config)

- To do this, loader creates a wirer container, asks each enabled plugin to add_services_to_app(app, config_for_that_plugin (or just all config?))

- App can be queried to find out the values for its config keys (e.g. by a config management command)
--- On a per-plugin basis? or just overall using a key namespacing convention
--- Right require subclassing/wrapping Wirer::Container to add some basic introspection for per-plugin config (or maybe that's overkill?)
--- could be done by adding config keys to application with a feature set
    convention, i.e. :features => [[:config_value, :some_config_key]]
Now have an app, great!

(Could have sugar to combine two steps above as: PluginFu.build_app(enabled_plugins, config))


Other stuff:
- For code loading, maybe could get away without the "loading_plugin" / "register_plugin" / "MSP.require_plugin" features in msp.rb
- Just use plain old ruby for code loading
- Just use a (configured) convention for looking up the ruby module corresponding to a loaded plugin

Plugin dependencies / versions and gems

- Ideally a plugin would be a rubygem
- Any hard load-time dependency on another plugin would be specified as a gem dependency
--- Which would hopefully be picked up by any debian packaging tool and turned into a correponding debian package dependency if plugins are put in separate packages
- Hard runtime dependency (i.e. non-optional dependency via wirer) would also probably want to make a rubygems dependency too
- Soft runtime dependency (optional dependency via wirer) would not be a rubygems dependency

- If plugins depend on other plugins' config, this might need some special handling -- would want to check that the other plugin is enabled in the same application.
--- Might be better achieved by a wirer dependency on a service exposed by that other plugin which exposes relevant bits of config (or better yet, an actual interface which does the relevant thing which uses that config)

- Plugin system would not depend on rubygems at runtime though -- just use the load path. Can then use RUBYOPT='-rubygems' or bundler load path creation or a load path gotten from debian packaging, or bundler/rvm/rubygems in development, as desired

- Question: would plugin system need to know about version dependencies between plugins?
--- Inclined to say no -- that's more an issue for whatever tool is used to install the plugins (rubygems, bundler, debain package, …)
--- Although a sanity check at runtime wouldn't hurt -- how best to achieve that without depending on rubygems at runtime / without needlessly replicating rubygems dependency functionality
--- Maybe

Testing

- Maybe some test runner command needed to help run tests across plugins
- Find out which plugins are available and what tests live within those plugin codebases
- May need some conventions for where tests live and how shared test helpers are loaded
- Maybe you can "include PluginFu::TestHelpers" to get some help creating applications for integration tests

- Would you require a particular test library? if not, maybe need to run tests in separate processes

- Integration & acceptance tests which work across multiple plugins -- how are these managed / where do they live?

--- Maybe: for a particular application config / deployment setup, you have acceptance tests for a particular config (perhaps based on some shared test helper code)
------ Perhaps a framework for setting up these kinds of tests for different combinations of config options
------ Build/CI system would use it

- Maybe: for smaller-scale integration tests across plugins, you could have a 'test-only' plugin which just depends on them and implements some integration tests to test that those two plugins play nice together
--- Often that might co-incide with the need for an actual proper plugin which depends on the other plugins



This way, config file loading and command-line entry points would be separate concerns
Although, would be nice to have some easy integration of plugin_fu with a config file parser, conventions for where to look for config files, and integration with some command-line library for command-line entry points which can specify config, give help etc

