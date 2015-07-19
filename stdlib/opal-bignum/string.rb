class String

  def to_i(base = 10)
    %x{
      var result,
          string = self.toLowerCase(),
          radix = #{Opal.coerce_to(`base`, Integer, :to_int)};

      if (radix === 1 || radix < 0 || radix > 36) {
        #{raise ArgumentError, "invalid radix #{`radix`}"}
      }

      if (/^\s*_/.test(string)) {
        return 0;
      }

      string = string.replace(/^(\s*[+-]?)(0[bodx]?)(.+)$/, function (original, head, flag, tail) {
        switch (tail.charAt(0)) {
        case '+':
        case '-':
          return original;
        case '0':
          if (tail.charAt(1) === 'x' && flag === '0x' && (radix === 0 || radix === 16)) {
            return original;
          }
        }
        switch (flag) {
        case '0b':
          if (radix === 0 || radix === 2) {
            radix = 2;
            return head + tail;
          }
          break;
        case '0':
        case '0o':
          if (radix === 0 || radix === 8) {
            radix = 8;
            return head + tail;
          }
          break;
        case '0d':
          if (radix === 0 || radix === 10) {
            radix = 10;
            return head + tail;
          }
          break;
        case '0x':
          if (radix === 0 || radix === 16) {
            radix = 16;
            return head + tail;
          }
          break;
        }
        return original
      });
      if (radix === 0) {
        radix = 10;
      }
      var number_str = string.replace(/_(?!_)/g, '')
      result = parseInt(number_str, radix);
      if ( #{Fixnum.fits_in(`result`)} ) {
        return isNaN(result) ? 0 : result;
      } else {
        return #{Bignum.create_from_string(`number_str`, `radix`)};
      }
    }
  end

end
