module Opal
  class SourceMapServer
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
        source = register[asset.logical_path.sub(/\.js$/, '')]
        return not_found(asset) if source.nil?

        map = JSON.parse(source)
        map['sources'] = map['sources'].map {|s| "#{prefix}/#{s}"}
        source = map.to_json
        return not_found(asset) if source.nil?

        return [200, {"Content-Type" => "text/json"}, [source.to_s]]
      when %r{^(.*)\.rb$}
        source = File.read(sprockets.resolve(path_info))
        return not_found(path_info) if source.nil?
        return [200, {"Content-Type" => "text/ruby"}, [source]]
      else
        not_found(path_info)
      end
    end

    def not_found(*messages)
      not_found = [404, {}, [{not_found: messages, keys: register.keys}.inspect]]
    end

    def register
      Opal::Processor.source_map_register
    end
  end
end
