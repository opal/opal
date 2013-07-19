require 'opal/parser'
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

  def self.parse(source, options = {})
    Parser.new.parse(source, options)
  end

  def self.core_dir
    File.expand_path('../../corelib', __FILE__)
  end

  def self.std_dir
    File.expand_path('../../stdlib', __FILE__)
  end

  # Add a file path to opals load path. Any gem containing ruby code that Opal
  # has access to should add a load path through this method. Load paths added
  # here should only be paths which contain code targeted at being compiled by
  # Opal.
  def self.append_path(path)
    paths << path
  end

  # Private, don't add to these directly (use .append_path instead).
  def self.paths
    @paths ||= [core_dir, std_dir]
  end
end
