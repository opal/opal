require 'corelib/string'

class Encoding
  def self.register(name, options = {}, &block)
    names = [name] + (options[:aliases] || [])
    ascii = options[:ascii] || false
    dummy = options[:dummy] || false

    if options[:inherits]
      encoding = options[:inherits].clone
      encoding.initialize(name, names, ascii, dummy)
    else
      encoding = new(name, names, ascii, dummy)
    end
    encoding.instance_eval(&block) if block_given?

    register = `Opal.encodings`
    names.each do |encoding_name|
      const_set encoding_name.tr('-', '_'), encoding
      register.JS[encoding_name] = encoding
    end
  end

  def self.find(name)
    return default_external if name == :default_external
    `return Opal.find_encoding(name)`
  end

  singleton_class.attr_accessor :default_external

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

  def binary?
    false
  end

  def to_s
    @name
  end

  def inspect
    "#<Encoding:#{@name}#{' (dummy)' if @dummy}>"
  end

  # methods to implement per encoding
  def charsize(string)
    %x{
      var len = 0;
      for (var i = 0, length = string.length; i < length; i++) {
        var charcode = string.charCodeAt(i);
        if (!(charcode >= 0xD800 && charcode <= 0xDBFF)) {
          len++;
        }
      }
      return len;
    }
  end

  def each_char(string, &block)
    %x{
      var low_surrogate = "";
      for (var i = 0, length = string.length; i < length; i++) {
        var charcode = string.charCodeAt(i);
        var chr = string.charAt(i);
        if (charcode >= 0xDC00 && charcode <= 0xDFFF) {
          low_surrogate = chr;
          continue;
        }
        else if (charcode >= 0xD800 && charcode <= 0xDBFF) {
          chr = low_surrogate + chr;
        }
        if (string.encoding.name != "UTF-8") {
          chr = new String(chr);
          chr.encoding = string.encoding;
        }
        Opal.yield1(block, chr);
      }
    }
  end

  def each_byte(*)
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
      // Taken from: https://github.com/feross/buffer/blob/f52dffd9df0445b93c0c9065c2f8f0f46b2c729a/index.js#L1954-L2032
      var units = Infinity;
      var codePoint;
      var length = string.length;
      var leadSurrogate = null;

      for (var i = 0; i < length; ++i) {
        codePoint = string.charCodeAt(i);

        // is surrogate component
        if (codePoint > 0xD7FF && codePoint < 0xE000) {
          // last char was a lead
          if (!leadSurrogate) {
            // no lead yet
            if (codePoint > 0xDBFF) {
              // unexpected trail
              if ((units -= 3) > -1) {
                #{yield `0xEF`};
                #{yield `0xBF`};
                #{yield `0xBD`};
              }
              continue;
            } else if (i + 1 === length) {
              // unpaired lead
              if ((units -= 3) > -1) {
                #{yield `0xEF`};
                #{yield `0xBF`};
                #{yield `0xBD`};
              }
              continue;
            }

            // valid lead
            leadSurrogate = codePoint;

            continue;
          }

          // 2 leads in a row
          if (codePoint < 0xDC00) {
            if ((units -= 3) > -1) {
              #{yield `0xEF`};
              #{yield `0xBF`};
              #{yield `0xBD`};
            }
            leadSurrogate = codePoint;
            continue;
          }

          // valid surrogate pair
          codePoint = (leadSurrogate - 0xD800 << 10 | codePoint - 0xDC00) + 0x10000;
        } else if (leadSurrogate) {
          // valid bmp char, but last char was a lead
          if ((units -= 3) > -1) {
            #{yield `0xEF`};
            #{yield `0xBF`};
            #{yield `0xBD`};
          }
        }

        leadSurrogate = null;

        // encode utf8
        if (codePoint < 0x80) {
          if ((units -= 1) < 0) break;
          #{yield `codePoint`};
        } else if (codePoint < 0x800) {
          if ((units -= 2) < 0) break;
          #{yield `codePoint >> 0x6 | 0xC0`};
          #{yield `codePoint & 0x3F | 0x80`};
        } else if (codePoint < 0x10000) {
          if ((units -= 3) < 0) break;
          #{yield `codePoint >> 0xC | 0xE0`};
          #{yield `codePoint >> 0x6 & 0x3F | 0x80`};
          #{yield `codePoint & 0x3F | 0x80`};
        } else if (codePoint < 0x110000) {
          if ((units -= 4) < 0) break;
          #{yield `codePoint >> 0x12 | 0xF0`};
          #{yield `codePoint >> 0xC & 0x3F | 0x80`};
          #{yield `codePoint >> 0x6 & 0x3F | 0x80`};
          #{yield `codePoint & 0x3F | 0x80`};
        } else {
          // Invalid code point
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
    `string.length * 2`
  end
end

Encoding.register 'UTF-16BE', inherits: Encoding::UTF_16LE do
  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var code = string.charCodeAt(i);

        #{yield `code >> 8`};
        #{yield `code & 0xff`};
      }
    }
  end
