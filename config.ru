Bundler.require

require 'opal-rspec'
require 'react/source'

sprockets_env = Opal::RSpec::SprocketsEnvironment.new
run Opal::Server.new(sprockets: sprockets_env) { |s|
      s.main = 'opal/rspec/sprockets_runner'
      sprockets_env.add_spec_paths_to_sprockets
      s.debug = false
      s.append_path File.dirname(::React::Source.bundled_path_for("react-with-addons.js"))
    }
