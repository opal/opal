require 'corelib/pack_unpack/format_string_parser'

class String
  %x{
    // Format Parser
    var eachDirectiveAndCount = Opal.PackUnpack.eachDirectiveAndCount;

    function flattenArray(callback) {
      return function(data) {
        var array = callback(data);
        return #{`array`.flatten};
      }
    }

    function mapChunksToWords(callback) {
      return function(data) {
        var chunks = callback(data);

        return chunks.map(function(chunk) {
          return chunk.reverse().reduce(function(result, singleByte) {
            return result * 256 + singleByte;
          }, 0);
        });
      }
    }

    function chunkBy(chunkSize, callback) {
      return function(data) {
        var array = callback(data),
            chunks = [],
            chunksCount = (array.length / chunkSize);

        for (var i = 0; i < chunksCount; i++) {
          var chunk = array.splice(0, chunkSize);
          if (chunk.length === chunkSize) {
            chunks.push(chunk);
          }
        }

        return chunks;
      }
    }

    function utf16LEToBytes(string) {
      var utf8 = [];
      for (var i=0; i < string.length; i++) {
        var charcode = string.charCodeAt(i);
        if (charcode < 0x100) utf8.push(charcode);
        else if (charcode < 0x800) {
          utf8.push(0xc0 | (charcode >> 6),
                    0x80 | (charcode & 0x3f));
        }
        else if (charcode < 0xd800 || charcode >= 0xe000) {
          utf8.push(0xe0 | (charcode >> 12),
                    0x80 | ((charcode>>6) & 0x3f),
                    0x80 | (charcode & 0x3f));
        }
        // surrogate pair
        else {
          i++;
          // UTF-16 encodes 0x10000-0x10FFFF by
          // subtracting 0x10000 and splitting the
          // 20 bits of 0x0-0xFFFFF into two halves
          charcode = 0x10000 + (((charcode & 0x3ff)<<10)
                    | (string.charCodeAt(i) & 0x3ff))
          utf8.push(0xf0 | (charcode >>18),
                    0x80 | ((charcode>>12) & 0x3f),
                    0x80 | ((charcode>>6) & 0x3f),
                    0x80 | (charcode & 0x3f));
        }
      }

      return utf8;
    }

    function toNByteSigned(bytesCount, callback) {
      return function(data) {
        var unsignedBits = callback(data),
            bitsCount = bytesCount * 8,
            limit = Math.pow(2, bitsCount);

        return unsignedBits.map(function(n) {
          if (n >= limit / 2) {
            n -= limit;
          }

          return n;
        });
      }
    }

    function bytesToAsciiChars(callback) {
      return function(data) {
        var bytes = callback(data);

        return bytes.map(function(singleByte) {
          return String.fromCharCode(singleByte);
        });
      }
    }

    function joinChars(callback) {
      return function(data) {
        var chars = callback(data);
        return chars.join('');
      }
    }

    function wrapIntoArray(callback) {
      return function(data) {
        var object = callback(data);
        return [object];
      }
    }

    function filterTrailingChars(chars) {
      var charCodesToFilter = chars.map(function(s) { return s.charCodeAt(0); });

      return function(callback) {
        return function(data) {
          var charCodes = callback(data);

          while (charCodesToFilter.indexOf(charCodes[charCodes.length - 1]) !== -1) {
            charCodes = charCodes.slice(0, charCodes.length - 1);
          }

          return charCodes;
        }
      }
    }

    var filterTrailingZerosAndSpaces = filterTrailingChars(["\u0000", " "]);

    function invertChunks(callback) {
      return function(data) {
        var chunks = callback(data);

        return chunks.map(function(chunk) {
          return chunk.reverse();
        });
      }
    }

    function uudecode(callback) {
      return function(data) {
        var bytes = callback(data);

        var stop = false;
        var i = 0, length = 0;

        var result = [];

        do {
          if (i < bytes.length) {
            var n = bytes[i] - 32 & 0x3F;

            ++i;

            if (bytes[i] === 10) {
              continue;
            }

            if (n > 45) {
              return '';
            }

            length += n;

            while (n > 0) {
              var c1 = bytes[i];
              var c2 = bytes[i + 1];
              var c3 = bytes[i + 2];
              var c4 = bytes[i + 3];

              var b1 = (c1 - 32 & 0x3F) << 2 | (c2 - 32 & 0x3F) >> 4;
              var b2 = (c2 - 32 & 0x3F) << 4 | (c3 - 32 & 0x3F) >> 2;
              var b3 = (c3 - 32 & 0x3F) << 6 | c4 - 32 & 0x3F;

              result.push(b1 & 0xFF);
              result.push(b2 & 0xFF);
              result.push(b3 & 0xFF);

              i += 4;
              n -= 3;
            }

            ++i;
          } else {
            break;
          }
        } while (true);

        return result.slice(0, length);
      }
    }

    function toBits(callback) {
      return function(data) {
        var bytes = callback(data);

        var bits = bytes.map(function(singleByte) {
          return singleByte.toString(2);
        });

        return bits;
      }
    }

    function decodeBERCompressedIntegers(callback) {
      return function(data) {
        var bytes = callback(data), result = [], buffer = '';

        for (var i = 0; i < bytes.length; i++) {
          var singleByte = bytes[i],
              bits = singleByte.toString(2);

          bits = Array(8 - bits.length + 1).join('0').concat(bits);

          var firstBit = bits[0];
          bits = bits.slice(1, bits.length);

          buffer = buffer.concat(bits);

          if (firstBit === '0') {
            var decoded = parseInt(buffer, 2);
            result.push(decoded);
            buffer = ''
          }
        }

        return result;
      }
    }

    function base64Decode(callback) {
      return function(data) {
        var string = callback(data);
        if (typeof(atob) === 'function') {
          // Browser
          return atob(string);
        } else if (typeof(Buffer) === 'function') {
          // Node
          if (typeof(Buffer.from) === 'function') {
            // Node 5.10+
            return Buffer.from(string, 'base64').toString();
          } else {
            return new Buffer(string, 'base64').toString();
          }
        } else if (#{defined?(Base64)}) {
          return #{Base64.decode64(`string`)};
        } else {
          #{raise "To use String#unpack('m'), you must first require 'base64'."}
        }
      }
    }

    // quoted-printable decode
    function qpdecode(callback) {
      return function(data) {
        var string = callback(data);

        return string
          .replace(/[\t\x20]$/gm, '')
          .replace(/=(?:\r\n?|\n|$)/g, '')
          .replace(/=([a-fA-F0-9]{2})/g, function($0, $1) {
            var codePoint = parseInt($1, 16);
            return String.fromCharCode(codePoint);
          });
      }
    }

    function identityFunction(value) { return value; }

    var handlers = {
      // Integer
      'C': identityFunction,
      'S': mapChunksToWords(chunkBy(2, identityFunction)),
      'L': mapChunksToWords(chunkBy(4, identityFunction)),
      'Q': mapChunksToWords(chunkBy(8, identityFunction)),
      'J': null,

      'S>': mapChunksToWords(invertChunks(chunkBy(2, identityFunction))),
      'L>': mapChunksToWords(invertChunks(chunkBy(4, identityFunction))),
      'Q>': mapChunksToWords(invertChunks(chunkBy(8, identityFunction))),

      'c': toNByteSigned(1, identityFunction),
      's': toNByteSigned(2, mapChunksToWords(chunkBy(2, identityFunction))),
      'l': toNByteSigned(4, mapChunksToWords(chunkBy(4, identityFunction))),
      'q': toNByteSigned(8, mapChunksToWords(chunkBy(8, identityFunction))),
      'j': null,

      's>': toNByteSigned(2, mapChunksToWords(invertChunks(chunkBy(2, identityFunction)))),
      'l>': toNByteSigned(4, mapChunksToWords(invertChunks(chunkBy(4, identityFunction)))),
      'q>': toNByteSigned(8, mapChunksToWords(invertChunks(chunkBy(8, identityFunction)))),

      'n': null, // aliased later
      'N': null, // aliased later
      'v': null, // aliased later
      'V': null, // aliased later

      'U': identityFunction,
      'w': decodeBERCompressedIntegers(identityFunction),

      // Float
      'D': null,
      'd': null,
      'F': null,
      'f': null,
      'E': null,
      'e': null,
      'G': null,
      'g': null,

      // String
      'A': wrapIntoArray(joinChars(bytesToAsciiChars(filterTrailingZerosAndSpaces(identityFunction)))),
      'a': wrapIntoArray(joinChars(bytesToAsciiChars(identityFunction))),
      'Z': joinChars(bytesToAsciiChars(identityFunction)),
      'B': joinChars(identityFunction),
      'b': joinChars(identityFunction),
      'H': joinChars(identityFunction),
      'h': joinChars(identityFunction),
      'u': joinChars(bytesToAsciiChars(uudecode(identityFunction))),
      'M': qpdecode(joinChars(bytesToAsciiChars(identityFunction))),
      'm': base64Decode(joinChars(bytesToAsciiChars(identityFunction))),

      'P': null,
      'p': null
    };

    function readBytes(n) {
      return function(bytes) {
        var chunk = bytes.slice(0, n);
        bytes = bytes.slice(n, bytes.length);
        return { chunk: chunk, rest: bytes };
      }
    }

    function readUnicodeCharChunk(bytes) {
      function readByte() {
        var result = bytes[0];
        bytes = bytes.slice(1, bytes.length);
        return result;
      }

      var c = readByte(), extraLength;

      if (c >> 7 == 0) {
        // 0xxx xxxx
        return { chunk: [c], rest: bytes };
      }

      if (c >> 6 == 0x02) {
        #{raise ArgumentError, 'malformed UTF-8 character'}
      }

      if (c >> 5 == 0x06) {
        // 110x xxxx (two bytes)
        extraLength = 1;
      } else if (c >> 4 == 0x0e) {
        // 1110 xxxx (three bytes)
        extraLength = 2;
      } else if (c >> 3 == 0x1e) {
        // 1111 0xxx (four bytes)
        extraLength = 3;
      } else if (c >> 2 == 0x3e) {
        // 1111 10xx (five bytes)
        extraLength = 4;
      } else if (c >> 1 == 0x7e) {
        // 1111 110x (six bytes)
        extraLength = 5;
      } else {
        #{raise 'malformed UTF-8 character'}
      }

      if (extraLength > bytes.length) {
        #{
          expected = `extraLength + 1`;
          given = `bytes.length + 1`;
          raise ArgumentError, "malformed UTF-8 character (expected #{expected} bytes, given #{given} bytes)"
        }
      }

      // Remove the UTF-8 prefix from the char
      var mask = (1 << (8 - extraLength - 1)) - 1,
          result = c & mask;

      for (var i = 0; i < extraLength; i++) {
        c = readByte();

        if (c >> 6 != 0x02) {
          #{raise 'Invalid multibyte sequence'}
        }

        result = (result << 6) | (c & 0x3f);
      }

      if (result <= 0xffff) {
        return { chunk: [result], rest: bytes };
      } else {
        result -= 0x10000;
        var high = ((result >> 10) & 0x3ff) + 0xd800,
            low = (result & 0x3ff) + 0xdc00;
        return { chunk: [high, low], rest: bytes };
      }
    }

    function readUuencodingChunk(buffer) {
      var length = buffer.indexOf(32); // 32 = space

      if (length === -1) {
        return { chunk: buffer, rest: [] };
      } else {
        return { chunk: buffer.slice(0, length), rest: buffer.slice(length, buffer.length) };
      }
    }

    function readNBitsLSBFirst(buffer, count) {
      var result = '';

      while (count > 0 && buffer.length > 0) {
        var singleByte = buffer[0],
            bitsToTake = Math.min(count, 8),
            bytesToTake = Math.ceil(bitsToTake / 8);

        buffer = buffer.slice(1, buffer.length);

        if (singleByte != null) {
          var bits = singleByte.toString(2);
          bits = Array(8 - bits.length + 1).join('0').concat(bits).split('').reverse().join('');

          for (var j = 0; j < bitsToTake; j++) {
            result += bits[j] || '0';
            count--;
          }
        }
      }

      return { chunk: [result], rest: buffer };
    }

    function readNBitsMSBFirst(buffer, count) {
      var result = '';

      while (count > 0 && buffer.length > 0) {
        var singleByte = buffer[0],
            bitsToTake = Math.min(count, 8),
            bytesToTake = Math.ceil(bitsToTake / 8);

        buffer = buffer.slice(1, buffer.length);

        if (singleByte != null) {
          var bits = singleByte.toString(2);
          bits = Array(8 - bits.length + 1).join('0').concat(bits);

          for (var j = 0; j < bitsToTake; j++) {
            result += bits[j] || '0';
            count--;
          }
        }
      }

      return { chunk: [result], rest: buffer };
    }

    function readWhileFirstBitIsOne(buffer) {
      var result = [];

      for (var i = 0; i < buffer.length; i++) {
        var singleByte = buffer[i];

        result.push(singleByte);

        if ((singleByte & 128) === 0) {
          break;
        }
      }

      return { chunk: result, rest: buffer.slice(result.length, buffer.length) };
    }

    function readTillNullCharacter(buffer, count) {
      var result = [];

      for (var i = 0; i < count && i < buffer.length; i++) {
        var singleByte = buffer[i];

        if (singleByte === 0) {
          break;
        } else {
          result.push(singleByte);
        }
      }

      if (count === Infinity) {
        count = result.length;
      }

      if (buffer[count] === 0) {
        count++;
      }

      buffer = buffer.slice(count, buffer.length);

      return { chunk: result, rest: buffer };
    }

    function readHexCharsHighNibbleFirst(buffer, count) {
      var result = [];

      while (count > 0 && buffer.length > 0) {
        var singleByte = buffer[0],
            hex = singleByte.toString(16);

        buffer = buffer.slice(1, buffer.length);
        hex = Array(2 - hex.length + 1).join('0').concat(hex);

        if (count === 1) {
          result.push(hex[0]);
          count--;
        } else {
          result.push(hex[0], hex[1]);
          count -= 2;
        }
      }

      return { chunk: result, rest: buffer };
    }

    function readHexCharsLowNibbleFirst(buffer, count) {
      var result = [];

      while (count > 0 && buffer.length > 0) {
        var singleByte = buffer[0],
            hex = singleByte.toString(16);

        buffer = buffer.slice(1, buffer.length);
        hex = Array(2 - hex.length + 1).join('0').concat(hex);

        if (count === 1) {
          result.push(hex[1]);
          count--;
        } else {
          result.push(hex[1], hex[0]);
          count -= 2;
        }
      }

      return { chunk: result, rest: buffer };
    }

    function readNTimesAndMerge(callback) {
      return function(buffer, count) {
        var chunk = [], chunkData;

        if (count === Infinity) {
          while (buffer.length > 0) {
            chunkData = callback(buffer);
            buffer = chunkData.rest;
            chunk = chunk.concat(chunkData.chunk);
          }
        } else {
          for (var i = 0; i < count; i++) {
            chunkData = callback(buffer);
            buffer = chunkData.rest;
            chunk = chunk.concat(chunkData.chunk);
          }
        }

        return { chunk: chunk, rest: buffer };
      }
    }

    function readAll(buffer, count) {
      return { chunk: buffer, rest: [] };
    }

    var readChunk = {
      // Integer
      'C': readNTimesAndMerge(readBytes(1)),
      'S': readNTimesAndMerge(readBytes(2)),
      'L': readNTimesAndMerge(readBytes(4)),
      'Q': readNTimesAndMerge(readBytes(8)),
      'J': null,

      'S>': readNTimesAndMerge(readBytes(2)),
      'L>': readNTimesAndMerge(readBytes(4)),
      'Q>': readNTimesAndMerge(readBytes(8)),

      'c': readNTimesAndMerge(readBytes(1)),
      's': readNTimesAndMerge(readBytes(2)),
      'l': readNTimesAndMerge(readBytes(4)),
      'q': readNTimesAndMerge(readBytes(8)),
      'j': null,

      's>': readNTimesAndMerge(readBytes(2)),
      'l>': readNTimesAndMerge(readBytes(4)),
      'q>': readNTimesAndMerge(readBytes(8)),

      'n': null, // aliased later
      'N': null, // aliased later
      'v': null, // aliased later
      'V': null, // aliased later

      'U': readNTimesAndMerge(readUnicodeCharChunk),
      'w': readNTimesAndMerge(readWhileFirstBitIsOne),

      // Float
      'D': null,
      'd': null,
      'F': null,
      'f': null,
      'E': null,
      'e': null,
      'G': null,
      'g': null,

      // String
      'A': readNTimesAndMerge(readBytes(1)),
      'a': readNTimesAndMerge(readBytes(1)),
      'Z': readTillNullCharacter,
      'B': readNBitsMSBFirst,
      'b': readNBitsLSBFirst,
      'H': readHexCharsHighNibbleFirst,
      'h': readHexCharsLowNibbleFirst,
      'u': readNTimesAndMerge(readUuencodingChunk),
      'M': readAll,
      'm': readAll,

      'P': null,
      'p': null
    }

    var autocompletion = {
      // Integer
      'C': true,
      'S': true,
      'L': true,
      'Q': true,
      'J': null,

      'S>': true,
      'L>': true,
      'Q>': true,

      'c': true,
      's': true,
      'l': true,
      'q': true,
      'j': null,

      's>': true,
      'l>': true,
      'q>': true,

      'n': null, // aliased later
      'N': null, // aliased later
      'v': null, // aliased later
      'V': null, // aliased later

      'U': false,
      'w': false,

      // Float
      'D': null,
      'd': null,
      'F': null,
      'f': null,
      'E': null,
      'e': null,
      'G': null,
      'g': null,

      // String
      'A': false,
      'a': false,
      'Z': false,
      'B': false,
      'b': false,
      'H': false,
      'h': false,
      'u': false,
      'M': false,
      'm': false,

      'P': null,
      'p': null
    }

    function alias(existingDirective, newDirective) {
      readChunk[newDirective] = readChunk[existingDirective];
      handlers[newDirective] = handlers[existingDirective];
      autocompletion[newDirective] = autocompletion[existingDirective];
    }

    alias('S>', 'n');
    alias('L>', 'N');

    alias('S', 'v');
    alias('L', 'V');
  }

  def unpack(format)
    format = Opal.coerce_to!(format, String, :to_str).gsub(/\s/, '').gsub("\000", '')

    %x{
      var output = [];

      var buffer = utf16LEToBytes(self);

      function autocomplete(array, size) {
        while (array.length < size) {
          array.push(nil);
        }

        return array;
      }

      function processChunk(directive, count) {
        var chunk,
            chunkReader = readChunk[directive];

        if (chunkReader == null) {
          #{raise "Unsupported unpack directive #{`directive`.inspect} (no chunk reader defined)"}
        }

        var chunkData = chunkReader(buffer, count);
        chunk = chunkData.chunk;
        buffer = chunkData.rest;

        var handler = handlers[directive];

        if (handler == null) {
          #{raise "Unsupported unpack directive #{`directive`.inspect} (no handler defined)"}
        }

        return handler(chunk);
      }

      eachDirectiveAndCount(format, function(directive, count) {
        var part = processChunk(directive, count);

        if (count !== Infinity) {
          var shouldAutocomplete = autocompletion[directive]

          if (shouldAutocomplete == null) {
            #{raise "Unsupported unpack directive #{`directive`.inspect} (no autocompletion rule defined)"}
          }

          if (shouldAutocomplete) {
            autocomplete(part, count);
          }
        }

        output = output.concat(part);
      });

      return output;
    }
  end

  def unpack1(format)
    format = Opal.coerce_to!(format, String, :to_str).gsub(/\s/, '').gsub("\000", '')

    unpack(format[0])[0]
  end
end
