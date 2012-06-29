require 'opal/parser'
require 'opal/builder'
require 'opal/builder_task'
require 'opal/version'

module Opal

  # Parse given string of ruby into javascript
  #
  # @example
  #
  #   Opal.parse "puts 'hello world'"
  #   # => "(function() { ... })()"
  #
  # @param [String] str ruby string to parse
  # @param [String] file the filename to use when parsing
  # @return [String] the resulting javascript code
  def self.parse(str, file='(file)')
    Parser.new.parse str, file
  end

  # Returns opal runtime js code (string)
  #
  # @return [String] returns opal runtime/corelib as a string
  def self.runtime
    Builder.runtime
  end

  # Build gem with given name to a string.
  #
  # @example
  #
  #   str = Opal.build_gem 'opal-spec'
  #   # => "... javascript code ..."
  #
  # @param [String] name the name of the gem
  # @return [String] returns built gem
  def self.build_gem(name)
    spec = Gem::Specification.find_by_name name
    Builder.build(:files => spec.require_paths, :dir => spec.full_gem_path)
  end

  def self.opal_dir
    File.expand_path '../..', __FILE__
  end

  def self.core_dir
    File.join opal_dir, 'core'
  end
end