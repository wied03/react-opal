if RUBY_ENGINE == 'opal'
  require 'react/opal/top_level'
  require 'react/opal/component'
  require 'react/opal/element'
  require 'react/opal/event'
  require 'react/opal/version'
  require 'react/opal/api'
  require 'react/opal/validator'
else
  require 'opal'
  require 'react/opal/version'
  require 'opal-activesupport'

  Opal.append_path File.expand_path('../', __FILE__).untaint
end
