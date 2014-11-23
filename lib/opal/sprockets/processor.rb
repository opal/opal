require 'set'
require 'tilt'
require 'sprockets'
require 'opal/version'
require 'opal/builder'
require 'opal/sprockets/path_reader'

$OPAL_SOURCE_MAPS = {}

module Opal
  # The Processor class is used to make ruby files (with rb or opal extensions)
  # available to any sprockets based server. Processor will then get passed any
  # ruby source file to build. There are some options you can override globally
  # which effect how certain ruby features are handled:
  #
  #   * method_missing_enabled      [true by default]
  #   * arity_check_enabled         [false by default]
  #   * const_missing_enabled       [true by default]
  #   * dynamic_require_severity    [:error by default]
  #   * source_map_enabled          [true by default]
  #   * irb_enabled                 [false by default]
  #   * inline_operators_enabled    [false by default]
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
      attr_accessor :inline_operators_enabled

      attr_accessor :source_map_register
    end

    self.method_missing_enabled      = true
    self.arity_check_enabled         = false
    self.const_missing_enabled       = true
    self.dynamic_require_severity    = :error # :error, :warning or :ignore
    self.source_map_enabled          = true
    self.irb_enabled                 = false

    self.source_map_register         = $OPAL_SOURCE_MAPS


    def evaluate(context, locals, &block)
      return Opal.compile data unless context.is_a? ::Sprockets::Context

      path = context.logical_path
      prerequired = []

      builder = self.class.new_builder(context)
      builder.build(path, :prerequired => prerequired)

      if self.class.source_map_enabled
        register_source_map(context.logical_path, builder.source_map.to_s)
        "#{builder.to_s}\n//# sourceMappingURL=#{File.basename(context.logical_path)}.map\n"
      else
        builder.to_s
      end
    end

    def register_source_map path, map_contents
      self.class.source_map_register[path] = map_contents
    end

    def self.stubbed_files
      @stubbed_files ||= []
    end

    def self.stub_file(name)
      stubbed_files << name.to_s
    end

    def stubbed_files
      self.class.stubbed_files
    end

    def self.new_builder(context)
      compiler_options = {
        :method_missing           => method_missing_enabled,
        :arity_check              => arity_check_enabled,
        :const_missing            => const_missing_enabled,
        :dynamic_require_severity => dynamic_require_severity,
        :irb                      => irb_enabled,
        :inline_operators         => inline_operators_enabled,
      }

      path_reader = ::Opal::Sprockets::PathReader.new(context.environment, context)
      cache_store = ::Opal::Sprockets::CacheStore.new(context.environment)

      return Builder.new(
        compiler_options: compiler_options,
        stubs:            stubbed_files,
        path_reader:      path_reader,
        cache_store:      cache_store
      )
    end
  end
end

Tilt.register 'rb',               Opal::Processor
Sprockets.register_engine '.rb',  Opal::Processor

Tilt.register 'opal',               Opal::Processor
Sprockets.register_engine '.opal',  Opal::Processor
