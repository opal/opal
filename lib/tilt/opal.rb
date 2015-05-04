require 'tilt'
require 'opal/compiler'
require 'opal/version'

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
  #   * irb_enabled                 [false by default]
  #   * inline_operators_enabled    [false by default]
  #
  class Processor < Tilt::Template
    class << self
      attr_accessor :method_missing_enabled
      attr_accessor :arity_check_enabled
      attr_accessor :const_missing_enabled
      attr_accessor :dynamic_require_severity
      attr_accessor :irb_enabled
      attr_accessor :inline_operators_enabled
    end

    self.method_missing_enabled      = true
    self.arity_check_enabled         = false
    self.const_missing_enabled       = true
    self.dynamic_require_severity    = :error # :error, :warning or :ignore
    self.irb_enabled                 = false
    self.inline_operators_enabled    = true

    self.default_mime_type = 'application/javascript'

    def self.inherited(subclass)
      subclass.default_mime_type = default_mime_type
    end

    def self.engine_initialized?
      true
    end

    def self.version
      ::Opal::VERSION
    end

    def self.compiler_options
      {
        :method_missing           => method_missing_enabled,
        :arity_check              => arity_check_enabled,
        :const_missing            => const_missing_enabled,
        :dynamic_require_severity => dynamic_require_severity,
        :irb                      => irb_enabled,
        :inline_operators         => inline_operators_enabled,
        :requirable               => true,
      }
    end

    module InstanceMethods
      def initialize_engine
        require_template_library 'opal'
      end

      def prepare
      end

      def evaluate(context, locals, &block)
        compiler_options = self.compiler_options.merge(file: file)
        compiler = Compiler.new(data, compiler_options)
        compiler.compile.to_s
      end

      def compiler_options
        # Not using self.class because otherwise would check subclasses for
        # attr_accessors they have but are not set.
        ::Opal::Processor.compiler_options
      end
    end

    include InstanceMethods
  end
end

Tilt.register 'rb',   Opal::Processor
Tilt.register 'opal', Opal::Processor
