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

  def self.core_dir
    File.join File.dirname(__FILE__), 'assets', 'javascripts'
  end

  def self.append_path(path)
    paths << path
  end

  # Private, don't add to these directly (use .append_path instead).
  def self.paths
    @paths ||= []
  end

  # Build ruby/opal file at fname
  def self.process(fname)
    env = Sprockets::Environment.new
    paths.each { |p| env.append_path p }

    env[fname].to_s
  end
end

require 'opal/parser'
require 'opal/processor'
require 'opal/version'
