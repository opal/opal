abort "Don't run on opal!" if RUBY_ENGINE =~ /^opal/

require 'opal'

module Kernel
  def opal_parse str, file = '(string)'
    Opal::Grammar.new.parse str, file
  end
end
