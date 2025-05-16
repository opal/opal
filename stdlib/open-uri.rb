# frozen_string_literal: true
# backtick_javascript: true

# Copied from https://raw.githubusercontent.com/ruby/ruby/373babeaac8c3e663e1ded74a9f06ac94a671ed9/lib/open-uri.rb

require 'stringio'
require 'corelib/array/pack'

module Kernel
  private
  alias open_uri_original_open open # :nodoc:
  class << self
    alias open_uri_original_open open # :nodoc:
  end

  # Allows the opening of various resources including URIs.
  #
  # If the first argument responds to the 'open' method, 'open' is called on
  # it with the rest of the arguments.
  #
  # If the first argument is a string that begins with xxx://, it is parsed by
  # URI.parse.  If the parsed object responds to the 'open' method,
  # 'open' is called on it with the rest of the arguments.
  #
  # Otherwise, the original Kernel#open is called.
  #
  # OpenURI::OpenRead#open provides URI::HTTP#open, URI::HTTPS#open and
  # URI::FTP#open, Kernel#open.
  #
  # We can accept URIs and strings that begin with http://, https:// and
  # ftp://. In these cases, the opened file object is extended by OpenURI::Meta.
  def open(name, *rest, &block) # :doc:
    if name.respond_to?(:to_str) && %r{\A[A-Za-z][A-Za-z0-9+\-\.]*://} =~ name
      OpenURI.open_uri(name, *rest, &block)
    else
      open_uri_original_open(name, *rest, &block)
    end
  end
  module_function :open
end

# OpenURI is an easy-to-use wrapper for Net::HTTP, Net::HTTPS and Net::FTP.
#
# == Example
#
# It is possible to open an http, https or ftp URL as though it were a file:
#
#   open("http://www.ruby-lang.org/") {|f|
#     f.each_line {|line| p line}
#   }
#
# The opened file has several getter methods for its meta-information, as
# follows, since it is extended by OpenURI::Meta.
#
#   open("http://www.ruby-lang.org/en") {|f|
#     f.each_line {|line| p line}
#     p f.base_uri         # <URI::HTTP:0x40e6ef2 URL:http://www.ruby-lang.org/en/>
#     p f.content_type     # "text/html"
#     p f.charset          # "iso-8859-1"
#     p f.content_encoding # []
#     p f.last_modified    # Thu Dec 05 02:45:02 UTC 2002
#   }
#
# Additional header fields can be specified by an optional hash argument.
#
#   open("http://www.ruby-lang.org/en/",
#     "User-Agent" => "Ruby/#{RUBY_VERSION}",
#     "From" => "foo@bar.invalid",
#     "Referer" => "http://www.ruby-lang.org/") {|f|
#     # ...
#   }
#
# The environment variables such as http_proxy, https_proxy and ftp_proxy
# are in effect by default. Here we disable proxy:
#
#   open("http://www.ruby-lang.org/en/", :proxy => nil) {|f|
#     # ...
#   }
#
# See OpenURI::OpenRead.open and Kernel#open for more on available options.
#
# URI objects can be opened in a similar way.
#
#   uri = URI.parse("http://www.ruby-lang.org/en/")
#   uri.open {|f|
#     # ...
#   }
#
# URI objects can be read directly. The returned string is also extended by
# OpenURI::Meta.
#
#   str = uri.read
#   p str.base_uri
#
# Author:: Tanaka Akira <akr@m17n.org>

module OpenURI

  %x{
  if (["bun", "deno", "graalnodejs", "node"].includes(Opal.platform.name)) {
  const Url = Opal.platform.modules.url;
  const fs = Opal.platform.modules.fs;
  const child_process = Opal.platform.modules.child_process;
  const os = Opal.platform.modules.os;
  const path = Opal.platform.modules.path;
  const DEFAULT_MAX_BUFFER = 1000 * 1000 * 100;

  Opal.global.XMLHttpRequest = function () {
    /** originally taken from https://github.com/Mogztter/unxhr, modified */
    /**
     * Wrapper for built-in http.js to emulate the browser XMLHttpRequest object.
     *
     * This can be used with JS designed for browsers to improve reuse of code and
     * allow the use of existing libraries.
     *
     * Usage: include("XMLHttpRequest.js") and use XMLHttpRequest per W3C specs.
     *
     * @author Dan DeFelippi <dan@driverdan.com>
     * @contributor David Ellis <d.f.ellis@ieee.org>
     * @contributor Guillaume Grossetie <ggrossetie@yuzutech.fr>
     * @contributor David Jencks <djencks@apache.org>
     * @license MIT
     */

    const request_runner_js = `import * as http from "node:http";
import * as https from "node:https";
import * as buffermod from "node:buffer";
const Buffer = buffermod.Buffer;


function doRequest (options, data) {
  const { ssl, requestOptions } = options
  if (data && requestOptions.headers) {
    requestOptions.headers['Content-Length'] = Buffer.isBuffer(data) ? data.length : Buffer.byteLength(data)
  }
  return new Promise((resolve, reject) => {
    let responseText = ''
    const responseBinary = []
    const httpRequest = ssl ? https.request : http.request
    const req = httpRequest(requestOptions, function (response) {
      response.on('data', function (chunk) {
        responseBinary.push(chunk)
      })
      response.on('end', function () {
        const result = {
          error: null,
          data: { statusCode: response.statusCode, headers: response.headers }
        }
        result.data.binary = Buffer.concat(responseBinary)
        resolve(result)
      })
      response.on('error', function (error) {
        reject(error)
      })
    }).on('error', function (error) {
      reject(error)
    })
    if (data) {
      req.write(data)
    }
    req.end()
  })
}

(async () => {
  try {
    let data
    const args = process.argv.slice(2)
    const options = {}
    for (let j = 0; j < args.length; j++) {
      const arg = args[j]
      if (arg.startsWith('--ssl=')) {
        options.ssl = arg.slice('--ssl='.length) === 'true'
      } else if (arg.startsWith('--request-options=')) {
        options.requestOptions = JSON.parse(arg.slice('--request-options='.length))
      }
    }
    if (process.stdin.isTTY) {
      // Even though executed by name, the first argument is still "node",
      // the second the script name. The third is the string we want.
      data = Buffer.from(process.argv[2] || '', 'binary')
      // There will be a trailing newline from the user hitting enter. Get rid of it.
      data = data.replace(/\\\\n$/, '')
      const result = await doRequest(options, data)
      console.log(JSON.stringify(result))
    } else {
      // Accepting piped content. E.g.:
      // echo "pass in this string as input" | ./example-script
      data = ''
      process.stdin.setEncoding('binary')
      process.stdin.on('readable', function () {
        let chunk = process.stdin.read()
        while (chunk) {
          data += chunk
          chunk = process.stdin.read()
        }
      })
      process.stdin.on('end', async function () {
        try {
          const result = await doRequest(options, data)
          console.log(JSON.stringify(result))
        } catch (e) {
          console.log(JSON.stringify({ error: e }))
        }
      })
    }
  } catch (e) {
    console.log(JSON.stringify({ error: e }))
  }
})()`

    const self = this;

    // Holds http.js objects
    let request;
    let response;

    // Request settings
    let settings = {};

    // Set some default headers
    const defaultHeaders = {
      'User-Agent': 'node-XMLHttpRequest',
      Accept: '*/*'
    };

    let headers = {};
    const headersCase = {};

    // These request methods are not allowed
    const forbiddenRequestMethods = ['TRACE', 'TRACK', 'CONNECT'];

    // Send flag
    let sendFlag = false;
    // Error flag, used when errors occur or abort is called
    let errorFlag = false;

    /**
     * Constants
     */
    this.UNSENT = 0;
    this.OPENED = 1;
    this.HEADERS_RECEIVED = 2;
    this.LOADING = 3;
    this.DONE = 4;

    /**
     * Public vars
     */

    // Current state
    this.readyState = this.UNSENT;

    // default ready state change handler in case one is not set or is set late
    this.onreadystatechange = null;

    // Result & response
    this.responseText = '';
    this.responseXML = '';
    this.status = null;
    this.statusText = null;

    // Whether cross-site Access-Control requests should be made using
    // credentials such as cookies or authorization headers
    this.withCredentials = false;
    // "text", "arraybuffer", "blob", or "document", depending on your data needs.
    // Note, setting xhr.responseType = '' (or omitting) will default the response to "text".
    // Omitting, '', or "text" will return a String.
    // Other values will return an ArrayBuffer.
    this.responseType = '';

    /**
     * Private methods
     */

    /**
     * Check if the specified method is allowed.
     *
     * @param method - {string}  Request method to validate
     * @return {boolean} - False if not allowed, otherwise true
     */
    const isAllowedHttpMethod = function (method) {
      return (method && forbiddenRequestMethods.indexOf(method) === -1);
    }

    /**
     * Public methods
     */

    /**
     * Open the connection. Currently supports local server requests.
     *
     * @param method - {string} Connection method (eg GET, POST)
     * @param url - {string} URL for the connection.
     * @param async - {boolean} Asynchronous connection. Default is true.
     * @param [user] - {string} Username for basic authentication (optional)
     * @param [password] - {string} Password for basic authentication (optional)
     */
    this.open = function (method, url, async, user, password) {
      this.abort()
      errorFlag = false

      // Check for valid request method
      if (!isAllowedHttpMethod(method))
        throw new Error('SecurityError: Request method not allowed');

      settings = {
        method: method,
        url: url.toString(),
        async: (typeof async !== 'boolean' ? true : async),
        user: user || null,
        password: password || null
      };

      setState(this.OPENED);
    }

    /**
     * Gets a header from the server response.
     *
     * @param header - {string} Name of header to get.
     * @return {Object} - Text of the header or null if it doesn't exist.
     */
    this.getResponseHeader = function (header) {
      if (typeof header === 'string' &&
        this.readyState > this.OPENED &&
        response &&
        response.headers &&
        response.headers[header.toLowerCase()] &&
        !errorFlag
      ) {
        return response.headers[header.toLowerCase()];
      }

      return null;
    }

    /**
     * Gets a request header
     *
     * @param name - {string} Name of header to get
     * @return {string} Returns the request header or empty string if not set
     */
    this.getRequestHeader = function (name) {
      if (typeof name === 'string' && headersCase[name.toLowerCase()]) return headers[headersCase[name.toLowerCase()]];
      return ''
    }

    /**
     * Sends the request to the server.
     *
     * @param data - {string} Optional data to send as request body.
     */
    this.send = function (data) {
      if (this.readyState !== this.OPENED)
        throw new Error('INVALID_STATE_ERR: connection must be opened before send() is called');

      if (sendFlag)
        throw new Error('INVALID_STATE_ERR: send has already been called');

      let ssl = false;
      let local = false;
      const url = new Url.URL(settings.url)
      let host
      // Determine the server
      switch (url.protocol) {
        case 'https:':
          ssl = true;
          host = url.hostname;
          break;
        case 'http:':
          host = url.hostname;
          break;
        case 'file:':
          local = true;
          break;
        case undefined:
        case null:
        case '':
          host = 'localhost';
          break;
        default:
          throw new Error('Protocol not supported.');
      }

      // Load files off the local filesystem (file://)
      if (local) {
        if (settings.method !== 'GET')
          throw new Error('XMLHttpRequest: Only GET method is supported');

        try {
          this.responseText = fs.readFileSync(url, 'utf8');
          this.status = 200;
          setState(self.DONE);
        } catch (e) {
          this.handleError(e, url);
        }

        return;
      }

      // Default to port 80. If accessing localhost on another port be sure
      // to use http://localhost:port/path
      const port = url.port || (ssl ? 443 : 80);
      // Add query string if one is used
      const uri = url.pathname + (url.search ? url.search : '');

      // Set the defaults if they haven't been set
      for (const name in defaultHeaders) {
        if (!headersCase[name.toLowerCase()]) headers[name] = defaultHeaders[name];
      }

      // Set the Host header or the server may reject the request
      headers.Host = host;
      // IPv6 addresses must be escaped with brackets
      if (url.host[0] === '[') headers.Host = '[' + headers.Host + ']';
      if (!((ssl && port === 443) || port === 80)) headers.Host += ':' + url.port;

      // Set Basic Auth if necessary
      if (settings.user) {
        if (typeof settings.password === 'undefined') settings.password = '';
        const authBuf = Buffer.from(settings.user + ':' + settings.password);
        headers.Authorization = 'Basic ' + authBuf.toString('base64');
      }

      // Set content length header
      if (settings.method === 'GET' || settings.method === 'HEAD') {
        data = null;
      } else if (data) {
        headers['Content-Length'] = Buffer.isBuffer(data) ? data.length : Buffer.byteLength(data);
        if (!this.getRequestHeader('Content-Type')) headers['Content-Type'] = 'text/plain;charset=UTF-8';
      } else if (settings.method === 'POST') {
        // For a post with no data set Content-Length: 0.
        // This is required by buggy servers that don't meet the specs.
        headers['Content-Length'] = 0;
      }

      const options = {
        host: host,
        port: port,
        path: uri,
        method: settings.method,
        headers: headers,
        agent: false,
        withCredentials: self.withCredentials
      };

      const responseType = this.responseType || 'text';

      // Reset error flag
      errorFlag = false;

      const maxBuffer = process.env.UNXHR_MAX_BUFFER
        ? parseInt(process.env.UNXHR_MAX_BUFFER)
        : DEFAULT_MAX_BUFFER;
      const encoding = responseType === 'text' ? 'utf8' : 'binary';

      let tmpdir;
      try {
        tmpdir = fs.mkdtempSync(path.join(os.tmpdir(), 'unxhr-request-runner-'));
        const scriptPath = path.join(tmpdir, 'request.js');
        fs.writeFileSync(scriptPath, request_runner_js);
        const output = child_process.execSync(`"${process.execPath}" ${Opal.platform.name == "deno" ? 'run --allow-net' : ''} "${scriptPath}" --ssl="${ssl}" \
 --request-options=${JSON.stringify(JSON.stringify(options))}`,
          { stdio: ['pipe', 'pipe', 'inherit'], input: data, maxBuffer: maxBuffer });
        const result = JSON.parse(output.toString(encoding));
        if (result.error) {
          throw translateError(result.error, url);
        } else {
          response = result.data;
          self.status = result.data.statusCode;
          self.response = Uint8Array.from(result.data.binary.data).buffer;
          setState(self.DONE);
        }
      } finally {
        fs.rmSync(tmpdir, { recursive: true, force: true });
      }
    }

    /**
     * Called when an error is encountered to deal with it.
     */
    this.handleError = function (error, url) {
      this.status = 0
      this.statusText = ''
      this.responseText = ''
      errorFlag = true
      setState(this.DONE)
    }

    /**
     * Aborts a request.
     */
    this.abort = function () {
      if (request) {
        request.abort();
        request = null;
      }

      headers = defaultHeaders;
      this.status = 0;
      this.responseText = '';
      this.responseXML = '';

      errorFlag = true;

      if (this.readyState !== this.UNSENT &&
        (this.readyState !== this.OPENED || sendFlag) &&
        this.readyState !== this.DONE) {
        sendFlag = false;
        setState(this.DONE);
      }
      this.readyState = this.UNSENT;
    }

    /**
     * Changes readyState and calls onreadystatechange.
     *
     * @param state - {Number} New state
     */
    const setState = function (state) {
      if (state === self.LOADING || self.readyState !== state) self.readyState = state;
    }

    const translateError = function (error, url) {
      if (typeof error === 'object') {
        if (error.code === 'ENOTFOUND' || error.code === 'EAI_AGAIN') {
          // XMLHttpRequest throws a DOMException when DNS lookup fails:
          // code: 19
          // message: "Failed to execute 'send' on 'XMLHttpRequest': Failed to load 'http://url/'."
          // name: "NetworkError"
          // stack: (...)
          return new Error(`Failed to execute 'send' on 'XMLHttpRequest': Failed to load '${url}'.`)
        }
        if (error instanceof Error) {
          return error
        }
        return new Error(JSON.stringify(error))
      }
      return new Error(error)
    }
  }

}
  }
  def self.open_uri(name, *rest) # :nodoc:
    io = open_loop(name, {})
    io.rewind
    if block_given?
      begin
        yield io
      ensure
        close_io(io)
      end
    else
      io
    end
  end

  def self.close_io(io)
    if io.respond_to? :close!
      io.close! # Tempfile
    else
      io.close unless io.closed?
    end
  end

  def self.open_loop(uri, options) # :nodoc:
    req = request(uri)
    data = `req.responseText`
    status = `req.status`
    status_text = `req.statusText && req.statusText.errno ? req.statusText.errno : req.statusText`
    if status == 200 || (status == 0 && data)
      build_response(req, status, status_text)
    else
      raise OpenURI::HTTPError.new("#{status} #{status_text}", '')
    end
  end

  def self.build_response(req, status, status_text)
    buf = Buffer.new
    buf << data(req).pack('c*')
    io = buf.io
    #io.base_uri = uri # TODO: Generate a URI object from the uri String
    io.status = "#{status} #{status_text}"
    io.meta_add_field('content-type', `req.getResponseHeader("Content-Type") || ''`)
    last_modified = `req.getResponseHeader("Last-Modified")`
    io.meta_add_field('last-modified', last_modified) if last_modified
    io
  end

  def self.data(req)
    %x{
      if (["bun", "deno", "graalnodejs", "node"].includes(Opal.platform.name)) {
        var arrayBuffer = req.response;
        var byteArray = new Uint8Array(arrayBuffer);
        var result = []
        for (var i = 0; i < byteArray.byteLength; i++) {
          result.push(byteArray[i]);
        }
        return result;
      } else {
        var binStr = req.responseText;
        var byteArray = [];
        for (var i = 0, len = binStr.length; i < len; ++i) {
          var c = binStr.charCodeAt(i);
          var byteCode = c & 0xff; // byte at offset i
          byteArray.push(byteCode);
        }
        return byteArray;
      }
    }
  end

  def self.request(uri)
    %x{
      try {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', uri, false);
        if (["bun", "deno", "graalnodejs", "node"].includes(Opal.platform.name)) {
          xhr.responseType = 'binary';
        } else {
          // We cannot use xhr.responseType = "arraybuffer" in Browsers because XMLHttpRequest
          // is used in synchronous mode.
          // https://developer.mozilla.org/en-US/docs/Web/API/XMLHttpRequest/responseType#Synchronous_XHR_restrictions
          xhr.overrideMimeType('text/plain; charset=x-user-defined');
        }
        xhr.send();
        return xhr;
      } catch (error) {
        #{raise OpenURI::HTTPError.new(`error.message`, '')}
      }
    }
  end

  class HTTPError < StandardError
    def initialize(message, io)
      super(message, io)
      @io = io
    end
    attr_reader :io
  end

  class Buffer # :nodoc: all
    def initialize
      @io = StringIO.new
      @io.binmode
      @size = 0
    end
    attr_reader :size

    def <<(str)
      @io << str
      @size += str.length
    end

    def io
      Meta.init @io unless Meta === @io
      @io
    end
  end

  # Mixin for holding meta-information.
  module Meta
    def Meta.init(obj, src=nil) # :nodoc:
      obj.extend Meta
      obj.instance_eval {
        @base_uri = nil
        @meta = {} # name to string.  legacy.
        @metas = {} # name to array of strings.
      }
      if src
        obj.status = src.status
        obj.base_uri = src.base_uri
        src.metas.each {|name, values|
          obj.meta_add_field2(name, values)
        }
      end
    end

    # returns an Array that consists of status code and message.
    attr_accessor :status

    # returns a URI that is the base of relative URIs in the data.
    # It may differ from the URI supplied by a user due to redirection.
    attr_accessor :base_uri

    # returns a Hash that represents header fields.
    # The Hash keys are downcased for canonicalization.
    # The Hash values are a field body.
    # If there are multiple field with same field name,
    # the field values are concatenated with a comma.
    attr_reader :meta

    # returns a Hash that represents header fields.
    # The Hash keys are downcased for canonicalization.
    # The Hash value are an array of field values.
    attr_reader :metas

    def meta_setup_encoding # :nodoc:
      charset = self.charset
      enc = find_encoding(charset)
      set_encoding(enc)
    end

    def set_encoding(enc)
      if self.respond_to? :force_encoding
        self.force_encoding(enc)
      elsif self.respond_to? :string
        self.string.force_encoding(enc)
      else # Tempfile
        self.set_encoding enc
      end
    end

    def find_encoding(charset)
      enc = nil
      if charset
        begin
          enc = Encoding.find(charset)
        rescue ArgumentError
        end
      end
      enc = Encoding::ASCII_8BIT unless enc
      enc
    end

    def meta_add_field2(name, values) # :nodoc:
      name = name.downcase
      @metas[name] = values
      @meta[name] = values.join(', ')
      meta_setup_encoding if name == 'content-type'
    end

    def meta_add_field(name, value) # :nodoc:
      meta_add_field2(name, [value])
    end

    def last_modified
      if (vs = @metas['last-modified'])
        Time.at(`Date.parse(#{vs.join(', ')}) / 1000`).utc
      else
        nil
      end
    end

    def content_type_parse # :nodoc:
      content_type = @metas['content-type']
      # FIXME Extract type, subtype and parameters
      content_type.join(', ')
    end

    # returns a charset parameter in Content-Type field.
    # It is downcased for canonicalization.
    #
    # If charset parameter is not given but a block is given,
    # the block is called and its result is returned.
    # It can be used to guess charset.
    #
    # If charset parameter and block is not given,
    # nil is returned except text type in HTTP.
    # In that case, "iso-8859-1" is returned as defined by RFC2616 3.7.1.
    def charset
      type = content_type_parse
      if type && %r{\Atext/} =~ type && @base_uri && /\Ahttp\z/i =~ @base_uri.scheme
        'iso-8859-1' # RFC2616 3.7.1
      else
        nil
      end
    end

    # returns "type/subtype" which is MIME Content-Type.
    # It is downcased for canonicalization.
    # Content-Type parameters are stripped.
    def content_type
      type = content_type_parse
      type || 'application/octet-stream'
    end
  end

  # Mixin for HTTP and FTP URIs.
  module OpenRead
    # OpenURI::OpenRead#open provides `open' for URI::HTTP and URI::FTP.
    #
    # OpenURI::OpenRead#open takes optional 3 arguments as:
    #
    #   OpenURI::OpenRead#open([mode [, perm]] [, options]) [{|io| ... }]
    #
    # OpenURI::OpenRead#open returns an IO-like object if block is not given.
    # Otherwise it yields the IO object and return the value of the block.
    # The IO object is extended with OpenURI::Meta.
    #
    # +mode+ and +perm+ are the same as Kernel#open.
    #
    # However, +mode+ must be read mode because OpenURI::OpenRead#open doesn't
    # support write mode (yet).
    # Also +perm+ is ignored because it is meaningful only for file creation.
    #
    def open(*rest, &block)
      OpenURI.open_uri(self, *rest, &block)
    end

    # OpenURI::OpenRead#read([options]) reads a content referenced by self and
    # returns the content as string.
    # The string is extended with OpenURI::Meta.
    # The argument +options+ is same as OpenURI::OpenRead#open.
    def read(options={})
      self.open(options) {|f|
        str = f.read
        Meta.init str, f
        str
      }
    end
  end
end
