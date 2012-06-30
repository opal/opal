$:.unshift File.expand_path('../../lib')
require 'opal-rails'


# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../../test_app/config/environment.rb',  __FILE__)
require 'rspec/rails'
require 'capybara/rspec'

Rails.backtrace_cleaner.remove_silencers!


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.treat_symbols_as_metadata_keys_with_true_values = true
end
