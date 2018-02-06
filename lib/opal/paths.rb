# frozen_string_literal: true

module Opal
  def self.gem_dir
    File.expand_path("../..", __FILE__.dup.untaint)
  end

  def self.core_dir
    File.expand_path("../../../opal", __FILE__.dup.untaint)
  end

  def self.std_dir
    File.expand_path("../../../stdlib", __FILE__.dup.untaint)
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
    @paths.concat(paths)
    nil
  end

  module UseGem
    # Adds the "require_paths" (usually `lib/`) of gem with the given name to
    # Opal paths. By default will include the "require_paths" from all the
    # dependent gems.
    #
    # @param gem_name [String] the name of the gem
    # @param include_dependencies [Boolean] whether or not to add recursively
    #   the gem's dependencies
    # @raise [Opal::GemNotFound]
    #   if gem or any of its runtime dependencies not found
    def use_gem(gem_name, include_dependencies = true)
      append_paths(*require_paths_for_gem(gem_name, include_dependencies))
    end

    private

    def require_paths_for_gem(gem_name, include_dependencies)
      paths = []

      spec = Gem::Specification.find_by_name(gem_name)
      raise GemNotFound, gem_name unless spec

      spec.runtime_dependencies.each do |dependency|
        paths += require_paths_for_gem(dependency.name, include_dependencies)
      end if include_dependencies

      gem_dir = spec.gem_dir
      spec.require_paths.map do |path|
        paths << File.join(gem_dir, path)
      end

      paths
    end
  end

  extend UseGem

  def self.paths
    @paths.dup.freeze
  end

  # Resets Opal.paths to the default value
  # (includes `corelib`, `stdlib`, `opal/lib`, `ast` gem and `parser` gem)
  def self.reset_paths!
    @paths = [core_dir.untaint, std_dir.untaint, gem_dir.untaint]
    if RUBY_ENGINE != 'opal'
      use_gem 'ast'
      use_gem 'parser'
    end
    nil
  end

  reset_paths!
end
