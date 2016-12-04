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
    #   Opal::Sprockets.load_asset(Rails.application.assets, 'application')
    #
    # @example Will output the following JavaScript:
    #
    #   if (typeof(Opal) !== 'undefined') {
    #     Opal.loaded("opal");
    #     Opal.loaded("jquery.self");
    #     Opal.load("application");
    #   }
    #
    # @param name      [String] The logical name of the main asset to be loaded (without extension)
    # @param sprockets [Sprockets::Environment]
    #
    # @return [String] JavaScript code
    def self.load_asset(name, sprockets, asset = nil)
      asset ||= sprockets[name.sub(/(\.(js|rb|opal))*#{REGEXP_END}/, '.js')]
      return '' if asset.nil?

      opal_extnames = sprockets.engines.map do |ext, engine|
        ext if engine <= ::Opal::Processor
      end.compact

      module_name       = -> asset { asset.logical_path.sub(/\.js#{REGEXP_END}/, '') }
      path_extnames     = -> path  { File.basename(path).scan(/\.[^.]+/) }
      mark_loaded       = -> paths { "Opal.loaded([#{paths.map(&:inspect).join(',')}]);" }
      processed_by_opal = -> asset { (path_extnames[asset.pathname] & opal_extnames).any? }
      stubbed_files     = ::Opal::Config.stubbed_files

      non_opal_assets = ([asset]+asset.dependencies)
        .select { |asset| not(processed_by_opal[asset]) }
        .map { |asset| module_name[asset] }

      loaded = ['opal'] + non_opal_assets + stubbed_files.to_a

      if processed_by_opal[asset]
        load_asset_code = "Opal.load(#{module_name[asset].inspect});"
      end


      "if (typeof(Opal) !== 'undefined') { "\
        "#{mark_loaded[loaded]} "\
        "#{load_asset_code} "\
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

      unless main.include? name.to_s
        scripts << %{<script>#{::Opal::Sprockets.load_asset(name, sprockets)}</script>}
      end

      scripts.join "\n"
    end

    # Mark an opal asset to collapse all of its dependencies to avoid bloat.
    #
    # @example Treat opal internals as a black-box
    #
    #   Opal::Sprockets.collapsed << 'opal' # won't show individual corelib files
    #
    # @return [Set<String>] A modifiable Set of logical paths (without extension)
    def self.collapsed
      @collapsed ||= Set.new
    end

    # Mark an opal asset as a main file, thus not needing loading code.
    # The loading code will be automatically appended at the end of the file.
    #
    # Once an asset is marked as such it's not expected to be required by other
    # assets, in a typical Rails application the manifest will be `application`.
    #
    # @example Mark "app/assets/application.js.rb" as a main file
    #
    # Opal::Sprockets.main  << 'application' # won't need loading code
    #
    # @return [Set<String>] A modifiable Set of logical paths (without extension)
    def self.main
      @main ||= Set.new
    end
  end
end
