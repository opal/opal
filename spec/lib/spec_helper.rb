require 'opal'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.before { Opal.instance_variable_set('@paths', nil) }
  config.before { Opal::Config.reset! if defined? Opal::Config }
  config.before { Opal::Processor.reset_cache_key! if defined? Opal::Processor }
end
