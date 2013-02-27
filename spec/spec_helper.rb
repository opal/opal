require 'opal'
require 'opal-parser'
require 'opal-spec'

# stdlib
require 'opal/date'
require 'opal/enumerator'

module OpalTest
  class RaiseErrorMatcher
    def not_match(block)
      should_raise = false
      begin
        block.call
      rescue => e
        should_raise = true
      end

      if should_raise
        failure "did not expect #{@actual} to be raised."
      end
    end
  end
end

module Kernel
  def raise_error expected = Exception, msg = nil
    OpalTest::RaiseErrorMatcher.new expected
  end

  def be_an_instance_of(cls)
    be_kind_of cls
  end
end

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

  # Used for splitting specific ruby version tests. For now we allow all test
  # groups to run (as opal isnt really a specific ruby version as such?)
  def ruby_version_is(version, &block)
    block.call
  end

  def enumerator_class
    Enumerator
  end
end
