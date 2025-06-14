# backtick_javascript: true
# helpers: str

class ::Encoding
  class << self
    attr_reader :default_external, :default_internal

    def register(name, options = {}, &block)
      names = if options.key?(:aliases)
                options[:aliases].each do |a|
                  aliases[a] = name
                end
                [name] + options[:aliases]
              else
                [name]
              end

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

    def aliases
      @aliases ||= {}
    end

    def compatible?(obj1, obj2)
      # Opal is different from Ruby and enables a more universal comatibility
      # of encodings, because the representation of a Ruby String with a JS String
      # makes them all UTF-16 "internally". This makes them all concatenable.
      # However, what matters is the binary representation. If the concatenated
      # string is written and source strings would not have a compatible binary
      # encoding, writing the concatened string into one file would lead to
      # different bytes written than writing each string to the same file,
      # concatenating them in the file.
      # If following the facts, Opal fails specs, because its encodings are
      # compatible in a different way than Ruby specs assume.
      # Also when comparing the #binary_encoding of strings here to ensure compatibility,
      # it makes no sense to return the #encoding. If later on the same #encoding is used
      # for a new string, it may still not be compatible if the #binary_encoding differs.
      # We should ideally return a encoding pair (#encoding and #binary_encoding) instead,
      # to ensure compatible strings can be constructed.
      # But thats way outside of Ruby specs for this method.

      # Maybe we can provide a Opal specific API in the future in ::Opal space.

      # For the moment just return nil (meaning: not compatible), still passes a few specs ;-)
      nil
    end

    def default_external=(enc)
      raise(ArgumentError, 'enc must be given') if enc.nil?
      unless enc.is_a?(::Encoding)
        enc = ::Opal.coerce_to!(enc, ::String, :to_str)
        enc = find(enc)
      end
      aliases['external'] = enc.name
      `Opal.encodings["EXTERNAL"] = enc`
      @default_external.names.delete('external') if @default_external
      enc.names << 'external' unless enc.names.include?('external')
      @default_external	= enc
    end

    def default_internal=(enc)
      return @default_internal = nil if enc.nil?
      unless enc.is_a?(::Encoding)
        enc = ::Opal.coerce_to!(enc, ::String, :to_str)
        enc = find(enc)
      end
      @default_internal	= enc
    end

    def find(name)
      return name if name.is_a?(::Encoding)
      name = ::Opal.coerce_to!(name, ::String, :to_str)
      return default_external if %w[external filesystem locale].include?(name)
      return default_internal if name == 'internal'
      `Opal.find_encoding(name)`
    end

    def list
      constants.map! { |e| const_get(e) }.uniq!.select! { |e| e.is_a?(::Encoding) }
    end

    def locale_charmap
      nil
    end

    def name_list
      list.map(&:names).flatten
    end
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
  def bytes(str)
    __not_implemented__
  end

  def bytesize(str, index)
    __not_implemented__
  end

  def byteslice(str, index, length)
    __not_implemented__
  end

  def decode(io_buffer)
    __not_implemented__
  end

  def decode!(io_buffer)
    __not_implemented__
  end

  def each_byte(str, &block)
    __not_implemented__
  end

  # Fills io_buffer with bytes of str and yields the number
  # of valid bytes in io_buffer to the block.
  # Repeats until end of str while reusing io_buffer.
  # In other words: io_buffer is used as a sliding window over str.
  def each_byte_buffer(str, io_buffer, &block)
    __not_implemented__
  end

  def scrub(str, replacement, &block)
    __not_implemented__
  end

  def valid_encoding?(str)
    __not_implemented__
  end

  class ::EncodingError < ::StandardError; end
  class ::CompatibilityError < ::EncodingError; end
  class InvalidByteSequenceError < ::EncodingError; end
  class UndefinedConversionError < ::EncodingError; end
end

%x{
  const SFCP = String.fromCodePoint;
  const SFCC = String.fromCharCode;

  function scrubbing_decoder(enc, label) {
    if (!enc.scrubbing_decoder) enc.scrubbing_decoder = new Opal.platform.text_decoder(label, { fatal: false });
    return enc.scrubbing_decoder;
  }

  function validating_decoder(enc, label) {
    if (!enc.validating_decoder) enc.validating_decoder = new Opal.platform.text_decoder(label, { fatal: true });
    return enc.validating_decoder;
  }
}

