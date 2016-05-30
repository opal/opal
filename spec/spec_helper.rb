require 'opal'
require 'set'
require 'opal/platform'
require 'opal-parser'
require 'mspec'
require 'mspec/version'
require 'support/mspec_rspec_adapter'
require 'mspec-opal/runner'

# Node v0.12 as well as Google Chrome/V8 42.0.2311.135 (64-bit)
# showed to need more tolerance (ruby spec default is 0.00003)
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
require 'mspec-opal/formatters'
