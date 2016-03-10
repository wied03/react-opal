if RUBY_ENGINE == 'opal'
  require 'react/opal/top_level'
  require 'react/opal/component'
  require 'react/opal/element'
  require 'react/opal/component_factory'
  require 'react/opal/validator'
else
  require 'opal'
  require 'react/opal/version'
  require 'opal-activesupport'

  Opal.append_path File.expand_path('../', __FILE__).untaint
end
