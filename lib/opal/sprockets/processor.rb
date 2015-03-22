require 'set'
require 'tilt'
require 'sprockets'
require 'opal/version'
require 'opal/builder'
require 'opal/sprockets/path_reader'
require 'opal/sprockets/source_map_server'

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
    end

    self.method_missing_enabled      = true
    self.arity_check_enabled         = false
    self.const_missing_enabled       = true
    self.dynamic_require_severity    = :error # :error, :warning or :ignore
    self.source_map_enabled          = true
    self.irb_enabled                 = false
    self.inline_operators_enabled    = false


    def evaluate(context, locals, &block)
      return Opal.compile data, file: file unless context.is_a? ::Sprockets::Context

      sprockets        = context.environment
      logical_path     = context.logical_path
      compiler_options = self.class.compiler_options.merge(file: logical_path)

      compiler = Compiler.new(data, compiler_options)
      result = compiler.compile

      compiler.requires.each do |required|
        context.require_asset required unless stubbed_files.include? required
      end

      if self.class.source_map_enabled
        map_contents = compiler.source_map.as_json.to_json
        ::Opal::SourceMapServer.set_map_cache(sprockets, logical_path, map_contents)
      end

      result.to_s
    end

    def self.load_asset_code(sprockets, name)
      asset = sprockets[name.sub(/(\.js)?$/, '.js')]
      return '' if asset.nil?

      module_name = -> asset { asset.logical_path.sub(/\.js$/, '') }
      mark_as_loaded = -> path { "Opal.mark_as_loaded(#{path.inspect});" }
      processed_by_opal = -> asset, sprockets {
        attributes = ::Sprockets::AssetAttributes.new(sprockets, asset.pathname)
        attributes.engines.any? { |engine| engine <= ::Opal::Processor }
      }

      non_opal_assets = ([asset]+asset.dependencies)
        .select { |asset| not(processed_by_opal[asset, sprockets]) }
        .map { |asset| module_name[asset] }

      mark_as_loaded = (non_opal_assets + stubbed_files.to_a)
        .map { |path| mark_as_loaded[path] }

      <<-JS
      if (typeof(Opal) !== 'undefined') {
        #{mark_as_loaded.join("\n")}
        Opal.load(#{module_name[asset].inspect});
      }
      JS
    end

    def self.stubbed_files
      @stubbed_files ||= Set.new
    end

    def self.stub_file(name)
      stubbed_files << name.to_s
    end

    def stubbed_files
      self.class.stubbed_files
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
  end
end

Tilt.register 'rb',               Opal::Processor
Sprockets.register_engine '.rb',  Opal::Processor

Tilt.register 'opal',               Opal::Processor
Sprockets.register_engine '.opal',  Opal::Processor
