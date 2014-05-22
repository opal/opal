require 'opal/compiler'
require 'opal/path_reader'
require 'opal/erb'

module Opal
  class Builder
    def initialize(options = {})
      @compiler_options   = options.delete(:compiler_options)   || {}
      @path_reader        = options.delete(:path_reader)        || PathReader.new
      @compiler_class     = options.delete(:compiler_class)
      @erb_compiler_class = options.delete(:erb_compiler_class) || Opal::ERB::Compiler
      @prerequired        = options.delete(:prerequired)        || []
      @stubbed_files      = options.delete(:stubbed_files)      || []
      ensure_no_options_left(options)

      @context = Context.new(@prerequired, @stubbed_files)
    end

    def build(path, options = {})
      source = path_reader.read(path)
      build_str(source, path, options)
    end

    def build_str(source, path = '(file)', options = {})
      context.stub_files(options.delete(:stubbed_files) || [])
      context.prerequire(options.delete(:prerequired) || [])
      ensure_no_options_left(options)
      requirable = options.fetch(:requirable, false)

      asset = RubyAsset.new(path, source, :requirable => requirable, :compiler_class => compiler_class, :compiler_options => compiler_options)

      asset.requires.each { |r| compile_require(r, context) }
      context.assets << asset
      context
    end

    def to_s
      context.to_s
    end




    private

    def ensure_no_options_left(options)
      raise ArgumentError, "unknown options: #{options.keys.join(', ')}" unless options.empty?
    end

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
      asset = build_asset(r, context)
      return if asset.nil?
      asset.requires.each { |r| compile_require(r, context) }
      context.assets << asset
    end

    def build_asset(r, context)
      options = {
        :requirable => true,
        :compiler_class => compiler_class,
        :erb_compiler_class => erb_compiler_class,
      }.merge(compiler_options)

      source = path_reader.read(r)

      case
      when stubbed?(context, r) then StubbedAsset.new(r, source, options)
      when source.nil?          then nil
      when javascript?(r)       then JSAsset.new(r, source, options)
      when erb?(r)              then ERBAsset.new(r, source, options)
      else                           RubyAsset.new(r, source, options)
      end
    end

    attr_reader :compiler_class, :path_reader, :compiler_options, :stubbed_files,
                :erb_compiler_class, :context
  end
end

require 'opal/builder/context'
require 'opal/builder/assets'
