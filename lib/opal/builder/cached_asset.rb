module Opal
  class Builder
    # An asset that is loaded from the cache. It exposes the same
    # interface as a processor, but is prefilled with compile data
    # and requires.
    #
    #     Opal::Builder::CachedAsset.new(
    #       :contents => "...", :requires => [])
    #
    # See Also
    #
    #   Opal::Builder::CacheStore
    #
    class CachedAsset
      def initialize(data)
        @data = data
      end

      def requires
        @data[:requires]
      end

      def to_s
        @data[:contents]
      end

      def source_map
        ""
      end
    end
  end
end
