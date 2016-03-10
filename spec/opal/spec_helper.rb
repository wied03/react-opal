# polyfill needed for phantom
require 'es5-shim'
require 'jquery'
require 'opal/jquery'
# actual react source
require 'react'
require 'react/react-with-addons'
# react.rb wrapper
require 'react-opal'
require 'react/opal/testing'
require 'element_collision'

RSpec.configure do |config|
  config.include React::Testing
  config.after :each do
    React::ComponentFactory.clear_component_class_cache
  end
end

