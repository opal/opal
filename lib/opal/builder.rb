# frozen_string_literal: true

require 'opal/path_reader'
require 'opal/paths'
require 'opal/config'
require 'opal/cache'
require 'opal/builder/scheduler'
require 'opal/project'
require 'opal/builder/directory'
require 'opal/builder/watcher'
require 'set'
# opal/builder/processor required at the bottom

module Opal
  class Builder
    # The registered processors
    def self.processors
      @processors ||= []
    end

    # All the extensions supported by registered processors
    def self.extensions
      @extensions ||= []
    end

    # @public
    # Register a builder processor and the supported extensions.
    # A processor will respond to:
    #
    # ## `#requires`
    # An array of string containing the logic paths of required assets
    #
    # ## `#required_trees`
    # An array of string containing the logic paths of required directories
    #
    # ## `#autoloads`
    # An array of entities that are autoloaded and their compile-time load failure can
    # be safely ignored
    #
    # ## `#to_s`
    # The processed source
    #
    # ## `#source_map`
    # An instance of `::Opal::SourceMap::File` representing the processd asset's source
    # map.
    #
    # ## `.new(source, filename, compiler_options)`
    # The processor will be instantiated passing:
    # - the unprocessed source
    # - the asset's filename
    # - Opal's compiler options
    #
    # ## `.match?(path)`
    # The processor is able to recognize paths suitable for its type of
    # processing.
    #
    def self.register_processor(processor, processor_extensions)
      return if processors.include?(processor)
      processors << processor
      processor_extensions.each { |ext| extensions << ext }
    end

    class MissingRequire < LoadError
    end

    class ProcessorNotFound < LoadError
    end

    include Project::Collection
    include Builder::Directory
    include Builder::Watcher

    def initialize(options = nil)
      (options || {}).each_pair do |k, v|
        public_send("#{k}=", v)
      end

      @stubs                    ||= []
      @preload                  ||= []
      @processors               ||= ::Opal::Builder.processors
      @path_reader              ||= PathReader.new(Opal.paths, extensions.map { |e| [".#{e}", ".js.#{e}"] }.flatten)
      @prerequired              ||= []
      @compiler_options         ||= Opal::Config.compiler_options
      @missing_require_severity ||= Opal::Config.missing_require_severity
      @cache                    ||= Opal.cache
      @scheduler                ||= Opal.builder_scheduler

      if @scheduler.respond_to? :new
        @scheduler = @scheduler.new(self)
      end

      @processed = []
    end

    def self.build(*args, &block)
      new.build(*args, &block)
    end

    def build(path, options = {})
      build_str(source_for(path), path, options)
    end

    # Retrieve the source for a given path the same way #build would do.
    def source_for(path)
      read(path, false)
    end

    def build_str(source, rel_path, options = {})
      return if source.nil?
      @build_time = Time.now
      abs_path = expand_path(rel_path)
      setup_project(abs_path)
      rel_path = expand_ext(rel_path)
      asset = processor_for(source, rel_path, abs_path, false, options)
      requires = preload + asset.requires + tree_requires(asset, abs_path)
      # Don't automatically load modules required by the module
      process_requires(rel_path, requires, asset.autoloads, options.merge(load: false))
      processed << asset
      self
    end

    def build_require(path, options = {})
      process_require(path, [], options)
    end

    def initialize_copy(other)
      super
      @stubs = other.stubs.dup
      @preload = other.preload.dup
      @processors = other.processors.dup
      @path_reader = other.path_reader.dup
      @projects = other.projects.dup
      @prerequired = other.prerequired.dup
      @compiler_options = other.compiler_options.dup
      @missing_require_severity = other.missing_require_severity.to_sym
      @processed = other.processed.dup
      @scheduler = other.scheduler.dup.tap { |i| i.builder = self }
    end

    def to_s
      processed.map(&:to_s).join("\n")
    end

    def source_map
      ::Opal::SourceMap::Index.new(processed.map(&:source_map), join: "\n")
    end

    def append_paths(*paths)
      paths.each { |i| setup_project(i) }
      path_reader.append_paths(*paths)
    end

    def process_require_threadsafely(rel_path, autoloads, options)
      return if prerequired.include?(rel_path)

      autoload = autoloads.include? rel_path

      source = stub?(rel_path) ? '' : read(rel_path, autoload)

      # The handling is delegated to the runtime
      return if source.nil?

      abs_path = expand_path(rel_path)
      rel_path = expand_ext(rel_path)
      asset = processor_for(source, rel_path, abs_path, autoload, options.merge(requirable: true))
      process_requires(
        rel_path,
        asset.requires + tree_requires(asset, abs_path),
        asset.autoloads,
        options
      )
      asset
    end

    def process_require(rel_path, autoloads, options)
      return if already_processed.include?(rel_path)
      already_processed << rel_path
      asset = process_require_threadsafely(rel_path, autoloads, options)
      processed << asset if asset
    end

    def already_processed
      @already_processed ||= Set.new
    end

    attr_reader :processed

    attr_accessor :processors, :path_reader, :stubs, :prerequired, :preload,
      :compiler_options, :missing_require_severity, :cache, :scheduler, :build_time

    def esm?
      @compiler_options[:esm]
    end

    # Output extension, to be used by runners. At least Node.JS switches
    # to ESM mode only if the extension is "mjs"
    def output_extension
      esm? ? 'mjs' : 'js'
    end

    # Return a list of dependent files, for watching purposes
    def dependent_files
      processed.map(&:abs_path).compact.select { |fn| File.exist?(fn) }
    end

    def expand_ext(path)
      abs_path = path_reader.expand(path)

      if abs_path
        File.join(
          File.dirname(path),
          File.basename(abs_path)
        )
      else
        path
      end
    end

    # Output method #compiled_source aims to replace #to_s
    def compiled_source(with_source_map: true)
      compiled_source = to_s
      compiled_source += "\n" + source_map.to_data_uri_comment if with_source_map
      compiled_source
    end

    private

    def process_requires(rel_path, requires, autoloads, options)
      @scheduler.process_requires(rel_path, requires, autoloads, options)
    end

    def tree_requires(asset, asset_path)
      dirname = asset_path.to_s.empty? ? Pathname.pwd : Pathname(asset_path).expand_path.dirname
      abs_base_paths = path_reader.paths.map { |p| File.expand_path(p) }

      asset.required_trees.flat_map do |tree|
        abs_tree_path = dirname.join(tree).expand_path.to_s
        abs_base_path = abs_base_paths.find { |p| abs_tree_path.start_with?(p) }

        if abs_base_path
          abs_base_path = Pathname(abs_base_path)
          entries_glob  = Pathname(abs_tree_path).join('**', "*{.js,}.{#{extensions.join ','}}")
          Pathname.glob(entries_glob).map do |file|
            if file.extname == '.rb'
              # remove .rb so file can be found in already_processed
              file.relative_path_from(abs_base_path).to_s.delete_suffix('.rb')
            else
              file.relative_path_from(abs_base_path).to_s
            end
          end
        else
          [] # the tree is not part of any known base path
        end
      end
    end

    def processor_for(source, rel_path, abs_path, autoload, options)
      processor = processors.find { |p| p.match? abs_path }

      if !processor && !autoload
        raise(ProcessorNotFound, "can't find processor for rel_path: " \
                                 "#{rel_path.inspect}, "\
                                 "abs_path: #{abs_path.inspect}, "\
                                 "source: #{source.inspect}, "\
                                 "processors: #{processors.inspect}"
             )
      end

      options = options.merge(cache: cache)

      processor.new(source, rel_path, abs_path, @compiler_options.merge(options))
    end

    def read(path, autoload)
      path_reader.read(path) || begin
        print_list = ->(list) { "- #{list.join("\n- ")}\n" }
        message = "can't find file: #{path.inspect} in:\n" +
                  print_list[path_reader.paths] +
                  "\nWith the following projects loaded:\n" +
                  print_list[all_projects.map(&:root_dir)] +
                  "\nWith the following extensions:\n" +
                  print_list[path_reader.extensions] +
                  "\nAnd the following processors:\n" +
                  print_list[processors]

        unless autoload
          case missing_require_severity
          when :error   then raise MissingRequire, message
          when :warning then warn message
          when :ignore  then # noop
          end
        end

        nil
      end
    end

    def expand_path(path)
      return if stub?(path)
      path = (path_reader.expand(path) || File.expand_path(path)).to_s
      path if File.exist?(path)
    end

    def stub?(path)
      stubs.include?(path)
    end

    def extensions
      ::Opal::Builder.extensions
    end
  end
end

require 'opal/builder/processor'
