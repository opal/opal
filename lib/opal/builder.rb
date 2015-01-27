require 'opal/builder/path_reader'
require 'opal/builder/processors'
require 'opal/builder/asset'
require 'set'

module Opal
  class Builder
    include Processors

    # A Hash of extension names to their processor class.
    #
    # @returns [Hash]
    #
    def self.processors
      @processors ||= {}
    end

    # Register a new processor for the given extension type.
    #
    #     Opal::Builder.register_processor '.haml', HamlCompiler
    #
    # The builder will then delegate to the given processor every time
    # a '.haml' file is required as a dependency. The given processor
    # should inherit from [Opal::BuilderProcessors::Processor].
    #
    # @param [String] file_ext file extension to handle
    # @param [Class] processor a Processor subclass
    #
    def self.register_processor(file_ext, processor)
      processors[file_ext] = processor
    end

    # Register default processors.
    #
    register_processor '.js',       JsProcessor
    register_processor '.rb',       RubyProcessor
    register_processor '.opal',     RubyProcessor
    register_processor '.opalerb',  OpalERBProcessor
    register_processor '.erb',      ERBProcessor

    attr_accessor :cache_store

    # A set of paths which have been processed already.
    attr_reader :processed

    # Array of compiled assets (either cached, or re-processed).
    attr_reader :assets

    class MissingRequire < LoadError
    end

    def initialize(options = nil)
      (options || {}).each_pair do |k,v|
        public_send("#{k}=", v)
      end

      @stubs             ||= []
      @preload           ||= []
      @processors        ||= self.class.processors
      @path_reader       ||= PathReader.new
      @prerequired       ||= []
      @compiler_options  ||= {}
      @default_processor ||= RubyProcessor

      @processed = Set.new

      @assets = []
    end

    def self.build(*args, &block)
      new.build(*args, &block)
    end

    def build(logical_path, options = {})
      source = read logical_path
      build_str source, logical_path, options
      self
    end

    def build_str(source, logical_path, options = {})
      options = options.merge(requirable: false)
      process_string(source, logical_path, options)

      preload.each { |path| process_require path, options }

      self
    rescue MissingRequire => error
      raise error, "A file required by #{filename.inspect} wasn't found.\n#{error.message}"
    end

    # Build the given asset as a ruby source, ignoring any actual file
    # extension for asset.
    #
    # Handles a ruby file (on disk) as the entry point to the application.
    # This method ensures the file is compiled as a ruby source, irrelevant
    # of its actual file extension. This is useful in sprockets contexts
    # where a ruby file may be handled after it has been through other
    # engines, so its file extension might not identify it as a ruby
    # source.
    #
    def build_require(source, logical_path, options = {})
      process_string source, logical_path, options
    end

    # @private
    #
    # Process the given string as a ruby source, ignoring the path for
    # processor type. Used to force a processor for the given path
    # compilation.
    def process_string(source, logical_path, options)
      filename  = path_reader.expand(logical_path).to_s
      asset     = build_asset(source, logical_path, default_processor, options)

      process_requires(asset, filename, options)
      @assets << asset
    end

    def process_require(logical_path, options, processor = nil)
      return if prerequired.include?(logical_path)
      return if processed.include?(logical_path)
      processed << logical_path

      filename = path_reader.expand(logical_path).to_s
      asset = find_asset logical_path, options, processor

      process_requires asset, filename, options
      @assets << asset
    end

    def process_requires(asset, filename, options)
      (asset.requires + tree_requires(asset, filename)).each do |require_path|
        process_require require_path, options
      end
    rescue MissingRequire => error
      raise error, "A file required by #{filename.inspect} wasn't found.\n#{error.message}"
    end

    def find_asset(logical_path, options, processor = nil)
      cached_asset(logical_path) do
        source = stub?(logical_path) ? '' : read(logical_path)

        if source.nil?
          message = "can't find file: #{logical_path.inspect}"
          case @compiler_options[:dynamic_require_severity]
          when :error then raise LoadError, message
          when :warning then warn "can't find file: #{logical_path.inspect}"
          end
        end

        filename    = path_reader.expand(logical_path).to_s
        processor ||= processor_for(filename)

        build_asset(source, logical_path, processor, options.merge(requirable: true))
      end
    end

    def processor_for(filename)
      extname = File.extname(filename)
      processors.fetch(extname) { default_processor }
    end

    def build_asset(source, logical_path, processor, options)
      options   = compiler_options.merge(options)

      result = processor.new(source, logical_path, options)

      data = {
        :source           => result.source,
        :requires         => result.requires,
        :required_trees   => result.required_trees,
        :source_map       => result.source_map.as_json,
        :logical_path     => logical_path,
      }

      if stat = stat(logical_path)
        data[:mtime] = stat.mtime.to_i
      end

      Asset.new(data)
    end

    def cached_asset(logical_path)
      if cache_store.nil?
        yield
      elsif (asset = cache_store[logical_path]) && asset.fresh?(self, logical_path)
        asset
      else
        asset = yield

        # TODO: cache asset (should check for cache_store first)
        cache_store[logical_path] = asset

        asset
      end
    end

    def to_s
      assets.map(&:to_s).join("\n")
    end

    def source_map
      assets.map(&:source_map).reduce(:+).as_json.to_json
    end

    attr_accessor :processors, :default_processor, :path_reader,
                  :compiler_options, :stubs, :prerequired, :preload




    def tree_requires(asset, filename)
      if filename.nil? or filename.empty?
        dirname = Dir.pwd
      else
        dirname = File.dirname(File.expand_path(filename))
      end

      paths = path_reader.paths.map { |p| File.expand_path(p) }

      asset.required_trees.flat_map do |tree|
        expanded = File.expand_path(tree, dirname)
        base = paths.find { |p| expanded.start_with?(p) }
        next [] if base.nil?

        globs = extensions.map { |ext| File.join base, tree, '**', "*.#{ext}" }

        Dir[*globs].map do |file|
          Pathname(file).relative_path_from(Pathname(base)).to_s.gsub(/(\.js)?(\.(?:#{extensions.join '|'}))$/, '')
        end
      end
    end

    def read(logical_path)
      path_reader.read(logical_path) or
        raise MissingRequire, "can't find file: #{logical_path.inspect} in #{path_reader.paths.inspect}"
    end

    def stat(logical_path)
      path_reader.stat(logical_path)
    end

    def stub?(logical_path)
      stubs.include?(logical_path)
    end

    def extensions
      @extensions ||= processors.keys.map { |ext| ext[1..-1] }
    end
  end
end
