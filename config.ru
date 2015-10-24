Bundler.require
require 'opal-rspec'
require 'react/source'

sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern='spec/opal/**/*_spec.rb')
run Opal::Server.new(sprockets: sprockets_env) { |s|
      s.main = 'opal/rspec/sprockets_runner'
      sprockets_env.add_spec_paths_to_sprockets
      s.debug = false
      # Need a Phantom polyfill, there is a docs and js path, order is not guaranteed, so just append both
      RailsAssetsEs5Shim.load_paths.each { |p| s.append_path p }
      RailsAssetsJquery.load_paths.each { |p| s.append_path p }
      s.append_path File.dirname(React::Source.bundled_path_for('react-with-addons.js'))
    }
