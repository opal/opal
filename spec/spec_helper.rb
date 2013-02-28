require 'opal'
require 'opal-parser'
require 'ospec'

# stdlib
require 'opal/date'
require 'opal/enumerator'

module Kernel
  def opal_eval(str)
    code = Opal::Parser.new.parse str
    `eval(code)`
  end

  def opal_parse(str, file='(string)')
    Opal::Grammar.new.parse str, file
  end

  def opal_eval_compiled(javascript)
    `eval(javascript)`
  end

  def eval(str)
    opal_eval str
  end
end
