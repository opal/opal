if ENV['CHECK_COVERAGE']
  require 'coveralls'
  Coveralls.wear!
end

require 'opal'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = [:expect, :should] }
  config.mock_with(:rspec) { |c| c.syntax = [:expect, :should] }
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.before { Opal.reset_paths! }
  config.before { Opal::Config.reset! if defined? Opal::Config }
  config.before { Opal::Processor.reset_cache_key! if defined? Opal::Processor }
end
