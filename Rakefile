Bundler.require
Bundler::GemHelper.install_tasks

require 'opal/rspec/rake_task'
require 'react/source'

Opal::RSpec::RakeTask.new(:default) do |_, task|
  task.files = [React::Source.bundled_path_for('react-with-addons.js')] + FileList['spec/**/*_spec.rb']
end
