# Copied from https://raw.githubusercontent.com/ruby/ruby/373babeaac8c3e663e1ded74a9f06ac94a671ed9/lib/open-uri.rb
# frozen_string_literal: true
require 'stringio'

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
      buf = Buffer.new
      buf << data
      io = buf.io
      #io.base_uri = uri # TODO: Generate a URI object from the uri String
      io.status = "#{status} #{status_text}"
      io.meta_add_field('content-type', `req.getResponseHeader("Content-Type")`)
      last_modified = `req.getResponseHeader("Last-Modified")`
      io.meta_add_field('last-modified', last_modified) if last_modified
      io
    else
      raise OpenURI::HTTPError.new("#{status} #{status_text}", '')
    end
  end

  def self.request(uri)
    %x{
      try {
        var xhr = new XMLHttpRequest();
        xhr.open('GET', uri, false);
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
