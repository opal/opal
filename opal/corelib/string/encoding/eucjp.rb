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

::Encoding.register 'EUC-JP', ascii: true do
  def bytes(str)
    res = []
    %x{
      let unicode;
      for( const c of str ) {
        unicode = c.codePointAt(0);

        // ASCII
        if( unicode < 0x80 ) {
          res.push(unicode);
        }
        // HALFWIDTH_KATAKANA
        else if( 0xFF61 <= unicode && unicode <= 0xFF9F ) {
          res.push(0x8E);
          res.push(unicode - 0xFFC0);
        }
        else {
          // KANJI
          var jis = JISInverted[ unicode ];
          if( jis ) {
            res.push(( jis >> 8 ) - 0x80);
            res.push(( jis & 0xFF ) - 0x80);
          }
          else {
            // EXTENSION
            var ext = JISEXTInverted[ unicode ];
            if( ext ) {
              res.push(0x8F);
              res.push(( ext >> 8 ) - 0x80);
              res.push(( ext & 0xFF ) - 0x80);
            }
            // UNKNOWN
            else {
              res.push(( unknownJis >> 8 ) - 0x80);
              res.push(( unknownJis & 0xFF ) - 0x80);
            }
          }
        }
      }
    }
    res
  end

  def bytesize(str, index)
    %x{
      let unicode, size = 0;
      for( const c of str ) {
        unicode = c.codePointAt(0);
        // ASCII
        if( unicode < 0x80 ) { size++; }
        // HALFWIDTH_KATAKANA
        else if( 0xFF61 <= unicode && unicode <= 0xFF9F ) { size += 2; }
        else {
          // KANJI
          var jis = JISInverted[ unicode ];
          if( jis ) { size += 2; }
          else {
            // EXTENSION
            var ext = JISEXTInverted[ unicode ];
            if( ext ) { size += 3; }
            // UNKNOWN
            else { size += 2; }
          }
        }
        if (index-- <= 0) break;
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
      let result = scrubbing_decoder(self, 'euc-jp').decode(new Uint8Array(bytes_ary));
      if (result.length === 0) return nil;
      return $str(result, self);
    }
  end

  def decode(io_buffer)
    %x{
      let result = scrubbing_decoder(self, 'euc-jp').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def decode!(io_buffer)
    %x{
      let result = validating_decoder(self, 'euc-jp').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def each_byte(str)
    %x{
      let unicode;
      for( const c of str ) {
        unicode = c.codePointAt(0);

        // ASCII
        if( unicode < 0x80 ) {
          #{yield `unicode`};
        }
        // HALFWIDTH_KATAKANA
        else if( 0xFF61 <= unicode && unicode <= 0xFF9F ) {
          #{yield `0x8E`};
          #{yield `unicode - 0xFFC0`};
        }
        else {
          // KANJI
          var jis = JISInverted[ unicode ];
          if( jis ) {
            #{yield `( jis >> 8 ) - 0x80`};
            #{yield `( jis & 0xFF ) - 0x80`};
          }
          else {
            // EXTENSION
            var ext = JISEXTInverted[ unicode ];
            if( ext ) {
              #{yield `0x8F`};
              #{yield `( ext >> 8 ) - 0x80`};
              #{yield `( ext & 0xFF ) - 0x80`};
            }
            // UNKNOWN
            else {
              #{yield `( unknownJis >> 8 ) - 0x80`};
              #{yield `( unknownJis & 0xFF ) - 0x80`};
            }
          }
        }
      }
    }
  end

  def each_byte_buffer(str, io_buffer)
    b_size = io_buffer.size
    pos = 0
    %x{
      let unicode,
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
          set_byte(unicode);
        }
        // HALFWIDTH_KATAKANA
        else if( 0xFF61 <= unicode && unicode <= 0xFF9F ) {
          set_byte(0x8E);
          set_byte(unicode - 0xFFC0);
        }
        else {
          // KANJI
          var jis = JISInverted[ unicode ];
          if( jis ) {
            set_byte(( jis >> 8 ) - 0x80);
            set_byte(( jis & 0xFF ) - 0x80);
          }
          else {
            // EXTENSION
            var ext = JISEXTInverted[ unicode ];
            if( ext ) {
              set_byte(0x8F);
              set_byte(( ext >> 8 ) - 0x80);
              set_byte(( ext & 0xFF ) - 0x80);
            }
            // UNKNOWN
            else {
              set_byte(( unknownJis >> 8 ) - 0x80);
              set_byte(( unknownJis & 0xFF ) - 0x80);
            }
          }
        }
      }
    }
    str
  end

  def scrub(str, replacement, &block)
    %x{
      let result = scrubbing_decoder(self, 'euc-jp').decode(new Uint8Array(self.$bytes(str)));
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
      try { validating_decoder(self, 'euc-jp').decode(new Uint8Array(self.$bytes(str))); }
      catch { return false; }
      return true;
    }
  end
end
