# frozen_string_literal: true

require 'opal/path_reader'
require 'opal/paths'
require 'opal/config'
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
    # An instance of `::SourceMap::Map` representing the processd asset's source
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

      @stubs             ||= []
      @preload           ||= []
      @processors        ||= ::Opal::Builder.processors
      @path_reader       ||= PathReader.new(Opal.paths, extensions.map { |e| [".#{e}", ".js.#{e}"] }.flatten)
      @prerequired       ||= []
      @compiler_options  ||= Opal::Config.compiler_options

      @processed = []
    end

    def self.build(*args, &block)
      new.build(*args, &block)
    end

    def build(path, options = {})
      source = read(path)
      build_str(source, path, options)
    end

    def build_str source, filename, options = {}
      path = path_from_filename(filename)
      asset = processor_for(source, filename, path, options)
      requires = preload + asset.requires + tree_requires(asset, path)
      requires.map { |r| process_require(r, options) }
      processed << asset
      self
    rescue MissingRequire => error
      raise error, "A file required by #{filename.inspect} wasn't found.\n#{error.message}", error.backtrace
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
      @processed = other.processed.dup
    end

    def to_s
      processed.map(&:to_s).join("\n")
    end

    def source_map
      processed.map(&:source_map).reduce(:+).as_json.to_json
    end

    def append_paths(*paths)
      path_reader.append_paths(*paths)
    end

    include UseGem

    attr_reader :processed

    attr_accessor :processors, :path_reader, :compiler_options,
                  :stubs, :prerequired, :preload

    private

    def tree_requires(asset, path)
      if path.nil? or path.empty?
        dirname = Dir.pwd
      else
        dirname = File.dirname(File.expand_path(path))
      end

      paths = path_reader.paths.map { |p| File.expand_path(p) }

      asset.required_trees.flat_map do |tree|
        expanded = File.expand_path(tree, dirname)
        base = paths.find { |p| expanded.start_with?(p) }
        next [] if base.nil?

        globs = extensions.map { |ext| File.join base, tree, '**', "*.#{ext}" }

        Dir[*globs].map do |file|
          Pathname(file).relative_path_from(Pathname(base)).to_s.gsub(/(\.js)?(\.(?:#{extensions.join '|'}))#{REGEXP_END}/, '')
        end
      end
    end

    def processor_for(source, filename, path, options)
      processor = processors.find { |p| p.match? path } or
        raise ProcessorNotFound, "can't find processor for filename: #{filename.inspect}, path: #{path.inspect}, source: #{source.inspect}, processors: #{processors.inspect}"
      processor.new(source, filename, compiler_options.merge(options))
    end

    def read(path)
      path_reader.read(path) or begin
        print_list = lambda { |list| "- #{list.join("\n- ")}\n" }
        message = "can't find file: #{path.inspect} in:\n" +
                  print_list[path_reader.paths] +
                  "\nWith the following extensions:\n" +
                  print_list[path_reader.extensions] +
                  "\nAnd the following processors:\n" +
                  print_list[processors]

        case compiler_options[:dynamic_require_severity]
        when :raise   then raise MissingRequire, message
        when :warning then warn message
        else # noop
        end

        return "raise LoadError, #{message.inspect}"
      end
    end

    def process_require(filename, options)
      filename = filename.gsub(/\.(rb|js|opal)#{REGEXP_END}/, '')
      return if prerequired.include?(filename)
      return if already_processed.include?(filename)
      already_processed << filename

      source = stub?(filename) ? '' : read(filename)

      if source.nil?
        message = "can't find file: #{filename.inspect}"
        case @compiler_options[:dynamic_require_severity]
        when :error then raise LoadError, message
        when :warning then warn "can't find file: #{filename.inspect}"
        end
      end

      path = path_from_filename(filename)
      asset = processor_for(source, filename, path, options.merge(requirable: true))
      process_requires(filename, asset.requires + tree_requires(asset, path), options)
      processed << asset
    end

    def path_from_filename(filename)
      return if stub?(filename)
      (path_reader.expand(filename) || File.expand_path(filename)).to_s
    end

    def process_requires(filename, requires, options)
      requires.map { |r| process_require(r, options) }
    rescue MissingRequire => error
      raise error, "A file required by #{filename.inspect} wasn't found.\n#{error.message}", error.backtrace
    end

    def already_processed
      @already_processed ||= Set.new
    end

    def stub? filename
      stubs.include?(filename)
    end

    def extensions
      ::Opal::Builder.extensions
    end
  end
end
