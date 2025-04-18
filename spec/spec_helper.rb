# backtick_javascript: true

require 'opal'
require 'set'
require 'opal-parser'
require 'mspec'
require 'mspec/version'
require 'support/mspec_rspec_adapter'
require 'support/guard_platform'
require 'mspec-opal/runner'
require 'mspec-opal/should' # Overwrite Object#should with strict version.

# Node v0.12 as well as Google Chrome/V8 42.0.2311.135 (64-bit)
# showed to need more tolerance (ruby spec default is 0.00003)
TOLERANCE = 0.00004

ENV['MSPEC_RUNNER'] = true

# Trigger autoloading, needed by `Module.constants`
# in `spec/ruby/core/module/constants_spec.rb`.
Dir

module Kernel
  def opal_parse(str, file='(string)')
    Opal::Parser.new.parse str, file
  end

  def eval_js(javascript)
    `eval(javascript.toString())`
  end
end

SPEC_TEMP_DIR = File.expand_path("#{File.realpath(Dir.pwd)}/../tmp/rubyspec_temp")

def tmp(name, uniquify = true)
  Dir.mkdir SPEC_TEMP_DIR unless Dir.exist? SPEC_TEMP_DIR
  File.join SPEC_TEMP_DIR, name
end

# To make MSpec happy
require 'thread'
require 'corelib/math'

require 'mspec/utils/script' # Needed by DottedFormatter
require 'mspec-opal/formatters'
