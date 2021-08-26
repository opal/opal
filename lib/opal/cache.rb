# frozen_string_literal: true

require 'opal/paths'

if RUBY_ENGINE != 'opal'
  require 'opal/cache/file_cache'
end

module Opal
  singleton_class.attr_writer :cache

  def self.cache
    @cache ||=
      if RUBY_ENGINE == 'opal' || ENV['OPAL_CACHE_DISABLE'] || !Cache::FileCache.find_dir
        Cache::NullCache.new
      else
        Cache::FileCache.new
      end
  end

  class Cache
    class CacheError < StandardError; end

    class NullCache
      def fetch(*)
        yield
      end
    end
  end
end
