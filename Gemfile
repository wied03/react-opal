source 'https://rubygems.org'

gemspec

# Remove this after figuring out why build fails on travis only
system 'git submodule update --init; (cd opal-rspec; git submodule update --init)' unless Dir.glob('opal-rspec/**').any?
# Until opal-rspec is updated
gem 'opal-rspec', path: 'opal-rspec'

gem 'rake'
gem 'react-source', '~> 0.13'
gem 'sinatra'
gem 'opal-jquery'
#gem 'opal-rspec', '>= 0.5.0.beta3'
# need this to be required in automatically, wasn't working in gemspec
gem 'opal-activesupport'

source 'https://rails-assets.org' do
  gem 'rails-assets-es5-shim'
end
