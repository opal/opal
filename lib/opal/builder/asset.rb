module Opal
  class Builder
    class Asset
      def initialize(data)
        @data = data
      end

      def encode
        @data.dup
      end

      def to_s
        @data['source']
      end

      def requires
        @data['requires']
      end

      def required_trees
        @data['required_trees']
      end

      def mtime
        @data['mtime']
      end

      def source_map
        @source_map ||= ::SourceMap::Map.from_hash(@data['source_map'])
      end

      # Check that this cached asset is fresh. A fresh asset is one
      # that has not changed on disk. An asset that is not fresh will
      # need to be discarded, and that file recompiled then recached.
      #
      # @params builder [Opal::Builder] owner builder for asset
      # @params path [String] the logical (module) path for asset
      # @returns [Boolean]
      #
      def fresh?(builder, path)
        # TODO: for now, always assume stale assets
        stat  = builder.stat(path)

        # if file no longer exists, cache cannot be fresh
        if stat.nil?
          return false
        end

        # if cached mtime is >= file on disk, cache is fine
        if mtime.to_i >= stat.mtime.to_i
          return true
        end

        # file mtime modified, so asset isn't fresh
        false
      end

    end
  end
end
