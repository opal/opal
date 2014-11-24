module Opal
  module Sprockets
    # A Builder cache store which knows about sprockets. Caching is
    # handed off to the sprockets cache, if one exists.
    #
    #     environment = sprockets_context.environment
    #     cache_store = Opal::Sprockets::CacheStore.new(environment)
    #     Builder.new(cache_store: cache_store)
    #
    class CacheStore
      # Sprockets environment instance
      attr_reader :environment

      def initialize(environment)
        @environment = environment
      end

      # Store an asset in the cache.
      #
      # @param path [String] the key/pathname of asset
      # @param asset [Opal::CachedAsset] the asset to cache
      def []=(path, asset)
        key = cache_key_for_path(path)
        environment.cache_set(key, asset.encode)
      end

      # Retrieve an asset from sprockets cache. Might be nil if
      # asset cannot be found in cache.
      #
      # @return [Opal::CachedAsset]
      def [](path)
        key = cache_key_for_path(path)
        if hash = environment.cache_get(key)
          ::Opal::Builder::CachedAsset.new(hash)
        else
          nil
        end
      end

      # TODO: this should really SHA the path, or similar
      def cache_key_for_path(path)
        "opal/#{path.gsub(/\//, '__')}"
      end
    end
  end
end
