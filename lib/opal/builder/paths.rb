# frozen_string_literal: true

require 'opal/project'

module Opal
  def self.gem_dir
    if defined? Opal::GEM_DIR
      # This is for the case of opalopal. __FILE__ and __dir__ are unreliable
      # in this case.
      Opal::GEM_DIR
    else
      File.expand_path('../..', __dir__)
    end
  end

  # Add a file path to opals load path. Any gem containing ruby code that Opal
  # has access to should add a load path through this method. Load paths added
  # here should only be paths which contain code targeted at being compiled by
  # Opal.
  def self.append_path(path)
    append_paths(path)
  end

  # Same as #append_path but can take multiple paths.
  def self.append_paths(*paths)
    paths.each { |i| setup_project(i) }
    @paths.concat(paths)
    nil
  end

  # All files that Opal depends on while compiling (for cache keying and
  # watching)
  def self.dependent_files
    # We want to ensure the compiler and any Gemfile/gemspec (for development)
    # stays untouched
    opal_path = File.expand_path('..', Opal.gem_dir)
    files = Dir["#{opal_path}/{Opalfile,Gemfile*,*.gemspec,lib/**/*}"]

    # Also check if parser wasn't changed:
    files += $LOADED_FEATURES.grep(%r{lib/(parser|ast)})

    files
  end

  extend Project::Collection

  def self.paths
    @paths.freeze
  end

  # Resets Opal.paths to the default value
  # (includes `corelib`, `stdlib`, `opal/lib`, `ast` gem and `parser` gem)
  def self.reset_paths!
    @paths = []
    @projects = []
    setup_project(gem_dir)
    nil
  end

  reset_paths!
end
