require 'opal/parser'
require 'opal/processor'
require 'opal/server'
require 'opal/version'

# Opal is a ruby to javascript compiler, with a runtime for running
# in any javascript environment.
#
# Opal::Parser is the core class used for parsing ruby and generating
# javascript from its syntax tree. Opal::Processor is the main system used
# for compiling larger programs. Opal::Processor uses sprockets to maintain
# an environment of load paths, which can be used to require other ruby or
# javascript sources.
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
    Parser.new.parse str, :file => file
  end

  # Returns the path to the opal corelib. Used by Opal::Processor to load
  # opal runtime and core lib.
  #
  # @return [String]
  def self.core_dir
    File.expand_path('../../opal', __FILE__)
  end

  # Add a file path to opals load path. Any gem containing ruby code that Opal
  # has access to should add a load path through this method. Load paths added
  # here should only be paths which contain code targeted at being compiled by
  # Opal.
  #
  # @param [String] path file path to add
  def self.append_path(path)
    paths << path
  end

  # Private, don't add to these directly (use .append_path instead).
  def self.paths
    @paths ||= [Opal.core_dir]
  end
end
