require 'opal/parser'
require 'opal/erb'
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
    Parser.new.parse str, file
  end

  # Returns opal runtime js code (string)
  #
  #   Opal.runtime
  #   # => "(function() { Opal = {}; ... })();"
  #
  # @return [String] returns opal runtime/corelib as a string
  def self.runtime
    process('opal').rstrip
  end
  # Returns parser prebuilt for js-environments.
  #
  # @return [String]
  def self.parser_code
    process('opal-parser')
  end

  def self.core_dir
    File.join File.dirname(__FILE__), 'assets', 'javascripts'
  end

  def self.append_path(path)
    paths << path
  end

  def self.lib_dir
    File.join File.dirname(__FILE__)
  end

  # Private, don't access these directly
  def self.paths
    @paths ||= []
  end

  # Build ruby/opal file at fname
  def self.process(fname)
    require 'opal/processor'

    env = Sprockets::Environment.new
    paths.each { |p| env.append_path p }

    env[fname].to_s
  end
end

# Add corelib to assets path
Opal.append_path Opal.core_dir
