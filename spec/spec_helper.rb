require 'opal'
require 'file'
require 'set'
require 'opal-parser'
require 'mspec'
require 'mspec/opal/mspec_fixes'
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
end

formatter_class = `!!window.OPAL_SPEC_PHANTOM` ? PhantomFormatter : BrowserFormatter

# As soon as this file loads, tell the runner the specs are starting
OSpecRunner.main(formatter_class).will_start
