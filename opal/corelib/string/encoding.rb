# backtick_javascript: true
# helpers: str

class ::Encoding
  class << self
    def register(name, options = {}, &block)
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

    def find(name)
      return default_external if name == :default_external
      `return Opal.find_encoding(name)`
    end

    attr_accessor :default_external, :default_internal
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

  def bytesize(str, index)
    ::Kernel.raise ::NotImplementedError
  end

  def byteslice(str, index, length)
    ::Kernel.raise ::NotImplementedError
  end

  def decode(io_buffer)
    ::Kernel.raise ::NotImplementedError
  end

  def each_byte(str)
    ::Kernel.raise ::NotImplementedError
  end

  def scrub(str, replacement, &block)
    ::Kernel.raise ::NotImplementedError
  end

  def valid_encoding?(str)
    ::Kernel.raise ::NotImplementedError
  end

  class ::EncodingError < ::StandardError; end
  class ::CompatibilityError < ::EncodingError; end
  class UndefinedConversionError < ::EncodingError; end
end

%x{
  const SFCP = String.fromCodePoint;
  const SFCC = String.fromCharCode;

  function scrubbing_decoder(enc, label) {
    if (!enc.scrubbing_decoder) enc.scrubbing_decoder = new TextDecoder(label, { fatal: false });
    return enc.scrubbing_decoder;
  }

  function validating_decoder(enc, label) {
    if (!enc.validating_decoder) enc.validating_decoder = new TextDecoder(label, { fatal: true });
    return enc.validating_decoder;
  }
}

