module Opal
  class Builder
    # Simple Memory based cache store. This is used generally in
    # non-sprockets environments, or in a sprocket environment which does
    # not have a cache predefined.
    #
    class CacheStore
      def initialize
        @cache = {}
      end

      def []=(key, asset)
        @cache[key] = asset.encode
      end

      def [](key)
        if hash = @cache[key]
          return CachedAsset.new(hash)
        else
          nil
        end
      end
    end
  end
end
