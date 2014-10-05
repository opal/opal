require 'opal'
require 'file'
require 'set'
require 'opal-parser'
require 'mspec'
require 'mspec/version'
require 'support/mspec_rspec_adapter'
require 'mspec/opal/runner'

require 'math'
require 'encoding'

ENV['MSPEC_RUNNER'] = true

module Kernel
  def opal_parse(str, file='(string)')
    Opal::Parser.new.parse str, file
  end

  def eval_js(javascript)
    `eval(javascript)`
  end

  def at_exit(&block)
    $AT_EXIT_CALLBACKS ||= []
    $AT_EXIT_CALLBACKS << block
  end
end

formatter_class = `!!window.OPAL_SPEC_PHANTOM` ? PhantomFormatter : BrowserFormatter

# Uncomment the following to see example titles when they're executed.
# (useful to relate debug output to the example that generated it)
#
#formatter_class = PhantomDebugFormatter

# As soon as this file loads, tell the runner the specs are starting
OSpecRunner.main(formatter_class).will_start
