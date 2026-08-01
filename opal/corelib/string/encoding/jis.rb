# backtick_javascript: true
# helpers: str

# inspired by
# Jconv
# Copyright (c) 2013-2014 narirou
# MIT Licensed
# https://github.com/narirou/jconv
# modified for Opal:
# https://github.com/janbiedermann/jconv/tree/for_opal
# only converts UCS2/UTF16 string to JIS/SJIS/EUCJP byte buffer
# performance:
# https://github.com/janbiedermann/jconv/blob/for_opal/test/chart/speedLog.txt

require 'corelib/string/encoding'
require 'corelib/string/encoding/tables/jis_inverted'
require 'corelib/string/encoding/tables/jis_ext_inverted'

%x{
  const JISInverted = Opal.Encoding.JISInverted;
  const JISEXTInverted = Opal.Encoding.JISEXTInverted;
  let unknownJis = JISInverted[ '・'.charCodeAt( 0 ) ];

  function scrubbing_decoder(enc, label) {
    if (!enc.scrubbing_decoder) enc.scrubbing_decoder = new TextDecoder(label, { fatal: false });
    return enc.scrubbing_decoder;
  }

  function validating_decoder(enc, label) {
    if (!enc.validating_decoder) enc.validating_decoder = new TextDecoder(label, { fatal: true });
    return enc.validating_decoder;
  }
}

