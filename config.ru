Bundler.require
require 'opal-rspec'

sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern='spec/opal/**/*_spec.rb',
                                                      spec_exclude_pattern=nil,
                                                      spec_files=nil,
                                                      default_path='spec/opal')
sprockets_env.cache = Sprockets::Cache::FileStore.new('./tmp/cache/opal_rspec')
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  sprockets_env.add_spec_paths_to_sprockets
  s.debug = false
  # Need a Phantom polyfill, there is a docs and js path, order is not guaranteed, so just append both
  RailsAssetsEs5Shim.load_paths.each { |p| s.append_path p }
  RailsAssetsJquery.load_paths.each { |p| s.append_path p }
  RailsAssetsReact.load_paths.each { |p| s.append_path p }
}
