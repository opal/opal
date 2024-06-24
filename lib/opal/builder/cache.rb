# frozen_string_literal: true

require 'digest/sha2' unless RUBY_ENGINE == 'opal'

if RUBY_ENGINE != 'opal'
  require 'opal/builder/cache/file_cache'
end

module Opal
  # A Sprockets-compatible cache, for example an instance of
  # Opal::Builder::Cache::FileCache or Opal::Builder::Cache::NullCache.
  singleton_class.attr_writer :cache

  def self.cache
    @cache ||=
      if RUBY_ENGINE == 'opal' || ENV['OPAL_CACHE_DISABLE'] || !Builder::Cache::FileCache.find_dir
        Builder::Cache::NullCache.new
      else
        Builder::Cache::FileCache.new
      end
  end

  class Builder
    module Cache
      class NullCache
        def fetch(*)
          yield
        end
      end

      module_function

      def fetch(cache, key, &block)
        # Extension to the Sprockets API of Cache, if a cache responds
        # to #fetch, then we call it instead of using #get and #set.
        return cache.fetch(key, &block) if cache.respond_to? :fetch

        key = digest(key.join('/')) + '-' + runtime_key

        data = cache.get(key)

        data || begin
                  compiler = yield
                  cache.set(key, compiler) unless compiler.dynamic_cache_result
                  compiler
                end
      end

      def runtime_key
        @runtime_key ||= begin
          files = Opal.dependent_files

          digest [
            files.sort.map { |f| "#{f}:#{File.size(f)}:#{File.mtime(f).to_f}" },
            RUBY_VERSION,
            RUBY_PATCHLEVEL
          ].join('/')
        end
      end

      def digest(string)
        ::Digest::SHA256.hexdigest(string)[-32..-1].to_i(16).to_s(36)
      end
    end
  end
end
