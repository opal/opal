require 'opal'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.before { Opal.instance_variable_set('@paths', nil) }
end
