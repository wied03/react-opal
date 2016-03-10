# polyfill needed for phantom
require 'es5-shim'
require 'jquery'
require 'opal/jquery'
# actual react source
require 'react/react-with-addons'
require 'react/react-dom'
require 'react/react-dom-server'
# react.rb wrapper
require 'react-opal'
require 'react/opal/testing'
require 'element_collision'
require 'helpers/children'

RSpec.configure do |config|
  config.include React::Testing
  config.after :each do
    React::ComponentFactory.clear_component_class_cache
  end
  config.filter_run_including focus: true
  config.run_all_when_everything_filtered = true
end

