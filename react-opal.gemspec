# -*- encoding: utf-8 -*-
require File.expand_path('../lib/react/opal/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'react-opal'
  s.version      = React::VERSION
  s.author       = 'Brady Wied'
  s.email        = 'brady@bswtechconsulting.com'
  s.homepage     = 'https://github.com/wied03/react-opal'
  s.summary      = 'Opal Ruby wrapper of React.js library.'
  s.license      = 'MIT'
  s.description  = "Write reactive UI component with Ruby's elegancy and compiled to run in Javascript."

  s.files          = Dir.glob('lib/**/*.rb') + Dir.glob('opal/**/*.rb')
  s.require_paths  = %w(lib)

  s.add_runtime_dependency 'opal', '>= 0.8.0'
  s.add_runtime_dependency 'opal-activesupport', '>= 0.2.0'
end
