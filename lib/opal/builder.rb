require 'opal/path_reader'
require 'opal/builder_processors'
require 'opal/paths'
require 'set'

module Opal
  class Builder
    include BuilderProcessors

    class MissingRequire < LoadError
    end

    def initialize(options = nil)
      (options || {}).each_pair do |k,v|
        public_send("#{k}=", v)
      end

      @stubs             ||= []
      @preload           ||= []
      @processors        ||= DEFAULT_PROCESSORS
      @path_reader       ||= PathReader.new
      @prerequired       ||= []
      @compiler_options  ||= {}
      @default_processor ||= RubyProcessor

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
      path = path_reader.expand(filename).to_s unless stub?(filename)
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

    attr_accessor :processors, :default_processor, :path_reader,
                  :compiler_options, :stubs, :prerequired, :preload




    private

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
          Pathname(file).relative_path_from(Pathname(base)).to_s.gsub(/(\.js)?(\.(?:#{extensions.join '|'}))#{REGEXP_END}/, '')
        end
      end
    end

    def processor_for(source, filename, path, options)
      processor   = processors.find { |p| p.match? path }
      processor ||= default_processor
      o = processor.new(source, filename, compiler_options.merge(options))
      o.path=path
      return o
    end

    def read(path)

      r = path_reader.read(path)
      if ! r 
        warn "can't find file: #{path.inspect} in #{path_reader.paths.inspect}\n";
        return "";
        #raise MissingRequire, "can't find file: #{path.inspect} in #{path_reader.paths.inspect}"
      else
        return r
      end

    end
      

    def process_require(filename, options)
      #puts "process_require\t"+ filename + "\n"
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

      path = path_reader.expand(filename).to_s unless stub?(filename)
      #puts "/*process_require\t"+ filename  + "\t"+ path + "*/\n"

      asset = processor_for(source, filename, path, options.merge(requirable: true))

      process_requires(filename, asset.requires+tree_requires(asset, path), options)
      processed << asset
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
      @extensions ||= DEFAULT_PROCESSORS.flat_map(&:extensions).compact
    end
  end
end
