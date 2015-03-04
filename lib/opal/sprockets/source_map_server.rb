module Opal
  class SourceMapServer
    def self.get_map_cache(sprockets, logical_path)
      cache_key = cache_key_for_path(logical_path)

      return memory_cache[cache_key] if sprockets.cache.nil?
      sprockets.cache_get(cache_key)
    end

    def self.set_map_cache(sprockets, logical_path, map_contents)
      cache_key = cache_key_for_path(logical_path)

      return memory_cache[cache_key]= map_contents if sprockets.cache.nil?
      sprockets.cache_set(cache_key, map_contents)
    end

    def self.memory_cache(reset = false)
      @memory_cache   = nil if reset
      @memory_cache ||= Hash.new
    end

    def self.cache_key_for_path(logical_path)
      base_name = logical_path.gsub(/\.js$/, '')
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
      when %r{^(.*)\.map$}
        path = $1
        asset  = sprockets[path]
        return not_found(path) if asset.nil?

        # "logical_name" of a BundledAsset keeps the .js extension
        source = SourceMapServer.get_map_cache(sprockets, asset.logical_path)
        return not_found(asset) if source.nil?

        map = JSON.parse(source)
        map['sources'] = map['sources'].map {|s| "#{prefix}/#{s}"}
        source = map.to_json
        return not_found(asset) if source.nil?

        return [200, {"Content-Type" => "text/json"}, [source.to_s]]
      when %r{^(.*)\.rb$}
        begin
          asset = sprockets.resolve(path_info.sub(/\.rb$/,''))
        rescue Sprockets::FileNotFound
          return not_found(path_info)
        end
        return [200, {"Content-Type" => "text/ruby"}, [asset.read]]
      else
        not_found(path_info)
      end
    end

    def not_found(*messages)
      not_found = [404, {}, [{not_found: messages}.inspect]]
    end
  end
end
