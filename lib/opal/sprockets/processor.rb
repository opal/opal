require 'set'
require 'sprockets'
require 'opal/version'
require 'opal/new_builder'

$OPAL_SOURCE_MAPS = {}

module Opal
  # The Processor class is used to make ruby files (with rb or opal extensions)
  # available to any sprockets based server. Processor will then get passed any
  # ruby source file to build. There are some options you can override globally
  # which effect how certain ruby features are handled:
  #
  #   * method_missing_enabled      [true by default]
  #   * optimized_operators_enabled [true by default]
  #   * arity_check_enabled         [false by default]
  #   * const_missing_enabled       [true by default]
  #   * dynamic_require_severity    [true by default]
  #   * source_map_enabled          [true by default]
  #   * irb_enabled                 [false by default]
  #
  class Processor < Tilt::Template
    # vvv BOILERPLATE vvv
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      true
    end

    def self.version
      ::Opal::VERSION
    end

    def initialize_engine
      require_template_library 'opal'
    end

    def prepare
    end
    # ^^^ BOILERPLATE ^^^


    class << self
      attr_accessor :method_missing_enabled
      attr_accessor :arity_check_enabled
      attr_accessor :const_missing_enabled
      attr_accessor :dynamic_require_severity
      attr_accessor :source_map_enabled
      attr_accessor :irb_enabled
    end

    self.method_missing_enabled      = true
    self.arity_check_enabled         = false
    self.const_missing_enabled       = true
    self.dynamic_require_severity    = :error # :error, :warning or :ignore
    self.source_map_enabled          = true
    self.irb_enabled                 = false

    def self.stub_file(name)
      stubbed_files << name.to_s
    end

    def self.stubbed_files
      @stubbed_files ||= Set.new
    end

    class SprocketsPathReader
      def initialize(env)
        @env ||= env
      end

      def read path
        if path.end_with? '.js'
          env[path].to_s
        else
          File.read(env.resolve(path))
        end
      end

      attr_reader :env
    end

    def evaluate(context, locals, &block)
      options = {
        :method_missing           => self.class.method_missing_enabled,
        :arity_check              => self.class.arity_check_enabled,
        :const_missing            => self.class.const_missing_enabled,
        :dynamic_require_severity => self.class.dynamic_require_severity,
        :irb                      => self.class.irb_enabled,
      }

      path = context.logical_path
      prerequired = []

      builder = NewBuilder.new(
        :compiler_options => options,
        :stubbed_files    => stubbed_files,
        :path_reader      => SprocketsPathReader.new(context.environment)
      )
      result = builder.build_str(data, path, prerequired)

      # prerequired is mutated by the builder
      prerequired.uniq.each { |asset| context.depend_on_asset asset }

      if self.class.source_map_enabled
        $OPAL_SOURCE_MAPS[context.pathname] = '' #compiler.source_map(source_file_url(context)).to_s
        "#{result}\n//# sourceMappingURL=#{source_map_url(context)}\n"
      else
        result
      end
    end

    def source_map_url(context)
      "#{prefix}/#{context.logical_path}.js.map"
    end

    def source_file_url(context)
      "#{prefix}/#{context.logical_path.to_s}"
    end

    def prefix
      "/__opal_source_maps__"
    end

    def stubbed_file?(name)
      stubbed_files.include? name
    end

    def stubbed_files
      self.class.stubbed_files
    end

    def find_opal_require(environment, r)
      path = environment.paths.find do |p|
        File.exist?(File.join(p, "#{r}.rb"))
      end

      path ? File.join(path, "#{r}.rb") : r
    end
  end
end

Tilt.register 'rb',               Opal::Processor
Sprockets.register_engine '.rb',  Opal::Processor

Tilt.register 'opal',               Opal::Processor
Sprockets.register_engine '.opal',  Opal::Processor
