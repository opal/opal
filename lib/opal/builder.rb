require 'opal/compiler'
require 'opal/path_reader'
require 'opal/erb'

module Opal
  class Builder
    def initialize(options = {})
      @compiler_options   = options.delete(:compiler_options)   || {}
      @stubbed_files      = options.delete(:stubbed_files)      || []
      @path_finder        = options.delete(:path_finder)        || HikePathFinder.new
      @path_reader        = options.delete(:path_reader)        || PathReader.new(path_finder)
      @compiler_class     = options.delete(:compiler_class)
      @erb_compiler_class = options.delete(:erb_compiler_class) || Opal::ERB::Compiler
      raise ArgumentError, "unknown options: #{options.keys.join(', ')}" unless options.empty?
    end

    def build(path, options = {})
      source = path_reader.read(path)
      build_str(source, path, options)
    end

    def build_str(source, path = '(file)', options = {})
      stubbed_files = @stubbed_files + (options[:stubbed_files] || [])
      context = Context.new(options[:prerequired], stubbed_files)
      asset = RubyAsset.new(path, source, :requirable => false, :compiler_class => compiler_class, :compiler_options => compiler_options)
      asset.requires.each { |r| compile_require(r, context) }
      context.assets << asset
      context
    end


    private

    def javascript? path
      type_of(path) == :javascript
    end

    def stubbed? context, file
      context.stubbed_files.include? file
    end

    def erb? path
      type_of(path) == :opalerb
    end

    def type_of(path)
      case path
      when /\.js$/      then :javascript
      when /\.opalerb$/ then :opalerb
      else :ruby
      end
    end

    def compile_require r, context
      sources, compiled_requires = context.sources, context.compiled_requires
      return if context.include?(r)

      compiled_requires[r] = true
      options = {
        :requirable => true,
        :compiler_class => compiler_class,
        :erb_compiler_class => erb_compiler_class,
        :compiler_options => compiler_options,
      }

      asset =
        case
        when stubbed?(context, r) then StubbedAsset.new(r, nil, options)
        when javascript?(r)       then JSAsset.new(r, path_reader.read(r), options)
        when erb?(r)              then ERBAsset.new(r, path_reader.read(r), options)
        else                           RubyAsset.new(r, path_reader.read(r), options)
        end
      asset.requires.each { |r| compile_require(r, context) }
      context.assets << asset
    end

    attr_reader :compiler_class, :path_reader, :compiler_options, :stubbed_files,
                :erb_compiler_class, :path_finder





    # CLASSES

    class Context
      def initialize(prerequired = nil, stubbed_files = nil)
        @prerequired        = prerequired   || []
        @stubbed_files      = stubbed_files || []
        @compiled_requires  = {}
        @assets             = []
        @prerequired.each {|pr| @compiled_requires[pr] = true}
      end

      def include? path
        compiled_requires.has_key?(path) #or stubbed_files.include?(path)
      end

      def sources
        assets.map(&:source)
      end

      def to_s
        sources.join("\n")
      end
      alias to_str to_s

      def inspect
        to_s.inspect
      end

      def source_map
        ''
      end

      def == other
        super or to_s == other
      end

      attr_reader :compiled_requires, :assets, :prerequired, :stubbed_files
    end

    class Asset
      def initialize(*)
        @path = '(file)'
        @source = ''.freeze
        @requires = []
      end

      attr_reader :path, :source, :requires
    end

    class RubyAsset < Asset
      def initialize(path, source, options)
        super
        @path, @source, @options = path, source, options
        @compiler_class = options.delete(:compiler_class) || ::Opal::Compiler
      end
      attr_reader :options, :compiler_class

      def source
        compiled.result
      end

      def requires
        compiled.requires
      end

      def compiled
        @compiled ||= begin
          compiler = compiler_for(@source, :file => path)
          compiler.compile
          compiler
        end
      end

      def compiler_for(source, options = {})
        compiler_class.new(source, self.options.merge(options))
      end
    end

    class JSAsset < RubyAsset
      def initialize(*)
        super
        @js_source = @source
        @source = ''
      end

      def source
        [@js_source, super]
      end
    end

    class StubbedAsset < RubyAsset
      def initialize(*)
        super
        @source = ''
      end
    end

    class ERBAsset < RubyAsset
      def initialize(path, source, options)
        @erb_compiler_class = options[:erb_compiler_class] || Opal::ERB::Compiler
        source = prepare_erb(source, path)
        super
      end

      def prepare_erb(source, path)
        erb_compiler = erb_compiler_class.new(source, path)
        erb_compiler.prepared_source
      end

      attr_reader :erb_compiler_class

      def requires
        ['erb']+super
      end
    end


  end
end
