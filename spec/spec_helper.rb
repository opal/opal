require 'opal'

module Kernel
  def opal_parse str, file = '(string)'
    Opal::Grammar.new.parse str, file
  end
end

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
end
