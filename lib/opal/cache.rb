# frozen_string_literal: true

require 'opal/paths'
require 'digest/sha2' unless RUBY_ENGINE == 'opal'

if RUBY_ENGINE != 'opal'
  require 'opal/cache/file_cache'
end

module Opal
  # A Sprockets-compatible cache, for example an instance of
  # Opal::Cache::FileCache or Opal::Cache::NullCache.
  singleton_class.attr_writer :cache

  def self.cache
    @cache ||=
      if RUBY_ENGINE == 'opal' || ENV['OPAL_CACHE_DISABLE'] || !Cache::FileCache.find_dir
        Cache::NullCache.new
      else
        Cache::FileCache.new
      end
  end

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
                cache.set(key, compiler)
                compiler
              end
    end

    def runtime_key
      @runtime_key ||= begin
        # We want to ensure the compiler and any Gemfile/gemspec (for development)
        # stays untouched
        opal_path = File.expand_path('..', Opal.gem_dir)
        files = Dir["#{opal_path}/{Gemfile*,*.gemspec,lib/**/*}"]

        # Also check if parser wasn't changed:
        files += $LOADED_FEATURES.grep(%r{lib/(parser|ast)})

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
