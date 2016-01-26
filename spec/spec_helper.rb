require 'opal'
require 'set'
require 'opal-parser'
require 'mspec'
require 'mspec/version'
require 'support/mspec_rspec_adapter'
require 'mspec-opal/runner'

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
end

require 'mspec/utils/script' # Needed by DottedFormatter
formatter_class = DottedFormatter

require 'mspec-opal/formatters'
# Uncomment one of the following to use a different formatter:
#
#formatter_class = BrowserFormatter
#formatter_class = NodeJSFormatter
#formatter_class = NodeJSDocFormatter
#formatter_class = PhantomFormatter
#formatter_class = PhantomDocFormatter

# As soon as this file loads, tell the runner the specs are starting
OSpecRunner.main(formatter_class).will_start
