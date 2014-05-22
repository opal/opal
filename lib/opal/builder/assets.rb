Opal::Builder.class_eval do
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
      compiler_class.new(source, @options.merge(options))
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
