# frozen_string_literal: true

require 'opal/path_reader'
require 'opal/paths'
require 'opal/config'
require 'opal/cache'
require 'set'

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
      read(path)
    end

    def build_str(source, rel_path, options = {})
      return if source.nil?
      abs_path = expand_path(rel_path)
      rel_path = expand_ext(rel_path)
      asset = processor_for(source, rel_path, abs_path, options)
      requires = preload + asset.requires + tree_requires(asset, abs_path)
      requires.map { |r| process_require(r, options) }
      processed << asset
      self
    rescue MissingRequire => error
      raise error, "A file required by #{rel_path.inspect} wasn't found.\n#{error.message}", error.backtrace
    end

    def build_require(path, options = {})
      process_require(path, options)
    end

    def initialize_copy(other)
      super
      @stubs = other.stubs.dup
      @preload = other.preload.dup
      @processors = other.processors.dup
      @path_reader = other.path_reader.dup
      @prerequired = other.prerequired.dup
      @compiler_options = other.compiler_options.dup
      @missing_require_severity = other.missing_require_severity.to_sym
      @processed = other.processed.dup
    end

    def to_s
      processed.map(&:to_s).join("\n")
    end

    def source_map
      ::Opal::SourceMap::Index.new(processed.map(&:source_map), join: "\n")
    end

    def append_paths(*paths)
      path_reader.append_paths(*paths)
    end

    include UseGem

    attr_reader :processed

    attr_accessor :processors, :path_reader, :stubs, :prerequired, :preload,
      :compiler_options, :missing_require_severity

    attr_writer :cache
    def cache
      @cache || Opal.cache
    end

    private

    def tree_requires(asset, asset_path)
      dirname = asset_path.to_s.empty? ? Pathname.pwd : Pathname(asset_path).expand_path.dirname
      abs_base_paths = path_reader.paths.map { |p| File.expand_path(p) }

      asset.required_trees.flat_map do |tree|
        abs_tree_path = dirname.join(tree).expand_path.to_s
        abs_base_path = abs_base_paths.find { |p| abs_tree_path.start_with?(p) }

        if abs_base_path
          abs_base_path = Pathname(abs_base_path)
          entries_glob  = Pathname(abs_tree_path).join('**', "*{.js,}.{#{extensions.join ','}}")

          Pathname.glob(entries_glob).map { |file| file.relative_path_from(abs_base_path).to_s }
        else
          [] # the tree is not part of any known base path
        end
      end
    end

    def processor_for(source, rel_path, abs_path, options)
      processor = processors.find { |p| p.match? abs_path } ||
                  raise(ProcessorNotFound, "can't find processor for rel_path: " \
                                           "#{rel_path.inspect}, "\
                                           "abs_path: #{abs_path.inspect}, "\
                                           "source: #{source.inspect}, "\
                                           "processors: #{processors.inspect}"
                  )

      options = options.merge(cache: cache)

      processor.new(source, rel_path, @compiler_options.merge(options))
    end

    def read(path)
      path_reader.read(path) || begin
        print_list = ->(list) { "- #{list.join("\n- ")}\n" }
        message = "can't find file: #{path.inspect} in:\n" +
                  print_list[path_reader.paths] +
                  "\nWith the following extensions:\n" +
                  print_list[path_reader.extensions] +
                  "\nAnd the following processors:\n" +
                  print_list[processors]

        case missing_require_severity
        when :error   then raise MissingRequire, message
        when :warning then warn message
        when :ignore  then # noop
        end

        nil
      end
    end

    def process_require(rel_path, options)
      return if prerequired.include?(rel_path)
      return if already_processed.include?(rel_path)
      already_processed << rel_path

      source = stub?(rel_path) ? '' : read(rel_path)

      # The handling is delegated to the runtime
      return if source.nil?

      abs_path = expand_path(rel_path)
      rel_path = expand_ext(rel_path)
      asset = processor_for(source, rel_path, abs_path, options.merge(requirable: true))
      process_requires(rel_path, asset.requires + tree_requires(asset, abs_path), options)
      processed << asset
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

    def expand_path(path)
      return if stub?(path)
      (path_reader.expand(path) || File.expand_path(path)).to_s
    end

    def process_requires(rel_path, requires, options)
      requires.map { |r| process_require(r, options) }
    rescue MissingRequire => error
      raise error, "A file required by #{rel_path.inspect} wasn't found.\n#{error.message}", error.backtrace
    end

    def already_processed
      @already_processed ||= Set.new
    end

    def stub?(path)
      stubs.include?(path)
    end

    def extensions
      ::Opal::Builder.extensions
    end
  end
end
