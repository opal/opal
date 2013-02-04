#= require opal
#= require opal-spec
#= require_tree .

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
end

OpalSpec::Runner.autorun
