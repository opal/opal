# frozen_string_literal: true

module Opal
  # Opal::Project is a representation of an Opal project. In particular
  # it's a directory containing Ruby files which is described by Opalfile.
  class Project
    # DSL for Opal::Project
    class Opalfile
      def initialize(project)
        @project = project
        yield self if block_given?
      end

      attr_reader :project

      def add_load_path(*load_paths)
        # Make relative paths absolute based on Opalfile's location
        load_paths = load_paths.map do |i|
          if File.absolute_path?(i)
            i
          else
            File.realpath(i, project.root_dir)
          end
        end
        project.collection.append_paths(*load_paths)
      end

      alias add_load_paths add_load_path

      def add_gem_dependency(name)
        project.collection.use_gem(name)
      end

      def method_missing(method, *, **)
        raise OpalfileUnknownDirective, "unknown directive #{method} in Opalfile"
      end

      def respond_to_missing?(_method, *)
        false
      end
    end

    # A mixin for methods that are used to extend either global (Opal) or local
    # (Opal::Builder instance) to contain a collection of projects.
    module Collection
      def all_projects
        if self == Opal
          projects
        else
          Opal.projects + projects
        end
      end

      def projects
        @projects ||= []
      end

      def has_project?(root_dir)
        all_projects.any? { |i| i.root_dir == root_dir }
      end

      def project_of(root_dir)
        all_projects.find { |i| i.root_dir == root_dir }
      end

      def add_project(project)
        projects << project
      end

      def setup_project(file)
        Project.setup_project_for(self, file)
      end

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
        if RUBY_ENGINE == 'opal'
          warn "Opal: paths for gems are not available in JavaScript. The directive `use_gem #{gem_name}` has been ignored."
        else
          append_paths(*require_paths_for_gem(gem_name, include_dependencies))
        end
      end

      private

      def require_paths_for_gem(gem_name, include_dependencies)
        paths = []

        spec = Gem::Specification.find_by_name(gem_name)
        raise GemNotFound, gem_name unless spec

        project = setup_project(spec.gem_dir)

        # If a project is found and it contains an Opalfile, use directives in
        # Opalfile. The dependencies will be resolved via Opalfile resolution.
        if project&.has_opalfile?
          []
        else
          if include_dependencies
            spec.runtime_dependencies.each do |dependency|
              paths += require_paths_for_gem(dependency.name, include_dependencies)
            end
          end

          gem_dir = spec.gem_dir
          spec.require_paths.map do |path|
            if File.absolute_path? path
              paths << path
            else
              paths << File.join(gem_dir, path)
            end
          end

          paths
        end
      end
    end

    def initialize(root_dir, collection)
      @root_dir = root_dir
      @collection = collection

      collection.add_project(self)

      parse_opalfile
    end

    attr_reader :root_dir, :collection

    def has_opalfile?
      @has_opalfile
    end

    def parse_opalfile
      opalfile_path = "#{@root_dir}/Opalfile"
      if File.exist?(opalfile_path)
        opalfile = File.read(opalfile_path)
        Opalfile.new(self) do |dsl|
          dsl.instance_eval(opalfile, opalfile_path, 1)
        end
        @has_opalfile = true
      end
    end

    @loading = []

    def self.setup_project_for(collection, file)
      root_dir = locate_root_dir(file)

      return collection.project_of(root_dir) if collection.has_project?(root_dir)
      return nil unless root_dir
      return nil if @loading.include? root_dir

      Project.new(root_dir, collection)
    end

    # Finds the project's root directory by searching for a project-defining file in
    # the given file's ancestor directories.
    #
    # A project-defining file is one of the files in the PROJECT_DEFINING_FILES constant.
    #
    # @param file [String] The starting file path for the search.
    # @return [String, nil] The path to the root directory, or nil if not found or
    # the file does not exist.
    def self.locate_root_dir(file)
      return nil unless file
      begin
        file = File.realpath(file)
      rescue Errno::ENOENT
        return nil
      end

      current_dir = file

      until dir_is_project_candidate? current_dir
        parent_dir = File.dirname(current_dir)
        # If no further parent, stop the search.
        # In addition, stop progressing if we hit a directory called "vendor".
        # This is a special case - some users are installing gem dependencies
        # inside a vendor directory in a standalone project. We don't want both
        # to be conflated, as then the gem's load paths may not be registered.
        break if current_dir == parent_dir || File.basename(current_dir) == 'vendor'

        current_dir = parent_dir
      end

      if dir_is_project_candidate? current_dir
        current_dir
      end
    end

    PROJECT_DEFINING_FILES = %w[Opalfile Gemfile *.gemspec].freeze

    @glob_cache = {}

    def self.dir_is_project_candidate?(current_dir)
      @glob_cache[current_dir] ||= Dir[File.join(current_dir, "{#{PROJECT_DEFINING_FILES.join(',')}}")]
      @glob_cache[current_dir].any?
    end
  end
end
