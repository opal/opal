require 'opal/compiler'
require 'opal/path_reader'

module Opal
  class NewBuilder
    def initialize(options = {}, path_reader = PathReader.new, compiler_class = CompilerWrapper)
      @options          = options
      @compiler_options = options[:compiler_options] || {}
      @stubbed_files    = options[:stubbed_files] || []
      @path_reader      = path_reader
      @compiler_class   = compiler_class
    end

    def build(path, prerequired = [])
      source = path_reader.read(path)
      build_str(source, path, prerequired)
    end

    def build_str(source, path = '(file)', prerequired = [])
      compiler = compiler_for(source, :file => path)
      sources = []
      compiled_requires = {}
      prerequired.each {|pr| compiled_requires[pr] = true}

      compiler.requires.uniq.each { |r| compile_require(r, sources, compiled_requires) }

      sources << compiler.compiled
      prerequired.concat(compiled_requires.keys)
      sources.join("\n")
    end


    private

    def javascript? path
      path.end_with?('.js')
    end

    def compile_require r, sources, compiled_requires
      return if compiled_requires.has_key?(r)
      compiled_requires[r] = true
      require_source = stubbed?(r) ? '' : path_reader.read(r)
      if javascript?(r)
        sources << require_source
      else
        require_compiler = compiler_for(require_source, :file => r, :requirable => true)
        require_compiler.requires.each { |r| compile_require(r, sources, compiled_requires) }
        sources << require_compiler.compiled
      end
    end

    def stubbed? file
      stubbed_files.include? file
    end

    def compiler_for(source, options = {})
      compiler_class.new(source, compiler_options.merge(options))
    end

    attr_reader :compiler_class, :path_reader, :compiler_options, :stubbed_files

    class CompilerWrapper
      def initialize(source, options)
        compiler = Compiler.new
        @compiled = compiler.compile(source, options)
        @requires = compiler.requires
      end
      attr_reader :compiled, :requires
    end
  end
end
