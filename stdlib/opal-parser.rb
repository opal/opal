require 'opal-gem'

module Kernel
  def eval(str)
    code = Opal.compile str
    `eval(#{code})`
  end
end
