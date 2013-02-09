root_dir = File.expand_path('../../', __FILE__)


# OPAL-RAILS

$:.unshift File.expand_path('lib', root_dir)
require 'opal-rails'


# RAILS

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('test_app/config/environment.rb', root_dir)
require 'rspec/rails'

Rails.backtrace_cleaner.remove_silencers!


# RSPEC

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path('spec/support/**/*.rb', root_dir)].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
