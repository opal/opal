require 'corelib/string'

class Encoding
  def self.register(name, options = {}, &block)
    names    = [name] + (options[:aliases] || [])
    encoding = Class.new(self, &block).
      new(name, names, options[:ascii] || false, options[:dummy] || false)

    names.each {|name|
      const_set name.sub('-', '_'), encoding
    }
  end

  def self.find(name)
    upcase = name.upcase

    constants.each {|const|
      encoding = const_get(const)

      next unless Encoding === encoding

      if encoding.name == upcase || encoding.names.include?(upcase)
        return encoding
      end
    }

    raise ArgumentError, "unknown encoding name - #{name}"
  end

  class << self
    attr_accessor :default_external
  end

  attr_reader :name, :names

  def initialize(name, names, ascii, dummy)
    @name  = name
    @names = names
    @ascii = ascii
    @dummy = dummy
  end

  def ascii_compatible?
    @ascii
  end

  def dummy?
    @dummy
  end

  def to_s
    @name
  end

  def inspect
    "#<Encoding:#{@name}#{" (dummy)" if @dummy}>"
  end

  # methods to implement per encoding
  def each_byte(*)
    raise NotImplementedError
  end

  def getbyte(*)
    raise NotImplementedError
  end

  def bytesize(*)
    raise NotImplementedError
  end

  class EncodingError < StandardError; end
  class CompatibilityError < EncodingError; end
end

Encoding.register "UTF-8", aliases: ["CP65001"], ascii: true do
  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var code = string.charCodeAt(i);

        if (code <= 0x7f) {
          #{yield `code`};
        }
        else {
          var encoded = encodeURIComponent(string.charAt(i)).substr(1).split('%');

          for (var j = 0, encoded_length = encoded.length; j < encoded_length; j++) {
            #{yield `parseInt(encoded[j], 16)`};
          }
        }
      }
    }
  end

  def bytesize(string)
    string.bytes.length
  end
end

Encoding.register "UTF-16LE" do
  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var code = string.charCodeAt(i);

        #{yield `code & 0xff`};
        #{yield `code >> 8`};
      }
    }
  end

  def bytesize(string)
    string.bytes.length
  end
end

Encoding.register "UTF-16BE" do
  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var code = string.charCodeAt(i);

        #{yield `code >> 8`};
        #{yield `code & 0xff`};
      }
    }
  end

  def bytesize(string)
    string.bytes.length
  end
end

Encoding.register "UTF-32LE" do
  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var code = string.charCodeAt(i);

        #{yield `code & 0xff`};
        #{yield `code >> 8`};
      }
    }
  end

  def bytesize(string)
    string.bytes.length
  end
end

Encoding.register "ASCII-8BIT", aliases: ["BINARY"], ascii: true do
  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var code = string.charCodeAt(i);
        #{yield `code & 0xff`};
        #{yield `code >> 8`};
      }
    }
  end

  def bytesize(string)
    string.bytes.length
  end
end

class String
  `String.prototype.encoding = #{Encoding::UTF_16LE}`

  def bytes
    each_byte.to_a
  end

  def bytesize
    @encoding.bytesize(self)
  end

  def each_byte(&block)
    return enum_for :each_byte unless block_given?

    @encoding.each_byte(self, &block)

    self
  end

  def encode(encoding)
    dup.force_encoding(encoding)
  end

  def encoding
    @encoding
  end

  def force_encoding(encoding)
    %x{
      if (encoding === self.encoding) {
        return self;
      }
    }
    encoding = Opal.coerce_to!(encoding, String, :to_s)
    encoding = Encoding.find(encoding)

    return self if encoding == @encoding
    raise ArgumentError, "unknown encoding name - #{encoding}" if encoding.nil?

    %x{
      var result = new String(self);
      result.encoding = encoding;

      return result;
    }
  end

  def getbyte(idx)
    @encoding.getbyte(self, idx)
  end

  # stub
  def valid_encoding?
    true
  end
end
