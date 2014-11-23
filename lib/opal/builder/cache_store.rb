module Opal
  class Builder
    # Simple Memory based cache store. This is used generally in
    # non-sprockets environments, or in a sprocket environment which does
    # not have a cache predefined.
    class CacheStore
      def initialize
        @cache = {}
      end

      def store(key, contents, requires)
        @cache[key] = {:contents => contents, :requires => requires}
      end

      def retrieve(key)
        if hash = @cache[key]
          return CachedAsset.new(hash)
        else
          nil
        end
      end
    end
  end
end
