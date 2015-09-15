require 'opal/sprockets/processor'
require 'opal/sprockets/erb'
require 'opal/sprockets/server'

module Opal
  module Sprockets
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

      scripts << %{<script>#{Opal::Processor.load_asset_code(sprockets, name)}</script>}

      scripts.join "\n"
    end
  end
end
