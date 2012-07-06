require 'opal/parser'
require 'opal/builder'
require 'opal/builder_task'
require 'opal/version'

# Opal is a ruby to javascript compiler, with a runtime for running
# in any javascript environment.
module Opal

  # Parse given string of ruby into javascript
  #
  #   Opal.parse "puts 'hello world'"
  #   # => "(function() { ... })()"
  #
  # @param [String] str ruby string to parse
  # @param [String] file the filename to use when parsing
  # @return [String] the resulting javascript code
  def self.parse(str, file='(file)')
    "(#{ Parser.new.parse str, file })();"
  end

  # Returns opal runtime js code (string)
  #
  #   Opal.runtime
  #   # => "(function() { Opal = {}; ... })();"
  #
  # @return [String] returns opal runtime/corelib as a string
  def self.runtime
    Builder.runtime
  end

  # Build gem with given name to a string.
  #
  #   Opal.build_gem 'opal-spec'
  #   # => "... javascript code ..."
  #
  # If the given gem name cannot be found, then an error will be
  # raised
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