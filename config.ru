Bundler.require

require 'opal-rspec'
require 'react/source'

files = [React::Source.bundled_path_for('react-with-addons.js')] + FileList['spec/**/*_spec.rb']
sprockets_env = Opal::RSpec::SprocketsEnvironment.new(spec_pattern=nil, spec_exclude_pattern=nil, spec_files=files)
run Opal::Server.new(sprockets: sprockets_env) { |s|
      s.main = 'opal/rspec/sprockets_runner'
      sprockets_env.add_spec_paths_to_sprockets
      s.debug = true
    }