::Encoding.register 'ISO-2022-JP', aliases: ['JIS'], ascii: true do
  def bytes(str)
    res = []
    %x{
      let sequence = 0, unicode;
      for( const c of str ) {
        unicode = c.codePointAt(0);
        // ASCII
        if( unicode < 0x80 ) {
          if( sequence !== 0 ) {
            sequence = 0;
            res.push(0x1B);
            res.push(0x28);
            res.push(0x42);
          }
          res.push(unicode);
        }
        // HALFWIDTH_KATAKANA
        else if( 0xFF61 <= unicode && unicode <= 0xFF9F ) {
          if( sequence !== 1 ) {
            sequence = 1;
            res.push(0x1B);
            res.push(0x28);
            res.push(0x49);
          }
          res.push(unicode - 0xFF40);
        }
        else {
          var code = JISInverted[ unicode ];
          if( code ) {
            // KANJI
            if( sequence !== 2 ) {
              sequence = 2;
              res.push(0x1B);
              res.push(0x24);
              res.push(0x42);
            }
            res.push(code >> 8);
            res.push(code & 0xFF);
          }
          else {
            var ext = JISEXTInverted[ unicode ];
            if( ext ) {
              // EXTENSION
              if( sequence !== 3 ) {
                sequence = 3;
                res.push(0x1B);
                res.push(0x24);
                res.push(0x28);
                res.push(0x44);
              }
              res.push(ext >> 8);
              res.push(ext & 0xFF);
            }
            else {
              // UNKNOWN
              if( sequence !== 2 ) {
                sequence = 2;
                res.push(0x1B);
                res.push(0x24);
                res.push(0x42);
              }
              res.push(unknownJis >> 8);
              res.push(unknownJis & 0xFF);
            }
          }
        }
      }
      // Add ASCII ESC
      if( sequence !== 0 ) {
        sequence = 0;
        res.push(0x1B);
        res.push(0x28);
        res.push(0x42);
      }
    }
    res
  end

  def bytesize(str, index)
    %x{
      let sequence = 0, size = 0, unicode;
      for( const c of str ) {
        unicode = c.codePointAt(0);
        // ASCII
        if( unicode < 0x80 ) {
          if( sequence !== 0 ) {
            sequence = 0;
            size += 3;
          }
          size++;
        }
        // HALFWIDTH_KATAKANA
        else if( 0xFF61 <= unicode && unicode <= 0xFF9F ) {
          if( sequence !== 1 ) {
            sequence = 1;
            size += 3;
          }
          size++;
        }
        else {
          var code = JISInverted[ unicode ];
          if( code ) {
            // KANJI
            if( sequence !== 2 ) {
              sequence = 2;
              size += 3;
            }
            size += 2;
          }
          else {
            var ext = JISEXTInverted[ unicode ];
            if( ext ) {
              // EXTENSION
              if( sequence !== 3 ) {
                sequence = 3;
                size += 4;
              }
              size += 2;
            }
            else {
              // UNKNOWN
              if( sequence !== 2 ) {
                sequence = 2;
                size += 3;
              }
              size += 2;
            }
          }
        }
        if (index-- <= 0) break;
      }
      // Add ASCII ESC
      if( sequence !== 0 ) {
        sequence = 0;
        size += 3;
      }
      return size;
    }
  end

  def byteslice(str, index, length)
    # Must handle negative index and length, with length being negative indicating a negative range end.
    %x{
      if (index < 0) index = str.length + index;
      if (index < 0) return nil;
      if (length < 0) length = (str.length + length) - index;
      if (length < 0) return nil;
      let bytes_ary = self.$bytes(str);
      bytes_ary = bytes_ary.slice(index, index + length);
      let result = scrubbing_decoder(self, 'iso-2022-jp').decode(new Uint8Array(bytes_ary));
      if (result.length === 0) return nil;
      return $str(result, self);
    }
  end

  def decode(io_buffer)
    %x{
      let result = scrubbing_decoder(self, 'iso-2022-jp').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def decode!(io_buffer)
    %x{
      let result = validating_decoder(self, 'iso-2022-jp').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str)
    %x{
      let sequence = 0, unicode;
      for( const c of str ) {
        unicode = c.codePointAt(0);
        // ASCII
        if( unicode < 0x80 ) {
          if( sequence !== 0 ) {
            sequence = 0;
            #{yield `0x1B`};
            #{yield `0x28`};
            #{yield `0x42`};
          }
          #{yield `unicode`};
        }
        // HALFWIDTH_KATAKANA
        else if( 0xFF61 <= unicode && unicode <= 0xFF9F ) {
          if( sequence !== 1 ) {
            sequence = 1;
            #{yield `0x1B`};
            #{yield `0x28`};
            #{yield `0x49`};
          }
          #{yield `unicode - 0xFF40`};
        }
        else {
          var code = JISInverted[ unicode ];
          if( code ) {
            // KANJI
            if( sequence !== 2 ) {
              sequence = 2;
              #{yield `0x1B`};
              #{yield `0x24`};
              #{yield `0x42`};
            }
            #{yield `code >> 8`};
            #{yield `code & 0xFF`};
          }
          else {
            var ext = JISEXTInverted[ unicode ];
            if( ext ) {
              // EXTENSION
              if( sequence !== 3 ) {
                sequence = 3;
                #{yield `0x1B`};
                #{yield `0x24`};
                #{yield `0x28`};
                #{yield `0x44`};
              }
              #{yield `ext >> 8`};
              #{yield `ext & 0xFF`};
            }
            else {
              // UNKNOWN
              if( sequence !== 2 ) {
                sequence = 2;
                #{yield `0x1B`};
                #{yield `0x24`};
                #{yield `0x42`};
              }
              #{yield `unknownJis >> 8`};
              #{yield `unknownJis & 0xFF`};
            }
          }
        }
      }
      // Add ASCII ESC
      if( sequence !== 0 ) {
        sequence = 0;
        #{yield `0x1B`};
        #{yield `0x28`};
        #{yield `0x42`};
      }
    }
  end

  def each_byte_buffer(str, io_buffer)
    b_size = io_buffer.size
    pos = 0
    %x{
      let sequence = 0,
          unicode,
          dv = io_buffer.data_view;

      function set_byte(byte) {
        if (pos === b_size) {
          #{yield pos}
          pos = 0;
        }
        dv.setUint8(pos++, byte);
      }

      for( const c of str ) {
        unicode = c.codePointAt(0);
        // ASCII
        if( unicode < 0x80 ) {
          if( sequence !== 0 ) {
            sequence = 0;
            set_byte(0x1B);
            set_byte(0x28);
            set_byte(0x42);
          }
          set_byte(unicode);
        }
        // HALFWIDTH_KATAKANA
        else if( 0xFF61 <= unicode && unicode <= 0xFF9F ) {
          if( sequence !== 1 ) {
            sequence = 1;
            set_byte(0x1B);
            set_byte(0x28);
            set_byte(0x49);
          }
          set_byte(unicode - 0xFF40);
        }
        else {
          var code = JISInverted[ unicode ];
          if( code ) {
            // KANJI
            if( sequence !== 2 ) {
              sequence = 2;
              set_byte(0x1B);
              set_byte(0x24);
              set_byte(0x42);
            }
            set_byte(code >> 8);
            set_byte(code & 0xFF);
          }
          else {
            var ext = JISEXTInverted[ unicode ];
            if( ext ) {
              // EXTENSION
              if( sequence !== 3 ) {
                sequence = 3;
                set_byte(0x1B);
                set_byte(0x24);
                set_byte(0x28);
                set_byte(0x44);
              }
              set_byte(ext >> 8);
              set_byte(ext & 0xFF);
            }
            else {
              // UNKNOWN
              if( sequence !== 2 ) {
                sequence = 2;
                set_byte(0x1B);
                set_byte(0x24);
                set_byte(0x42);
              }
              set_byte(unknownJis >> 8);
              set_byte(unknownJis & 0xFF);
            }
          }
        }
      }
      // Add ASCII ESC
      if( sequence !== 0 ) {
        sequence = 0;
        set_byte(0x1B);
        set_byte(0x28);
        set_byte(0x42);
      }
    }
    str
  end

  def scrub(str, replacement, &block)
    %x{
      let result = scrubbing_decoder(self, 'iso-2022-jp').decode(new Uint8Array(self.$bytes(str)));
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
      try { validating_decoder(self, 'iso-2022-jp').decode(new Uint8Array(self.$bytes(str))); }
      catch { return false; }
      return true;
    }
  end
end
