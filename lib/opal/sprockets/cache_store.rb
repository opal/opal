module Opal
  module Sprockets
    # Sprockets compatible CacheStore
    class CacheStore
      attr_reader :environment

      def initialize(environment)
        @environment = environment
      end

      def []=(key, asset)
        environment.cache_set("opal/#{key}.cache", asset.encode)
      end

      def [](key)
        if obj = environment.cache_get("opal/#{key}.cache")
          return CachedAsset.new(obj)
        else
          nil
        end
      end
    end
  end
end
