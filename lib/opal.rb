require 'opal/parser'
require 'opal/builder'
require 'opal/builder_task'
require 'opal/version'

module Opal
  # Parse given string of ruby into javascript
  def self.parse(str, file='(file)')
    js = Parser.new.parse str, file
    "(#{js})();"
  end

  # Returns opal runtime js code (string)
  def self.runtime
    Builder.runtime
  end

  def self.opal_dir
    File.expand_path '../..', __FILE__
  end

  def self.core_dir
    File.join opal_dir, 'core'
  end
end