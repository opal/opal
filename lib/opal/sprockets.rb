require 'opal/sprockets/processor'
require 'opal/sprockets/erb'
require 'opal/sprockets/server'

module Opal
  module Sprockets
    # Bootstraps modules loaded by sprockets on `Opal.modules` marking any
    # non-Opal asset as already loaded.
    #
    # @example
    #
    #   Opal::Sprockets.load_asset('application')
    #
    # @example Will output the following JavaScript:
    #
    #   if (typeof(Opal) !== 'undefined') {
    #     Opal.loaded("opal");
    #     Opal.loaded("jquery.self");
    #     Opal.load("application");
    #   }
    #
    # @param name [String] The logical name of the main asset to be loaded (without extension)
    #
    # @return [String] JavaScript code
    def self.load_asset(name, _sprockets = :deprecated)
      if _sprockets != :deprecated && !@load_asset_warning_displayed
        @load_asset_warning_displayed = true
        warn "Passing a sprockets environment to Opal::Sprockets.load_asset no more needed.\n  #{caller(1, 3).join("\n  ")}"
      end

      name = name.sub(/(\.(js|rb|opal))*\z/, '')
      stubbed_files     = ::Opal::Config.stubbed_files

      loaded = ['opal', 'corelib/runtime'] + stubbed_files.to_a

      "if (typeof(Opal) !== 'undefined') { "\
        "Opal.loaded(#{loaded.to_json}); "\
        "if (typeof(OpalLoaded) === 'undefined') Opal.loaded(OpalLoaded); "\
        "if (Opal.modules[#{name.to_json}]) Opal.load(#{name.to_json}); "\
      "}"
    end

    # Generate a `<script>` tag for Opal assets.
    #
    # @param [String] name     The logical name of the asset to be loaded (without extension)
    # @param [Hash]   options  The options about sprockets
    # @option options [Sprockets::Environment] :sprockets  The sprockets instance
    # @option options [String]                 :prefix     The prefix String at which is mounted Sprockets, e.g. '/assets'
    # @option options [Boolean]                :debug      Wether to enable debug mode along with sourcemaps support
    #
    # @return a string of HTML code containing `<script>` tags.
    def self.javascript_include_tag(name, options = {})
      sprockets = options.fetch(:sprockets)
      prefix    = options.fetch(:prefix)
      debug     = options.fetch(:debug)

      # Avoid double slashes
      prefix = prefix.chop if prefix.end_with? '/'

      asset = sprockets[name]
      raise "Cannot find asset: #{name}" if asset.nil?
      scripts = []

      if debug
        asset.to_a.map do |dependency|
          scripts << %{<script src="#{prefix}/#{dependency.logical_path}?body=1"></script>}
        end
      else
        scripts << %{<script src="#{prefix}/#{name}.js"></script>}
      end

      scripts << %{<script>#{::Opal::Sprockets.load_asset(name)}</script>}

      scripts.join "\n"
    end
  end
end
