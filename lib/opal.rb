require 'opal/parser'
require 'opal/builder'
require 'opal/builder_task'
require 'opal/context'
require 'opal/version'

module Opal
  # Parse given string of ruby into javascript
  def self.parse(str)
    Parser.new.parse str
  end

  # Returns opal runtime js code (string)
  def self.runtime
    File.read runtime_path
  end

  def self.opal_dir
    File.expand_path '../..', __FILE__
  end

  def self.runtime_path
    File.join opal_dir, 'build', 'opal.js'
  end
end