require 'opal'
require 'opal-parser'
require 'opal-spec'

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

  # Used for splitting specific ruby version tests. For now we allow all test
  # groups to run (as opal isnt really a specific ruby version as such?)
  def ruby_version_is(version, &block)
    block.call
  end

  def enumerator_class
    Enumerator
  end
end
