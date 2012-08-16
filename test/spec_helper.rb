require 'opal-spec'

module Kernel
  def opal_eval(str)
    code = Opal::Parser.new.parse str
    # puts code
    `eval('(' + code + ')()')`
  end
end

Spec::Runner.autorun