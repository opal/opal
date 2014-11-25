require 'opal/builder/path_reader'
require 'opal/builder/processors'
require 'opal/builder/cached_asset'
require 'set'

module Opal
  class Builder
    include BuilderProcessors

    attr_accessor :cache_store

    # A set of paths which have been processed already.
    attr_reader :processed

    # Array of compiled assets (either cached, or re-processed).
    attr_reader :assets

    def initialize(options = nil)
      (options || {}).each_pair do |k,v|
        public_send("#{k}=", v)
      end

      @compiler_options  ||= {}
      @default_processor ||= RubyProcessor
      @processors  ||= DEFAULT_PROCESSORS
      @stubs       ||= []
      @preload     ||= []
      @prerequired ||= []
      @path_reader ||= PathReader.new

      @processed = Set.new

      @assets = []
    end

    def self.build(*args, &block)
      new.build(*args, &block)
    end

    def build(path, options = {})
      source = read path
      build_str source, path, options
      self
    end

    def build_str(source, filename, options = {})
      fname = path_reader.expand(filename).to_s
      asset = processor_for(source, filename, fname, requirable: false)

      preload.each { |p| process_require p, options }

      process_requires asset, fname, options
      @assets << asset
      self
    end

    def build_require(path, options = {})
      process_require(path, options)
    end

    def process_require(filename, options)
      return if prerequired.include?(filename)
      return if processed.include? filename
      processed << filename

      path  = path_reader.expand(filename).to_s
      asset = find_asset filename

      process_requires asset, path, options

      @assets << asset
    end

    def process_requires(asset, path, options)
      (asset.requires + tree_requires(asset, path)).each do |require_path|
        process_require require_path, options
      end
    end

    def find_asset(path)
      cached_asset(path) do
        source = stub?(path) ? '' : read(path)

        if source.nil?
          message = "can't find file: #{filename.inspect}"
          case @compiler_options[:dynamic_require_severity]
          when :error then raise LoadError, message
          when :warning then warn "can't find file: #{filename.inspect}"
          end
        end

        fname  = path_reader.expand(path).to_s

        asset = processor_for(source, path, fname, requirable: true)
        stat  = stat(path)
        # TODO: fixme - processors should do this
        asset.mtime = stat(path).mtime.to_i if stat

        asset
      end
    end

    def cached_asset(path)
      if cache_store.nil?
        yield
      elsif (asset = cache_store[path]) && asset.fresh?(self, path)
        asset
      else
        asset = yield

        # TODO: cache asset (should check for cache_store first)
        cache_store[path] = asset

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




    def tree_requires(asset, path)
      if path.nil? or path.empty?
        dirname = Dir.pwd
      else
        dirname = File.dirname(File.expand_path(path))
      end

      paths = path_reader.paths.map{|p| File.expand_path(p)}

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

    def processor_for(source, filename, path, options)
      processor   = processors.find { |p| p.match? path }
      processor ||= default_processor
      return processor.new(source, filename, compiler_options.merge(options))
    end

    def read(path)
      path_reader.read(path) or
        raise ArgumentError, "can't find file: #{path.inspect} in #{path_reader.paths.inspect}"
    end

    def stat(path)
      path_reader.stat(path)
    end

    def stub?(filename)
      stubs.include?(filename)
    end

    def extensions
      @extensions ||= DEFAULT_PROCESSORS.flat_map(&:extensions).compact
    end
  end
end
