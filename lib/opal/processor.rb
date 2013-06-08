require 'sprockets'

module Opal
  # Proccess using Sprockets
  #
  #   Opal.process('opal-jquery')   # => String
  def self.process asset
    Environment.new[asset].to_s
  end

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
  #
  class Processor < Tilt::Template
    self.default_mime_type = 'application/javascript'

    def self.engine_initialized?
      true
    end

    class << self
      attr_accessor :method_missing_enabled
      attr_accessor :optimized_operators_enabled
      attr_accessor :arity_check_enabled
      attr_accessor :const_missing_enabled
      attr_accessor :dynamic_require_severity
      attr_accessor :source_map_enabled
    end

    self.method_missing_enabled      = true
    self.optimized_operators_enabled = true
    self.arity_check_enabled         = false
    self.const_missing_enabled       = true
    self.dynamic_require_severity    = :error # :error, :warning or :ignore
    self.source_map_enabled          = true

    def initialize_engine
      require_template_library 'opal'
    end

    def prepare
    end

    def evaluate(context, locals, &block)
      options = {
        :method_missing           => self.class.method_missing_enabled,
        :optimized_operators      => self.class.optimized_operators_enabled,
        :arity_check              => self.class.arity_check_enabled,
        :const_missing            => self.class.const_missing_enabled,
        :dynamic_require_severity => self.class.dynamic_require_severity,
        :source_map_enabled       => self.class.source_map_enabled,
        :file                     => context.logical_path,
        :source_file              => context.pathname.to_s
      }

      parser = Opal::Parser.new
      result = parser.parse data, options

      parser.requires.each { |r| context.require_asset r }
      result
    end
  end
end

Tilt.register 'rb',               Opal::Processor
Sprockets.register_engine '.rb',  Opal::Processor

Tilt.register 'opal',               Opal::Processor
Sprockets.register_engine '.opal',  Opal::Processor
