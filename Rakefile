Bundler.require
Bundler::GemHelper.install_tasks

require 'opal/rspec/rake_task'
require 'react/source'

Opal::RSpec::RakeTask.new(:default) do |server, task|
  RailsAssetsEs5Shim.load_paths.each { |p| server.append_path p }
  # Need a Phantom polyfill
  task.files = ['es5-shim/es5-shim.js', React::Source.bundled_path_for('react-with-addons.js')] + FileList['spec/opal/**/*_spec.rb']
end
