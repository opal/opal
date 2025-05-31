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
require 'corelib/string/encoding/tables/sjis_inverted'

%x{
  const SJISInverted = Opal.Encoding.SJISInverted;
  let unknownSjis = SJISInverted[ '・'.charCodeAt( 0 ) ];

  function scrubbing_decoder(enc, label) {
    if (!enc.scrubbing_decoder) enc.scrubbing_decoder = new TextDecoder(label, { fatal: false });
    return enc.scrubbing_decoder;
  }

  function validating_decoder(enc, label) {
    if (!enc.validating_decoder) enc.validating_decoder = new TextDecoder(label, { fatal: true });
    return enc.validating_decoder;
  }
}

::Encoding.register 'Shift_JIS', aliases: %w[SHIFT_JIS SJIS], ascii: true do
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
          res.push(unicode - 0xFEC0);
        }
        // KANJI
        else {
          let code = SJISInverted[ unicode ] || unknownSjis;
          res.push(code >> 8);
          res.push(code & 0xFF);
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
        else if( 0xFF61 <= unicode && unicode <= 0xFF9F ) { size++; }
        // KANJI
        else {
          let code = SJISInverted[ unicode ] || unknownSjis;
          size += 2;
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
      let result = scrubbing_decoder(self, 'sjis').decode(new Uint8Array(bytes_ary));
      if (result.length === 0) return nil;
      return $str(result, self);
    }
  end

  def decode(io_buffer)
    %x{
      let result = scrubbing_decoder(self, 'sjis').decode(io_buffer.data_view);
      return $str(result, self);
    }
  end

  def decode!(io_buffer)
    %x{
      let result = validating_decoder(self, 'sjis').decode(io_buffer.data_view);
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
          #{yield `unicode - 0xFEC0`};
        }
        // KANJI
        else {
          let code = SJISInverted[ unicode ] || unknownSjis;
          #{yield `code >> 8`};
          #{yield `code & 0xFF`};
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
          set_byte(unicode - 0xFEC0);
        }
        // KANJI
        else {
          let code = SJISInverted[ unicode ] || unknownSjis;
          set_byte(code >> 8);
          set_byte(code & 0xFF);
        }
      }
    }
    str
  end

  def scrub(str, replacement, &block)
    %x{
      let result = scrubbing_decoder(self, 'sjis').decode(new Uint8Array(self.$bytes(str)));
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
      try { validating_decoder(self, 'sjis').decode(new Uint8Array(self.$bytes(str))); }
      catch { return false; }
      return true;
    }
  end
end
