require 'opal/compiler'
require 'opal/path_reader'
require 'opal/erb'

module Opal
  class Builder
    def initialize(options = {})
      @compiler_options   = options.delete(:compiler_options)   || {}
      @stubbed_files      = options.delete(:stubbed_files)      || []
      @path_reader        = options.delete(:path_reader)        || PathReader.new
      @compiler_class     = options.delete(:compiler_class)     || Compiler
      @erb_compiler_class = options.delete(:erb_compiler_class) || Opal::ERB::Compiler
      raise ArgumentError, "unknown options: #{options.keys.join(', ')}" unless options.empty?
    end

    def build(path, prerequired = [])
      source = path_reader.read(path)
      build_str(source, path, prerequired)
    end

    def build_str(source, path = '(file)', prerequired = [])
      compiler = compiler_for(source, :file => path)
      compiler.compile
      sources = []
      compiled_requires = {}
      prerequired.each {|pr| compiled_requires[pr] = true}

      compiler.requires.uniq.each { |r| compile_require(r, sources, compiled_requires) }

      sources << compiler.result
      prerequired.concat(compiled_requires.keys)
      sources.join("\n")
    end


    private

    def javascript? path
      path.end_with?('.js')
    end

    def stubbed? file
      stubbed_files.include? file
    end

    def erb? path
      path.end_with?('.opalerb')
    end

    def compile_require r, sources, compiled_requires
      return if compiled_requires.has_key?(r)
      compiled_requires[r] = true
      require_source = stubbed?(r) ? '' : path_reader.read(r)

      if javascript?(r)
        sources << require_source
        require_source = ''
      end

      require_source = prepare_erb(require_source, r) if erb?(r)
      require_compiler = compiler_for(require_source, :file => r, :requirable => true)
      require_compiler.compile
      require_compiler.requires.each { |r| compile_require(r, sources, compiled_requires) }
      sources << require_compiler.result
    end

    def prepare_erb(source, path)
      erb_compiler = erb_compiler_class.new(source, path)
      erb_compiler.prepared_source
    end

    def compiler_for(source, options = {})
      compiler_class.new(source, compiler_options.merge(options))
    end

    attr_reader :compiler_class, :path_reader, :compiler_options, :stubbed_files,
                :erb_compiler_class
  end
end
