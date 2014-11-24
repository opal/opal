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
      # @param key [String] the key/pathname of asset
      # @param asset [Opal::CachedAsset] the asset to cache
      def []=(key, asset)
        environment.cache_set("opal/#{key}", asset.encode)
      end

      # Retrieve an asset from sprockets cache. Might be nil if
      # asset cannot be found in cache.
      #
      # @return [Opal::CachedAsset]
      def [](key)
        if hash = environment.cache_get("opal/#{key}")
          ::Opal::Builder::CachedAsset.new(hash)
        else
          nil
        end
      end
    end
  end
end
