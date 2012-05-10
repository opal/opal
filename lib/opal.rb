require 'opal/parser'
require 'opal/builder'
require 'opal/context'
require 'opal/version'

module Opal
  # Base Opal directory - used by build tools
  # @return [String]
  def self.opal_dir
    File.expand_path '../..', __FILE__
  end

  def self.runtime_path
    File.join opal_dir, 'build', 'opal.js'
  end
end