Bundler.require
Bundler::GemHelper.install_tasks

require 'opal/rspec/rake_task'
require_relative 'spec/rails_assets'

Opal::RSpec::RakeTask.new(:default) do |_, task|
  task.default_path = 'spec/opal'
  task.pattern = 'spec/opal/**/*_spec.rb'
end
