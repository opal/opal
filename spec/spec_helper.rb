require 'opal'

module Kernel
  def opal_eval(str)
    code = Opal::Parser.new.parse str
    `eval('(' + code + ')()')`
  end

  def opal_parse(str, file='(string)')
    Opal::Grammar.new.parse str, file
  end
end

Spec::Runner.autorun