end

Encoding.register 'UTF-32LE' do
  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var code = string.charCodeAt(i);

        #{yield `code & 0xff`};
        #{yield `code >> 8`};
        #{yield 0};
        #{yield 0};
      }
    }
  end

  def bytesize(string)
    `string.length * 4`
  end
end

Encoding.register 'UTF-32BE', inherits: Encoding::UTF_32LE do
  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var code = string.charCodeAt(i);

        #{yield 0};
        #{yield 0};
        #{yield `code >> 8`};
        #{yield `code & 0xff`};
      }
    }
  end
end

Encoding.register 'ASCII-8BIT', aliases: ['BINARY'], ascii: true do
  def each_char(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var chr = new String(string.charAt(i));
        chr.encoding = string.encoding;
        #{yield `chr`};
      }
    }
  end

  def charsize(string)
    `string.length`
  end

  def each_byte(string, &block)
    %x{
      for (var i = 0, length = string.length; i < length; i++) {
        var code = string.charCodeAt(i);
        #{yield `code & 0xff`};
      }
    }
  end

  def bytesize(string)
    `string.length`
  end

  def binary?
    true
  end
end

Encoding.register 'ISO-8859-1', aliases: ['ISO8859-1'], ascii: true, inherits: Encoding::ASCII_8BIT
Encoding.register 'US-ASCII', aliases: ['ASCII'], ascii: true, inherits: Encoding::ASCII_8BIT

class String
  attr_reader :encoding
  attr_reader :internal_encoding
  `Opal.defineProperty(String.prototype, 'bytes', nil)`
  `Opal.defineProperty(String.prototype, 'encoding', #{Encoding::UTF_8})`
  `Opal.defineProperty(String.prototype, 'internal_encoding', #{Encoding::UTF_8})`

  def b
    dup.force_encoding('binary')
  end

  def bytesize
    @internal_encoding.bytesize(self)
  end

  def each_byte(&block)
    return enum_for(:each_byte) { bytesize } unless block_given?

    @internal_encoding.each_byte(self, &block)

    self
  end

  def bytes
    # REMIND: required when running in strict mode, otherwise the following error will be thrown:
    # Cannot create property 'bytes' on string 'abc'
    %x{
      if (typeof self === 'string') {
        return #{`new String(self)`.each_byte.to_a};
      }
    }

    @bytes ||= each_byte.to_a
    @bytes.dup
  end

  def each_char(&block)
    return enum_for(:each_char) { length } unless block_given?

    @encoding.each_char(self, &block)

    self
  end

  def chars(&block)
    return each_char.to_a unless block

    each_char(&block)
  end

  def each_codepoint(&block)
    return enum_for :each_codepoint unless block_given?
    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        #{yield `self.codePointAt(i)`};
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
    `Opal.enc(self, encoding)`
  end

  def force_encoding(encoding)
    %x{
      var str = self;

      if (encoding === str.encoding) { return str; }

      if (typeof Opal.Encoding !== 'undefined' &&
          !Opal.is_a(encoding, Opal.Encoding)) {

        encoding = #{Opal.coerce_to!(encoding, String, :to_s)};
        encoding = #{Encoding.find(encoding)};
      }

      if (encoding === str.encoding) { return str; }

      str = Opal.set_encoding(str, encoding);

      return str;
    }
  end

  def getbyte(idx)
    string_bytes = bytes
    idx = Opal.coerce_to!(idx, Integer, :to_int)
    return if string_bytes.length < idx

    string_bytes[idx]
  end

  def initialize_copy(other)
    %{
      self.encoding = other.encoding;
      self.internal_encoding = other.internal_encoding;
    }
  end

  def length
    `self.length`
  end

  alias size length

  # stub
  def valid_encoding?
    true
  end
end

Encoding.default_external = __ENCODING__
