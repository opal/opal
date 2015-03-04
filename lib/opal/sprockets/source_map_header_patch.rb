require 'sprockets/server'

module Opal
  module Sprockets
    module SourceMapHeaderPatch
      # Adds the source map header to all sprocket responses for assets
      # with a .rb or .opal extension in the extension chain.
      def headers_with_opal_source_maps(env, asset, length)
        headers_without_opal_source_maps(env, asset, length).tap do |headers|
          if asset.pathname.to_s =~ /\.(rb|opal)\b/
            base_path = asset.logical_path.gsub('.js', '')
            headers['X-SourceMap'] = "#{::Opal::Sprockets::SourceMapHeaderPatch.prefix}/#{base_path}.map"
          end
        end
      end

      def self.included(base)
        # Poor man's alias_method_chain :)
        base.send(:alias_method, :headers_without_opal_source_maps, :headers)
        base.send(:alias_method, :headers, :headers_with_opal_source_maps)
      end

      def self.inject!(prefix)
        self.prefix = prefix
        ::Sprockets::Server.send :include, self
      end

      def self.prefix
        @prefix
      end

      def self.prefix= val
        @prefix = val
      end
    end
  end
end


