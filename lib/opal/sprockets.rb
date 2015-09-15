require 'opal/sprockets/processor'
require 'opal/sprockets/erb'
require 'opal/sprockets/server'

module Opal
  module Sprockets
    # Public: Bootstraps modules loaded by sprockets on `Opal.modules` marking any
    #   non-Opal asset as already loaded.
    #
    # name      - The name of the main asset to be loaded (with or without ext)
    # sprockets - A Sprockets::Environment instance
    #
    # Example
    #
    #   Opal::Sprockets.load_asset(Rails.application.assets, 'application')
    #
    # Will output the following JavaScript:
    #
    #   if (typeof(Opal) !== 'undefined') {
    #     Opal.mark_as_loaded("opal");
    #     Opal.mark_as_loaded("jquery.self");
    #     Opal.load("application");
    #   }
    #
    # Returns a String containing JavaScript code.
    def self.load_asset(name, sprockets)
      asset = sprockets[name.sub(/(\.(js|rb|opal))*#{REGEXP_END}/, '.js')]
      return '' if asset.nil?

      opal_extnames = sprockets.engines.map do |ext, engine|
        ext if engine <= ::Opal::Processor
      end.compact

      module_name       = -> asset { asset.logical_path.sub(/\.js#{REGEXP_END}/, '') }
      path_extnames     = -> path  { File.basename(path).scan(/\.[^.]+/) }
      loaded            = -> path  { "Opal.loaded(#{path.inspect});" }
      processed_by_opal = -> asset { (path_extnames[asset.pathname] & opal_extnames).any? }
      stubbed_files     = ::Opal::Processor.stubbed_files

      non_opal_assets = ([asset]+asset.dependencies)
        .select { |asset| not(processed_by_opal[asset]) }
        .map { |asset| module_name[asset] }

      loaded = (['opal'] + non_opal_assets + stubbed_files.to_a)
        .map { |path| loaded[path] }

      if processed_by_opal[asset]
        load_asset_code = "Opal.load(#{module_name[asset].inspect});"
      end

      <<-JS
      if (typeof(Opal) !== 'undefined') {
        #{loaded.join("\n")}
        #{load_asset_code}
      }
      JS
    end

    # Public: Generate a `<script>` tag for Opal assets.
    #
    # name    - The name of the asset to be loaded
    # options - (default: {}):
    #   :sprockets - A Sprockets::Environment instance
    #   :prefix    - The prefix String at which is mounted Sprockets
    #   :debug     - Wether to enable debug mode along with sourcemaps support
    #
    # Returns a string of HTML code containing `<script>` tags.
    def self.javascript_include_tag(name, options = {})
      sprockets = options.fetch(:sprockets)
      prefix    = options.fetch(:prefix)
      debug     = options.fetch(:debug)

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

      scripts << %{<script>#{::Opal::Sprockets.load_asset(name, sprockets)}</script>}

      scripts.join "\n"
    end
  end
end
