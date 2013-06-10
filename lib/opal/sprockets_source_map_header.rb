require 'sprockets/server'

module Sprockets
  module Server

    # Adds the source map header to all sprocket responses for assets
    # with a .rb or .opal extension in the extension chain.
    def headers_with_opal_source_maps(env, asset, length)
      headers_without_opal_source_maps(env, asset, length).tap do |headers|
        if asset.pathname.to_s =~ /\.(rb|opal)\b/
          headers['X-SourceMap'] = '/__opal_source_maps__/'+asset.logical_path + '.map'
        end
      end
    end

    # Poor man's alias_method_chain :)
    alias headers_without_opal_source_maps headers
    alias headers headers_with_opal_source_maps

  end
end
