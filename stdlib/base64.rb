# use_strict: true
# frozen_string_literal: true

module Base64
  # FROM https://github.com/davidchambers/Base64.js/blob/69262ec7e1fa4541de5700a1b0b03b0de0e3f5aa/base64.js
  %x{
    var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
    var encode, decode;

    // encoder
    // [https://gist.github.com/999166] by [https://github.com/nignag]
    encode = function (input) {
      var str = String(input);
      /* eslint-disable */
      for (
        // initialize result and counter
        var block, charCode, idx = 0, map = chars, output = '';
        // if the next str index does not exist:
        //   change the mapping table to "="
        //   check if d has no fractional digits
        str.charAt(idx | 0) || (map = '=', idx % 1);
        // "8 - idx % 1 * 8" generates the sequence 2, 4, 6, 8
        output += map.charAt(63 & block >> 8 - idx % 1 * 8)
      ) {
        charCode = str.charCodeAt(idx += 3/4);
        if (charCode > 0xFF) {
          #{raise ArgumentError, 'invalid character (failed: The string to be encoded contains characters outside of the Latin1 range.)'};
        }
        block = block << 8 | charCode;
      }
      return output;
      /* eslint-enable */
    };

    // decoder
    // [https://gist.github.com/1020396] by [https://github.com/atk]
    decode = function (input) {
      var str = String(input).replace(/=+$/, '');
      if (str.length % 4 == 1) {
        #{raise ArgumentError, 'invalid base64 (failed: The string to be decoded is not correctly encoded.)'};
      }
      /* eslint-disable */
      for (
        // initialize result and counters
        var bc = 0, bs, buffer, idx = 0, output = '';
        // get next character
        buffer = str.charAt(idx++);
        // character found in table? initialize bit storage and add its ascii value;
        ~buffer && (bs = bc % 4 ? bs * 64 + buffer : buffer,
          // and if not first of each 4 characters,
          // convert the first 8 bits to one ascii character
          bc++ % 4) ? output += String.fromCharCode(255 & bs >> (-2 * bc & 6)) : 0
      ) {
        // try to find character in table (0-63, not found => -1)
        buffer = chars.indexOf(buffer);
      }
      return output;
      /* eslint-enable */
    };
  }

  def self.decode64(string)
    `decode(string.replace(/\r?\n/g, ''))`
  end

  def self.encode64(string)
    `encode(string).replace(/(.{60})/g, "$1\n").replace(/([^\n])$/g, "$1\n")`
  end

  def self.strict_decode64(string)
    `decode(string)`
  end

  def self.strict_encode64(string)
    `encode(string)`
  end

  def self.urlsafe_decode64(string)
    `decode(string.replace(/\-/g, '+').replace(/_/g, '/'))`
  end

  def self.urlsafe_encode64(string, padding: true)
    str = `encode(string).replace(/\+/g, '-').replace(/\//g, '_')`
    str = str.delete('=') unless padding
    str
  end
end
