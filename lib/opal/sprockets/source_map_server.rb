module Opal
  class SourceMapServer
    # Carelessly taken from Sprockets::Caching (Sprockets v2)
    class Cache
      def initialize
        @cache = {}
      end

      attr_reader :cache

      def cache_get(key)
        # `Cache#get(key)` for Memcache
        if cache.respond_to?(:get)
          cache.get(key)

        # `Cache#[key]` so `Hash` can be used
        elsif cache.respond_to?(:[])
          cache[key]

        # `Cache#read(key)` for `ActiveSupport::Cache` support
        elsif cache.respond_to?(:read)
          cache.read(key)

        else
          nil
        end
      end

      def cache_set(key, value)
        # `Cache#set(key, value)` for Memcache
        if cache.respond_to?(:set)
          cache.set(key, value)

        # `Cache#[key]=value` so `Hash` can be used
        elsif cache.respond_to?(:[]=)
          cache[key] = value

        # `Cache#write(key, value)` for `ActiveSupport::Cache` support
        elsif cache.respond_to?(:write)
          cache.write(key, value)
        end

        value
      end
    end

    def self.get_map_cache(sprockets, logical_path)
      logical_path = logical_path.gsub(/\.js#{REGEXP_END}/, '')
      cache_key = cache_key_for_path(logical_path+'.map')
      cache(sprockets).cache_get(cache_key)
    end

    def self.set_map_cache(sprockets, logical_path, map_contents)
      logical_path = logical_path.gsub(/\.js#{REGEXP_END}/, '')
      cache_key = cache_key_for_path(logical_path+'.map')
      cache(sprockets).cache_set(cache_key, map_contents)
    end

    def self.cache(sprockets)
      @cache ||= sprockets.cache ? sprockets : Cache.new
    end

    def self.cache_key_for_path(logical_path)
      base_name = logical_path.gsub(/\.js#{REGEXP_END}/, '')
      File.join('opal', 'source_maps', base_name)
    end


    def initialize sprockets, prefix = '/'
      @sprockets = sprockets
      @prefix = prefix
    end

    attr_reader :sprockets, :prefix

    def inspect
      "#<#{self.class}:#{object_id}>"
    end

    def call(env)
      prefix_regex = %r{^(?:#{prefix}/|/)}
      path_info = env['PATH_INFO'].to_s.sub(prefix_regex, '')

      case path_info
      when %r{^(.*)\.self\.map$}
        path = $1
        asset  = sprockets[path]
        return not_found(path) if asset.nil?

        # "logical_name" of a BundledAsset keeps the .js extension
        source = SourceMapServer.get_map_cache(sprockets, asset.logical_path)
        return not_found(asset) if source.nil?

        map = JSON.parse(source)
        map['sources'] = map['sources'].map {|s| "#{prefix}/#{s}"}
        source = map.to_json

        return [200, {"Content-Type" => "text/json"}, [source.to_s]]
      when %r{^(.*)\.rb$}
        begin
          asset = sprockets.resolve(path_info.sub(/\.rb#{REGEXP_END}/,''))
        rescue Sprockets::FileNotFound
          return not_found(path_info)
        end
        return [200, {"Content-Type" => "text/ruby"}, [Pathname(asset).read]]
      else
        not_found(path_info)
      end
    end

    def not_found(*messages)
      not_found = [404, {}, [{not_found: messages}.inspect]]
    end
  end
end
