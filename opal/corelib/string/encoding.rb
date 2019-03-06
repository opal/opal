require 'corelib/string'

class Encoding
  `Opal.defineProperty(self, '$$register', {})`

  def self.register(name, options = {}, &block)
    names    = [name] + (options[:aliases] || [])
    encoding = Class.new(self, &block)
                    .new(name, names, options[:ascii] || false, options[:dummy] || false)

    register = self.JS['$$register']
    names.each do |encoding_name|
      const_set encoding_name.sub('-', '_'), encoding
      register.JS["$$#{encoding_name}"] = encoding
    end
  end

  def self.find(name)
    return default_external if name == :default_external
    register = self.JS['$$register']
    encoding = register.JS["$$#{name}"] || register.JS["$$#{name.upcase}"]
    raise ArgumentError, "unknown encoding name - #{name}" unless encoding
    encoding
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
    "#<Encoding:#{@name}#{' (dummy)' if @dummy}>"
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

Encoding.register 'UTF-8', aliases: ['CP65001'], ascii: true do
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

Encoding.register 'UTF-16LE' do
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

Encoding.register 'UTF-16BE' do
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

Encoding.register 'UTF-32LE' do
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

Encoding.register 'ASCII-8BIT', aliases: ['BINARY', 'US-ASCII', 'ASCII'], ascii: true, dummy: true do
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
  attr_reader :encoding
  `Opal.defineProperty(String.prototype, 'encoding', #{Encoding::UTF_16LE})`

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

  def each_codepoint(&block)
    return enum_for :each_codepoint unless block_given?
    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        var code = self.codePointAt(i);
        #{yield `code`};
      }
    }
    self
  end

  def codepoints(&block)
    # If a block is given, which is a deprecated form, works the same as each_codepoint.
    return each_codepoint(&block) if block_given?
    each_codepoint.to_a
  end

  def encode(encoding)
    dup.force_encoding(encoding)
  end

  def force_encoding(encoding)
    %x{
      if (encoding === self.encoding) { return self; }

      encoding = #{Opal.coerce_to!(encoding, String, :to_s)};
      encoding = #{Encoding.find(encoding)};

      if (encoding === self.encoding) { return self; }

      var result = new String(self.toString())
      Object.defineProperty(result, 'encoding', {
        value: encoding,
        writable: true
      });
      return result
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