::Encoding.register 'UTF-8', aliases: ['CP65001'], ascii: true do
  def bytes(str)
    res = []
    %x{
      let code_point;
      for (const c of str) {
        code_point = c.codePointAt(0);
        if (code_point < 0x80) {
          res.push(code_point);
        } else if (code_point < 0x800) {
          res.push(code_point >> 0x6 | 0xC0);
          res.push(code_point & 0x3F | 0x80);
        } else if (code_point < 0xD800) {
          res.push(code_point >> 0xC | 0xE0);
          res.push(code_point >> 0x6 & 0x3F | 0x80);
          res.push(code_point & 0x3F | 0x80);
        } else if (code_point < 0xE000) {
          res.push(0xEF);
          res.push(0xBF);
          res.push(0xBD);
        } else if (code_point < 0x10000) {
          res.push(code_point >> 0xC | 0xE0);
          res.push(code_point >> 0x6 & 0x3F | 0x80);
          res.push(code_point & 0x3F | 0x80);
        } else if (code_point < 0x110000) {
          res.push(code_point >> 0x12 | 0xF0);
          res.push(code_point >> 0xC & 0x3F | 0x80);
          res.push(code_point >> 0x6 & 0x3F | 0x80);
          res.push(code_point & 0x3F | 0x80);
        }
      }
    }
    res
  end

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
      let result = scrubbing_decoder(self, 'utf-8').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def decode!(io_buffer)
    %x{
      let result = validating_decoder(self, 'utf-8').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str)
    %x{
      let code_point;
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

  def each_byte_buffer(str, io_buffer)
    b_size = io_buffer.size
    pos = 0
    %x{
      let code_point,
          dv = io_buffer.data_view;

      function set_byte(byte) {
        if (pos === b_size) {
          #{yield pos}
          pos = 0;
        }
        dv.setUint8(pos++, byte);
      }

      for (const c of str) {
        code_point = c.codePointAt(0);
        if (code_point < 0x80) {
          set_byte(code_point);
        } else if (code_point < 0x800) {
          set_byte(code_point >> 0x6 | 0xC0);
          set_byte(code_point & 0x3F | 0x80);
        } else if (code_point < 0xD800) {
          set_byte(code_point >> 0xC | 0xE0);
          set_byte(code_point >> 0x6 & 0x3F | 0x80);
          set_byte(code_point & 0x3F | 0x80);
        } else if (code_point < 0xE000) {
          set_byte(0xEF);
          set_byte(0xBF);
          set_byte(0xBD);
        } else if (code_point < 0x10000) {
          set_byte(code_point >> 0xC | 0xE0);
          set_byte(code_point >> 0x6 & 0x3F | 0x80);
          set_byte(code_point & 0x3F | 0x80);
        } else if (code_point < 0x110000) {
          set_byte(code_point >> 0x12 | 0xF0);
          set_byte(code_point >> 0xC & 0x3F | 0x80);
          set_byte(code_point >> 0x6 & 0x3F | 0x80);
          set_byte(code_point & 0x3F | 0x80);
        }
      }

      if (pos > 0) { #{yield pos} }
    }
    str
  end

  def scrub(str, replacement, &block)
    %x{
      let result = scrubbing_decoder(self, 'utf-8').decode(new Uint8Array(self.$bytes(str)));
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
      try { validating_decoder(self, 'utf-8').decode(new Uint8Array(self.$bytes(str))); }
      catch { return false; }
      return true;
    }
  end
end

::Encoding.register 'UTF-16LE', aliases: ['UTF-16'] do
  def bytes(str)
    res = []
    %x{
      for (let char_code, i = 0, length = str.length; i < length; i++) {
        char_code = str.charCodeAt(i);
        res.push(char_code & 0xff);
        res.push(char_code >> 8);
      }
    }
    res
  end

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
      let result = scrubbing_decoder(self, 'utf-16le').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def decode!(io_buffer)
    %x{
      let result = validating_decoder(self, 'utf-16le').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str)
    %x{
      for (let i = 0, length = str.length; i < length; i++) {
        let char_code = str.charCodeAt(i);

        #{yield `char_code & 0xff`};
        #{yield `char_code >> 8`};
      }
    }
  end

  def each_byte_buffer(str, io_buffer)
    b_size = io_buffer.size
    pos = 0
    %x{
      let char_code,
          dv = io_buffer.data_view;

      function set_byte(byte) {
        if (pos === b_size) {
          #{yield pos}
          pos = 0;
        }
        dv.setUint8(pos++, byte);
      }

      for (let i = 0, length = str.length; i < length; i++) {
        char_code = str.charCodeAt(i);
        set_byte(char_code & 0xff);
        set_byte(char_code >> 8);
      }

      if (pos > 0) { #{yield pos} }
    }
    str
  end

  def scrub(str, replacement, &block)
    %x{
      let result = scrubbing_decoder(self, 'utf-16le').decode(new Uint8Array(self.$bytes(str)));
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
      try { validating_decoder(self, 'utf-16').decode(new Uint8Array(self.$bytes(str))); }
      catch { return false; }
      return true;
    }
  end
end

::Encoding.register 'UTF-16BE', inherits: ::Encoding::UTF_16LE do
  def bytes(str)
    res = []
    %x{
      for (let char_code, i = 0, length = str.length; i < length; i++) {
        char_code = str.charCodeAt(i);
        res.push(char_code >> 8);
        res.push(char_code & 0xff);
      }
    }
    res
  end

  def decode(io_buffer)
    %x{
      let result = scrubbing_decoder(self, 'utf-16be').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def decode!(io_buffer)
    %x{
      let result = validating_decoder(self, 'utf-16be').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str)
    %x{
      for (var i = 0, length = str.length; i < length; i++) {
        var char_code = str.charCodeAt(i);
        #{yield `char_code >> 8`};
        #{yield `char_code & 0xff`};
      }
    }
  end

  def each_byte_buffer(str, io_buffer)
    b_size = io_buffer.size
    pos = 0
    %x{
      let char_code,
          dv = io_buffer.data_view;

      function set_byte(byte) {
        if (pos === b_size) {
          #{yield pos}
          pos = 0;
        }
        dv.setUint8(pos++, byte);
      }

      for (let i = 0, length = str.length; i < length; i++) {
        char_code = str.charCodeAt(i);
        set_byte(char_code >> 8);
        set_byte(char_code & 0xff);
      }

      if (pos > 0) { #{yield pos} }
    }
    str
  end

  def scrub(str, replacement, &block)
    %x{
      let result = scrubbing_decoder(self, 'utf-16be').decode(new Uint8Array(self.$bytes(str)));
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
      try { validating_decoder(self, 'utf-16be').decode(new Uint8Array(self.$bytes(str))); }
      catch { return false; }
      return true;
    }
  end
end

::Encoding.register 'UTF-32LE' do
  def bytes(str)
    res = []
    %x{
      for (let char_code, i = 0, length = str.length; i < length; i++) {
        char_code = str.charCodeAt(i);
        res.push(char_code & 0xff);
        res.push(char_code >> 8);
        res.push(0);
        res.push(0);
      }
    }
    res
  end

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

  def decode(io_buffer)
    %x{
      let i = 0, o = 0,
          io_dv = io_buffer.data_view,
          io_dv_bl = io_dv.byteLength,
          data_view = new DataView(new ArrayBuffer(Math.ceil(io_dv_bl / 2)));
      while (i < io_dv_bl) {
        data_view.setUint8(o++, io_dv.getUint8(i++));
        if (i < io_dv_bl) data_view.setUint8(o++, io_dv.getUint8(i++));
        i += 2;
      }
      let result = scrubbing_decoder(self, 'utf-16').decode(data_view);
      return $str(result, self);
    }
  end

  def decode!(io_buffer)
    %x{
      let i = 0, o = 0,
          io_dv = io_buffer.data_view,
          io_dv_bl = io_dv.byteLength,
          data_view = new DataView(new ArrayBuffer(Math.ceil(io_dv_bl / 2)));
      while (i < io_dv_bl) {
        data_view.setUint8(o++, io_dv.getUint8(i++));
        if (i < io_dv_bl) data_view.setUint8(o++, io_dv.getUint8(i++));
        i += 2;
      }
      let result = validating_decoder(self, 'utf-16').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str)
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

  def each_byte_buffer(str, io_buffer)
    b_size = io_buffer.size
    pos = 0
    %x{
      let char_code,
          dv = io_buffer.data_view;

      function set_byte(byte) {
        if (pos === b_size) {
          #{yield pos}
          pos = 0;
        }
        dv.setUint8(pos++, byte);
      }

      for (let i = 0, length = str.length; i < length; i++) {
        char_code = str.charCodeAt(i);
        set_byte(char_code & 0xff);
        set_byte(char_code >> 8);
        set_byte(0);
        set_byte(0);
      }

      if (pos > 0) { #{yield pos} }
    }
    str
  end

  def scrub(str, replacement)
    str
  end

  def valid_encoding?(str)
    true
  end
end

::Encoding.register 'UTF-32BE', inherits: ::Encoding::UTF_32LE do
  def bytes(str)
    res = []
    %x{
      for (let char_code, i = 0, length = str.length; i < length; i++) {
        char_code = str.charCodeAt(i);
        res.push(0);
        res.push(0);
        res.push(char_code >> 8);
        res.push(char_code & 0xff);
      }
    }
    res
  end

  def decode(io_buffer)
    %x{
      let i = 0, o = 0,
          io_dv = io_buffer.data_view,
          io_dv_bl = io_dv.byteLength,
          data_view = new DataView(new ArrayBuffer(Math.floor(io_dv_bl / 2)));
      while (i < io_dv_bl) {
        i += 2;
        if (i < io_dv_bl) data_view.setUint8(o++, io_dv.getUint8(i++));
        if (i < io_dv_bl) data_view.setUint8(o++, io_dv.getUint8(i++));
      }
      let result = scrubbing_decoder(self, 'utf-16').decode(data_view);
      return $str(result, self);
    }
  end

  def decode!(io_buffer)
    %x{
      let i = 0, o = 0,
          io_dv = io_buffer.data_view,
          io_dv_bl = io_dv.byteLength,
          data_view = new DataView(new ArrayBuffer(Math.floor(io_dv_bl / 2)));
      while (i < io_dv_bl) {
        i += 2;
        if (i < io_dv_bl) data_view.setUint8(o++, io_dv.getUint8(i++));
        if (i < io_dv_bl) data_view.setUint8(o++, io_dv.getUint8(i++));
      }
      let result = validating_decoder(self, 'utf-16').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str)
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

  def each_byte_buffer(str, io_buffer)
    b_size = io_buffer.size
    pos = 0
    %x{
      let char_code,
          dv = io_buffer.data_view;

      function set_byte(byte) {
        if (pos === b_size) {
          #{yield pos}
          pos = 0;
        }
        dv.setUint8(pos++, byte);
      }

      for (let i = 0, length = str.length; i < length; i++) {
        char_code = str.charCodeAt(i);
        set_byte(0);
        set_byte(0);
        set_byte(char_code >> 8);
        set_byte(char_code & 0xff);
      }

      if (pos > 0) { #{yield pos} }
    }
    str
  end
end

::Encoding.register 'ASCII-8BIT', aliases: ['BINARY'], ascii: true do
  def bytes(str)
    res = []
    %x{
      for (let char_code, i = 0, length = str.length; i < length; i++) {
        char_code = str.charCodeAt(i);
        if (char_code > 0xff) res.push(char_code >> 8);
        res.push(char_code & 0xff);
      }
    }
    res
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
      let result = scrubbing_decoder(self, 'ascii').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def decode!(io_buffer)
    %x{
      let result = validating_decoder(self, 'ascii').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str)
    %x{
      for (let char_code, i = 0, length = str.length; i < length; i++) {
        char_code = str.charCodeAt(i);
        if (char_code > 0xff) #{yield `char_code >> 8`};
        #{yield `char_code & 0xff`};
      }
    }
  end

  def each_byte_buffer(str, io_buffer)
    b_size = io_buffer.size
    pos = 0
    %x{
      let dv = io_buffer.data_view;

      function set_byte(byte) {
        if (pos === b_size) {
          #{yield pos}
          pos = 0;
        }
        dv.setUint8(pos++, byte);
      }

      for (let char_code, i = 0, length = str.length; i < length; i++) {
        char_code = str.charCodeAt(i);
        if (char_code > 0xff) set_byte(char_code >> 8);
        set_byte(char_code & 0xff);
      }

      if (pos > 0) { #{yield pos} }
    }
    str
  end

  def scrub(str, replacement, &block)
    %x{
      let result = scrubbing_decoder(self, 'ascii').decode(new Uint8Array(self.$bytes(str)));
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
      try { validating_decoder(self, 'ascii').decode(new Uint8Array(self.$bytes(str))); }
      catch { return false; }
      return true;
    }
  end
end

::Encoding.register 'ISO-8859-1', aliases: ['ISO8859-1'], ascii: true, inherits: ::Encoding::ASCII_8BIT
::Encoding.register 'US-ASCII', aliases: ['ASCII'], ascii: true, inherits: ::Encoding::ASCII_8BIT

::Encoding.default_external = __ENCODING__

`Opal.prop(String.prototype, 'encoding', #{::Encoding::UTF_8})`
`Opal.prop(String.prototype, 'binary_encoding', #{::Encoding::UTF_8})`
