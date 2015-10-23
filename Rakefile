Bundler.require
Bundler::GemHelper.install_tasks

require 'opal/rspec/rake_task'
require 'react/source'

Opal::RSpec::RakeTask.new(:default) do |server, task|
  # Need a Phantom polyfill, there is a docs and js path, order is not guaranteed, so just append both
  RailsAssetsEs5Shim.load_paths.each {|p| server.append_path p}
  server.append_path File.dirname(React::Source.bundled_path_for('react-with-addons.js'))
  task.pattern = 'spec/opal/**/*_spec.rb'
end
