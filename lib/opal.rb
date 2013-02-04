require 'opal/parser'
require 'opal/erb'
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

  def self.core_dir
    File.join File.dirname(__FILE__), 'assets', 'javascripts'
  end

  # Returns parser prebuilt for js-environments.
  #
  # @return [String]
  def self.parser_code
    [
      Builder.new(:files => %w(racc.rb strscan.rb), :dir => File.join(self.core_dir, 'opal', 'parser')).build,
      Builder.new(:files => %w(opal.rb opal/builder.rb opal/erb.rb opal/grammar.rb opal/lexer.rb opal/parser.rb opal/scope.rb), :dir => File.join(File.dirname(__FILE__))).build,
      File.read(File.join self.core_dir, 'opal', 'parser', 'browser.js')
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

  ######################
  # NEW BUILDER
  ######################

  # Private, don't access these directly
  def self.paths
    @paths ||= []
  end

  def self.append_path(path)
    paths << path
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
