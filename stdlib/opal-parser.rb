require 'opal-gem'

module Kernel
  def eval(str)
    code = Opal::Parser.new.parse str
    `eval(#{code})`
  end
end
