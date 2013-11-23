require 'opal'

module OpalSpecHelpers
  def opal_parse(str, file='(string)')
    Opal::Parser.new.parse str, file
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.include OpalSpecHelpers
end
