require 'opal/path_reader'
require 'opal/builder_processors'
require 'set'

module Opal
  class Builder
    include BuilderProcessors

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

      @processed = []
    end

    def self.build(*args, &block)
      new.build(*args, &block)
    end

    def build(path, options = {})
      source = path_reader.read(path)
      build_str(source, path, options)
    end

    def build_str source, filename, options = {}
      asset = processor_for(source, filename, options)
      requires = preload + asset.requires
      requires.map { |r| process_require(r, options) }
      processed << asset
      self
    end

    def build_require(path, options = {})
      process_require(path, options)
    end

    def to_s
      processed.map(&:to_s).join("\n")
    end

    def source_map
      processed.map(&:source_map).reduce(:+).to_s
    end

    attr_reader :processed

    attr_accessor :processors, :default_processor, :path_reader,
                  :compiler_options, :stubs, :prerequired, :preload




    private

    def processor_for(source, filename, options)
      unless stub?(filename)
        full_filename = path_reader.expand(filename).to_s
        processor = processors.find { |p| p.match? full_filename }
      end
      processor ||= default_processor
      asset = processor.new(source, filename, compiler_options.merge(options))
    end

    def process_require(filename, options)
      return if prerequired.include?(filename)
      return if already_processed.include?(filename)
      already_processed << filename

      source = stub?(filename) ? '' : path_reader.read(filename)
      raise ArgumentError, "can't find file: #{filename.inspect}" if source.nil?
      asset = processor_for(source, filename, options.merge(requirable: true))
      process_requires(asset, options)
      processed << asset
    end

    def process_requires(asset, options)
      asset.requires.map { |r| process_require(r, options) }
    end

    def already_processed
      @already_processed ||= Set.new
    end

    def stub? filename
      stubs.include?(filename)
    end
  end
end
