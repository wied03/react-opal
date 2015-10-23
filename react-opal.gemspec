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

  s.files          = `git ls-files`.split("\n")
  s.executables    = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.test_files     = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths  = %w(lib vendor)

  s.add_runtime_dependency 'opal', '>= 0.8.0'
  s.add_runtime_dependency 'opal-activesupport'
end
