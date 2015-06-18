require 'opal'
require 'set'
require 'opal-parser'
require 'mspec'
require 'mspec/version'
require 'fixtures/version'
require 'support/mspec_rspec_adapter'
require 'mspec/opal/runner'

require 'math'
require 'encoding'

# Node v0.12 as well as Google Chrome/V8 42.0.2311.135 (64-bit)
# showed to need more tolerance (rubyspec default is 0.00003)
TOLERANCE = 0.00004

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

is_node = `typeof(process) == 'object' && !!process.versions.node`
is_browser = `(typeof(window) !== 'undefined')`
is_phantom = is_browser && `!!window.OPAL_SPEC_PHANTOM`

case
when is_node
  formatter_class = NodeJSFormatter
when is_phantom
  require 'phantomjs'
  formatter_class = PhantomFormatter
else
  formatter_class = BrowserFormatter
end

# Uncomment the following to see example titles when they're executed.
# (useful to relate debug output to the example that generated it)
#
#formatter_class = PhantomDebugFormatter

# As soon as this file loads, tell the runner the specs are starting
OSpecRunner.main(formatter_class).will_start
