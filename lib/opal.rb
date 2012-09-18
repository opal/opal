require 'opal/parser'
require 'opal/builder'
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
    core_dir   = Opal.core_dir
    load_order = File.join core_dir, 'load_order'
    corelib    = File.read(load_order).strip.split.map do |c|
      File.read File.join(core_dir, "#{c}.rb")
    end

    runtime = File.read(File.join core_dir, 'runtime.js')
    corelib = Opal.parse corelib.join("\n"), '(corelib)'

    [
      "// Opal v#{Opal::VERSION}",
      "// http://opal.github.com",
      "// Copyright 2012, Adam Beynon",
      "// Released under the MIT License",
      "(function(undefined) {",
      runtime,
      "Opal.version = #{ Opal::VERSION.inspect };",
      corelib,
      "}).call(this);"
    ].join("\n")
  end

  # Returns parser prebuilt for js-environments.
  #
  # @return [String]
  def self.parser_code
    [
      Builder.new(:files => %w(racc.rb strscan.rb), :dir => File.join(self.core_dir, 'parser')).build,
      self.build_gem('opal'),
      File.read(File.join self.core_dir, 'parser', 'browser.js')
    ].join("\n")
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
    Builder.new(:files => spec.require_paths, :dir => spec.full_gem_path).build
  end

  # Build the given files. Files should be a string of either a full
  # filename, a directory name or even a glob of files to build.
  #
  #   Opal.build_files 'spec'
  #   # => all spec files in spec dir
  #
  # @param [String] files files to build
  # @return [String]
  def self.build_files(files, dir=nil)
    Builder.new(:files => files, :dir => dir).build
  end

  def self.opal_dir
    File.expand_path '../..', __FILE__
  end

  def self.core_dir
    File.join opal_dir, 'core'
  end
end