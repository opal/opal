module Opal
  def self.gem_dir
    File.expand_path('../..', __FILE__.untaint)
  end

  def self.core_dir
    File.expand_path('../../../opal', __FILE__.untaint)
  end

  def self.std_dir
    File.expand_path('../../../stdlib', __FILE__.untaint)
  end

  # Add a file path to opals load path. Any gem containing ruby code that Opal
  # has access to should add a load path through this method. Load paths added
  # here should only be paths which contain code targeted at being compiled by
  # Opal.
  def self.append_path(path)
    paths << path
  end

  def self.use_gem(gem_name, include_dependecies = true)
    spec = Gem::Specification.find_by_name(gem_name)

    spec.runtime_dependencies.each do |dependency|
      use_gem dependency.name
    end if include_dependecies

    spec.require_paths.each do |path|
      Opal.append_path File.join(spec.gem_dir, path)
    end
  end

  # Private, don't add to these directly (use .append_path instead).
  def self.paths
    @paths ||= [core_dir.untaint, std_dir.untaint, gem_dir.untaint]
  end
end
