# run with:
#
#   bundle exec ./bin/opal ./doc/examples/node_http_server.rb
#

%x{
  var http;
  http = require('http');
}


module HTTP
  class Server
    %x{
      var dom_class = http.Server;
      #{self}['_proto'] = dom_class.prototype;
      def = #{self}._proto;
      dom_class.prototype._klass = #{self};
    }

    def self.__http__
      Native(`http`)
    end

    alias_native :listen, :listen

    def self.start options = {}, &block
      host = options[:host] || '127.0.0.1'
      port = options[:port] || 3000

      server = __http__.createServer do |req, res|
        req = Native(req)
        res = Native(res)
        status, headers, body = block.call(`req`)
        res.writeHead(status, headers.to_n);
        res.end(body.join(' '));
      end

      server.listen(port, host)
      puts("Server running at http://#{host}:#{port}/");
      server
    end
  end
end

util = Native(`require('util')`)
HTTP::Server.start port: 3000 do |env|
  [200, {'Content-Type' => 'text/plain'}, ["Hello World!\n", util.inspect(env)]]
end