::Encoding.register 'UTF-8', aliases: ['CP65001'], ascii: true do
  def bytesize(str, index)
    %x{
      let code_point, size = 0;
      for (const c of str) {
        code_point = c.codePointAt(0);
        if (code_point < 0x80) size++; // char is one byte long in UTF-8
        else if (code_point < 0x800) size += 2; // char is two bytes long
        // else if (code_point < 0xD800) size += 3; // char is three bytes long
        // else if (code_point < 0xE000) size += 3; // for lone surrogates the 0xBD 0xBF 0xEF, 3 bytes, get inserted
        else if (code_point < 0x10000) size += 3; // char is three bytes long
        else if (code_point <= 0x110000) size += 4; // char is four bytes long
        if (index-- <= 0) break;
      }
      return size;
    }
  end

  def byteslice(str, index, length)
    # Must handle negative index and length, with length being negative indicating a negative range end.
    # This slices at UTF-16 character boundaries, as required by specs.
    # However, some specs require slicing UTF-16 characters into its bytes, which won't work.
    %x{
      let result = "", code_point, idx, max;
      if (index < 0) {
        // negative index, walk from the end of the string,
        let i = str.length - 1,
            bad_cp = -1; // -1 = no, string ok, 0 or larger = the code point
        idx = -1;
        if (length < 0) max = length; // a negative index
        else if (length === 0) max = index;
        else if ((index + length) >= 0) max = -1; // from end of string
        else max = index + length - 1;
        for (; i >= 0; i--) {
          code_point = str.codePointAt(i);
          if (code_point >= 0xD800 && code_point <= 0xDFFF) {
            // low surrogate, get the full code_point next
            continue;
          }
          if (length >= 0 || length === -1 || (length < 0 && idx <= length)) {
            if (code_point < 0x80) {
              if (idx >= index && idx <= max) result = SFCP(code_point) + result;
              idx--;
              // always landing on character boundary, no need to check
            } else if (code_point < 0x800) {
              // 2 byte surrogates
              if (idx >= index && idx <= max) result = SFCP(code_point) + result;
              idx -= 2;
              // check for broken character boundary, raise if so
            // } else if (code_point < 0xD800) {
            //  // 3 byte surrogates
            //  if (idx >= index && idx <= max) result = SFCP(code_point) + result;
            //  idx -= 3;
            } else if (code_point < 0x10000) {
              // 3 byte surrogates
              if (idx >= index && idx <= max) result = SFCP(code_point) + result;
              idx -= 3;
            } else if (code_point < 0x110000) {
              // 4 byte surrogates
              if (idx >= index && idx <= max) result = SFCP(code_point) + result;
              idx -= 3;
            }
          }
          if (idx < index) break;
        }
        if (idx > index || result.length === 0) return nil;
      } else {
        // 0 or positive index, walk from beginning
        idx = 0;
        if (length < 0) max = Infinity; // to end of string
        else if (length === 0) max = index + 1;
        else max = index + length;
        for (const c of str) {
          code_point = c.codePointAt(0);
          if (code_point < 0x80) {
            if (idx >= index && idx <= max) result += SFCP(code_point);
            idx++;
          } else if (code_point < 0x800) {
            // 2 byte surrogates
            if (idx >= index && idx <= max) result += SFCP(code_point);
            idx += 2;
          } else if (code_point < 0xD800) {
            // 3 byte surrogates
            if (idx >= index && idx <= max) result += SFCP(code_point);
            idx += 3;
          } else if (code_point < 0xE000) {
            if (idx >= index && idx <= max) result += SFCP(0xEF); idx++;
            if (idx >= index && idx <= max) result += SFCP(0xBF); idx++;
            if (idx >= index && idx <= max) result += SFCP(0xBD); idx++;
          } else if (code_point < 0x10000) {
            // 3 byte surrogates
            if (idx >= index && idx <= max) result += SFCP(code_point);
            idx += 3;
          } else if (code_point < 0x110000) {
            // 4 byte surrogates
            if (idx >= index && idx <= max) result += SFCP(code_point);
            idx += 4;
          }
          if (idx >= max) break;
        }
        if (result.length === 0) {
          if (idx === index) result = "";
          else return nil;
        }
        if (length < 0) {
          // if length is a negative index from a range, we walked to the end,
          // so shorten the result accordingly
          // result has the bytes already spread out as chars so we can simply slice
          if ((idx + length) > 0) result = result.slice(0, result.length + length);
          else result = "";
        }
      }
      if (length === 0) result = "";
      return result;
    }
  end

  def decode(io_buffer)
    %x{
      let result = (new TextDecoder('utf-8')).decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str, &block)
    %x{
      let units = Infinity,
          code_point,
          length = str.length;
      for (const c of str) {
        code_point = c.codePointAt(0);
        if (code_point < 0x80) {
          #{yield `code_point`};
        } else if (code_point < 0x800) {
          #{yield `code_point >> 0x6 | 0xC0`};
          #{yield `code_point & 0x3F | 0x80`};
        } else if (code_point < 0xD800) {
          #{yield `code_point >> 0xC | 0xE0`};
          #{yield `code_point >> 0x6 & 0x3F | 0x80`};
          #{yield `code_point & 0x3F | 0x80`};
        } else if (code_point < 0xE000) {
          #{yield `0xEF`};
          #{yield `0xBF`};
          #{yield `0xBD`};
        } else if (code_point < 0x10000) {
          #{yield `code_point >> 0xC | 0xE0`};
          #{yield `code_point >> 0x6 & 0x3F | 0x80`};
          #{yield `code_point & 0x3F | 0x80`};
        } else if (code_point < 0x110000) {
          #{yield `code_point >> 0x12 | 0xF0`};
          #{yield `code_point >> 0xC & 0x3F | 0x80`};
          #{yield `code_point >> 0x6 & 0x3F | 0x80`};
          #{yield `code_point & 0x3F | 0x80`};
        }
      }
    }
  end

  def scrub(str, replacement, &block)
    %x{
      let result = scrubbing_decoder(self, 'utf-8').decode(new Uint8Array(str.$bytes()));
      if (block !== nil) {
        // dont know the bytes anymore ... ¯\_(ツ)_/¯
        result = result.replace(/�/g, (byte)=>{ return #{yield `byte`}; });
      } else if (replacement && replacement !== nil) {
        // this may replace valid � that have existed in the string before,
        // but there currently is no way to specify a other replacement character for TextDecoder
        result = result.replace(/�/g, replacement);
      }
      return $str(result, self);
    }
  end

  def valid_encoding?(str)
    %x{
      try { validating_decoder(self, 'utf-8').decode(new Uint8Array(str.$bytes())); }
      catch { return false; }
      return true;
    }
  end
end

::Encoding.register 'UTF-16LE', aliases: ['UTF-16'] do
  def bytesize(str, index)
    %x{
      if (index < str.length) return (index + 1) * 2;
      return str.length * 2;
    }
  end

  def byteslice(str, index, length)
    # Must handle negative index and length, with length being negative indicating a negative range end.
    %x{
      let result = "", char_code, idx, max, i;
      if (index < 0) {
        // negative index, walk from the end of the string,
        idx = -1;
        if (length < 0) max = length; // a negative index
        else if (length === 0) max = index;
        else if ((index + length) >= 0) max = -1; // from end of string
        else max = index + length - 1;
        for (i = str.length; i > 0; i--) {
          char_code = str.charCodeAt(i);
          if (length >= 0 || length === -1 || (length < 0 && idx <= length)) {
            if (idx >= index && idx <= max) result = SFCC(char_code) + result;
          }
          idx -= 2;
          if (idx < index) break;
        }
        if (idx > index || result.length === 0) return nil;
      } else {
        // 0 or positive index, walk from beginning
        idx = 0;
        if (length < 0) max = Infinity;
        else if (length === 0) max = index + 1;
        else max = index + length;
        for (i = 0, length = str.length; i < length; i++) {
          char_code = str.charCodeAt(i);
          if (idx >= index && idx <= max) result += SFCC(char_code);
          idx += 2;
          if (idx >= max) break;
        }
        if (result.length === 0) {
          if (idx === index) result = "";
          else return nil;
        }
        if (length < 0) {
          // if length is a negative index from a range, we walked to the end, so shorten the result
          if ((idx + length) > 0) result = result.slice(0, result.length + length);
          else result = "";
        }
      }
      if (length === 0) result = "";
      return result;
    }
  end

  def decode(io_buffer)
    %x{
      let result = (new TextDecoder('utf-16le')).decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str, &block)
    %x{
      for (let i = 0, length = str.length; i < length; i++) {
        let char_code = str.charCodeAt(i);

        #{yield `char_code & 0xff`};
        #{yield `char_code >> 8`};
      }
    }
  end

  def scrub(str, replacement, &block)
    %x{
      let result = scrubbing_decoder(self, 'utf-16').decode(new Uint8Array(str.$bytes()));
      if (block !== nil) {
        // dont know the bytes anymore ... ¯\_(ツ)_/¯
        result = result.replace(/�/g, (byte)=>{ return #{yield `byte`}; });
      } else if (replacement && replacement !== nil) {
        // this may replace valid � that have existed in the string before,
        // but there currently is no way to specify a other replacement character for TextDecoder
        result = result.replace(/�/g, replacement);
      }
      return $str(result, self);
    }
  end

  def valid_encoding?(str)
    %x{
      try { validating_decoder(self, 'utf-16').decode(new Uint8Array(str.$bytes())); }
      catch { return false; }
      return true;
    }
  end
end

::Encoding.register 'UTF-16BE', inherits: ::Encoding::UTF_16LE do
  def decode(io_buffer)
    %x{
      let result = (new TextDecoder('utf-16be')).decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str, &block)
    %x{
      for (var i = 0, length = str.length; i < length; i++) {
        var char_code = str.charCodeAt(i);
        #{yield `char_code >> 8`};
        #{yield `char_code & 0xff`};
      }
    }
  end

  def scrub(str, replacement, &block)
    %x{
      let result = scrubbing_decoder(self, 'utf-16be').decode(new Uint8Array(str.$bytes()));
      if (block !== nil) {
        // dont know the bytes anymore ... ¯\_(ツ)_/¯
        result = result.replace(/�/g, (byte)=>{ return #{yield `byte`}; });
      } else if (replacement && replacement !== nil) {
        // this may replace valid � that have existed in the string before,
        // but there currently is no way to specify a other replacement character for TextDecoder
        result = result.replace(/�/g, replacement);
      }
      return $str(result, self);
    }
  end

  def valid_encoding?(str)
    %x{
      try { validating_decoder(self, 'utf-16be').decode(new Uint8Array(str.$bytes())); }
      catch { return false; }
      return true;
    }
  end
end

::Encoding.register 'UTF-32LE' do
  def bytesize(str, index)
    %x{
      if (index < str.length) return (index + 1) * 4;
      return str.length * 4;
    }
  end

  def byteslice(str, index, length)
    # Must handle negative index and length, with length being negative indicating a negative range end.
    %x{
      let result = "", char_code, idx, max, i;
      if (index < 0) {
        // negative index, walk from the end of the string,
        idx = -1;
        if (length < 0) max = length; // a negative index
        else if (length === 0) max = index;
        else if ((index + length) >= 0) max = -1; // from end of string
        else max = index + length - 1;
        for (i = str.length; i > 0; i--) {
          char_code = str.charCodeAt(i);
          if (length > 0 || length === -1 || (length < 0 && idx <= length)) {
            if (idx >= index && idx <= max) result = SFCC(char_code) + result;
          }
          idx -= 4;
          if (idx < index) break;
        }
        if (idx > index || result.length === 0) return nil;
      } else {
        // 0 or positive index, walk from beginning
        idx = 0;
        if (length < 0) max = Infinity;
        else if (length === 0) max = index + 1;
        else max = index + length;
        for (let i = 0, length = str.length; i < length; i++) {
          char_code = str.charCodeAt(i);
          if (idx >= index && idx <= max) result += SFCC(char_code);
          idx += 4;
          if (idx >= max) break;
        }
        if (result.length === 0) {
          if (idx === index) result = "";
          else return nil;
        }
        if (length < 0) {
          // if length is a negative index from a range, we walked to the end, so shorten the result
          if ((idx + length) > 0) result = result.slice(0, result.length + length);
          else result = "";
        }
      }
      if (length === 0) result = "";
      return result;
    }
  end

  def each_byte(str, &block)
    %x{
      for (var i = 0, length = str.length; i < length; i++) {
        var char_code = str.charCodeAt(i);

        #{yield `char_code & 0xff`};
        #{yield `char_code >> 8`};
        #{yield 0};
        #{yield 0};
      }
    }
  end

  def scrub(str, replacement, &block)
    str
  end

  def valid_encoding?(str)
    true
  end
end

::Encoding.register 'UTF-32BE', inherits: ::Encoding::UTF_32LE do
  def each_byte(str, &block)
    %x{
      for (var i = 0, length = str.length; i < length; i++) {
        var char_code = str.charCodeAt(i);
        #{yield 0};
        #{yield 0};
        #{yield `char_code >> 8`};
        #{yield `char_code & 0xff`};
      }
    }
  end
end

::Encoding.register 'ASCII-8BIT', aliases: ['BINARY'], ascii: true do
  def binary?
    true
  end

  def bytesize(str, index)
    %x{
      if (index < str.size) return index + 1;
      return str.length;
    }
  end

  def byteslice(str, index, length)
    # Must handle negative index and length, with length being negative indicating a negative range end.
    %x{
      let result = "", char_code, i;
      if (index < 0) index = str.length + index;
      if (index < 0) return nil;
      if (length < 0) length = (str.length + length) - index;
      if (length < 0) return nil;
      // must produce the same result as each_byte, so we cannot simply use slice()
      for (i = 0; i < length && (index + i) <= str.length; i++) {
        char_code = str.charCodeAt(index + i);
        result = SFCC(char_code & 0xff) + result;
      }
      if (result.length === 0) return nil;
      return result;
    }
  end

  def decode(io_buffer)
    %x{
      let result = (new TextDecoder('ascii')).decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str, &block)
    %x{
      for (let i = 0, length = str.length; i < length; i++) {
        let char_code = str.charCodeAt(i);
        #{yield `char_code & 0xff`};
      }
    }
  end

  def scrub(str, replacement, &block)
    %x{
      let result = scrubbing_decoder(self, 'ascii').decode(new Uint8Array(str.$bytes()));
      if (block !== nil) {
        // dont know all the bytes anymore ... ¯\_(ツ)_/¯
        result = result.replace(/[�\x80-\xff]/g, (byte)=>{ return #{yield `byte`}; });
      } else if (replacement && replacement !== nil) {
        // this may replace valid � that have existed in the string before,
        // but there currently is no way to specify a other replacement character for TextDecoder
        result = result.replace(/[�\x80-\xff]/g, replacement);
      } else {
        result = result.replace(/[�\x80-\xff]/g, '?');
      }
      return $str(result, self);
    }
  end

  def valid_encoding?(str)
    %x{
      try { validating_decoder(self, 'ascii').decode(new Uint8Array(str.$bytes())); }
      catch { return false; }
      return true;
    }
  end
end

::Encoding.register 'ISO-8859-1', aliases: ['ISO8859-1'], ascii: true, inherits: ::Encoding::ASCII_8BIT
::Encoding.register 'US-ASCII', aliases: ['ASCII'], ascii: true, inherits: ::Encoding::ASCII_8BIT

::Encoding.default_external = __ENCODING__
::Encoding.default_internal = __ENCODING__

`Opal.prop(String.prototype, 'encoding', #{::Encoding::UTF_8})`
`Opal.prop(String.prototype, 'internal_encoding', #{::Encoding::UTF_8})`
