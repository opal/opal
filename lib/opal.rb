require 'opal/parser/parser'
require 'opal/builder'
require 'opal/dependency_builder'
require 'opal/context'
require 'opal/version'

module Opal
  def self.opal_dir
    File.expand_path '../..', __FILE__
  end

  def self.runtime_code
    File.read File.join(opal_dir, 'runtime', 'opal.js')
  end

  def self.runtime_debug_code
    File.read File.join(opal_dir, 'runtime', 'opal.debug.js')
  end
end
