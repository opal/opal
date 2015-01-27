module Opal
  module Sprockets
    # Very simple memory based cache for sprockets.
    #
    #     enironment = sprockets_context.environment
    #     environment.cache = Opal::Sprockets::MemoryStore.new
    #
    # By default, sprockets 2.x does not have a memory based store,
    # so this simple implementation can be used to avoid writing
    # caches to disk.
    #
    class MemoryStore
      def initialize
        @cache = {}
      end

      # Returns object from cache.
      def get(key)
        @cache[key]
      end

      # Sets object in cache
      def set(key, value)
        @cache[key] = value
      end
    end
  end
end
