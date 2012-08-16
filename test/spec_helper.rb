require 'opal-spec'

module Kernel
  def opal_eval(str)
    `eval('(' + #{Opal::Parser.new.parse str} + ')()')`
  end
end

Spec::Runner.autorun