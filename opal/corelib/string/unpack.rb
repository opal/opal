require 'strscan'

class String
  %x{
    var directives = [
      // Integer
      'C', // supported
      'S', // supported
      'L', // supported
      'Q', // supported
      'J',

      'c', // supported
      's', // supported
      'l', // supported
      'q', // supported
      'j',

      'n', // supported
      'N', // supported
      'v', // supported
      'V', // supported

      'U', // supported
      'w',

      // Float
      'D',
      'd',
      'F',
      'f',
      'E',
      'e',
      'G',
      'g',

      // String
      'A', // supported
      'a', // supported
      'Z',
      'B',
      'b',
      'H',
      'h',
      'u', // supported
      'M',
      'm',

      'P',
      'p',

      // Misc
      '@',
      'X',
      'x',
    ];

    var modifiers = [
      '!', // ignored
      '_', // ignores
      '>', // big endian
      '<'  // little endian
    ];

    // Format Parser
    function eachDirectiveAndCount(format, callback) {
      var currentDirective,
          currentCount,
          currentModifiers,
          countSpecified;

      function reset() {
        currentDirective = null;
        currentCount = 0;
        currentModifiers = [];
        countSpecified = false;
      }

      reset();

      function yieldAndReset() {
        if (currentDirective == null) {
          reset();
          return;
        }

        var directiveSupportsModifiers = /[sSiIlLqQjJ]/.test(currentDirective);

        if (!directiveSupportsModifiers && currentModifiers.length > 0) {
          #{raise ArgumentError, "'#{`currentModifiers[0]`}' allowed only after types sSiIlLqQjJ"}
        }

        if (currentModifiers.indexOf('<') !== -1 && currentModifiers.indexOf('>') !== -1) {
          #{raise RangeError, "Can't use both '<' and '>'"}
        }

        if (!countSpecified) {
          currentCount = 1;
        }

        if (currentModifiers.indexOf('>') !== -1) {
          currentDirective = currentDirective + '>';
        }

        callback(currentDirective, currentCount);

        reset();
      }

      for (var i = 0; i < format.length; i++) {
        var currentChar = format[i];

        console.log("Got", currentChar,
          "currentDirective is", currentDirective,
          "currentCount is", currentCount,
          "currentModifiers are", currentModifiers,
          "countSpecified is", countSpecified
        )

        if (directives.indexOf(currentChar) !== -1) {
          // Directive char always resets current state
          yieldAndReset();
          currentDirective = currentChar;
        } else if (currentDirective) {
          if (/\d/.test(currentChar)) {
            // Count can be represented as a sequence of digits
            currentCount = currentCount * 10 + parseInt(currentChar, 10);
            countSpecified = true;
          } else if (currentChar === '*' && countSpecified === false) {
            // Count can be represented by a star character
            currentCount = Infinity;
            countSpecified = true;
          } else if (modifiers.indexOf(currentChar) !== -1 && countSpecified === false) {
            // Directives can be specified only after directive and before count
            currentModifiers.push(currentChar);
          } else {
            yieldAndReset();
          }
        }
      }

      yieldAndReset();
    }

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
          return chunk.reverse().reduce(function(result, byte) {
            return result * 256 + byte;
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

        return bytes.map(function(byte) {
          return String.fromCharCode(byte);
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

        console.log(bytes);

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

            console.log("Reading n =", n);

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

        result = result.slice(0, length);

        console.log(result);

        return result;
      }
    }

    function identityFunction(value) { return value; }

    var handlers = {
      'C': identityFunction,
      'S': mapChunksToWords(chunkBy(2, identityFunction)),
      'L': mapChunksToWords(chunkBy(4, identityFunction)),
      'Q': mapChunksToWords(chunkBy(8, identityFunction)),

      'S>': mapChunksToWords(invertChunks(chunkBy(2, identityFunction))),
      'L>': mapChunksToWords(invertChunks(chunkBy(4, identityFunction))),
      'Q>': mapChunksToWords(invertChunks(chunkBy(8, identityFunction))),

      'c': toNByteSigned(1, identityFunction),
      's': toNByteSigned(2, mapChunksToWords(chunkBy(2, identityFunction))),
      'l': toNByteSigned(4, mapChunksToWords(chunkBy(4, identityFunction))),
      'q': toNByteSigned(8, mapChunksToWords(chunkBy(8, identityFunction))),

      's>': toNByteSigned(2, mapChunksToWords(invertChunks(chunkBy(2, identityFunction)))),
      'l>': toNByteSigned(4, mapChunksToWords(invertChunks(chunkBy(4, identityFunction)))),
      'q>': toNByteSigned(8, mapChunksToWords(invertChunks(chunkBy(8, identityFunction)))),

      'U': identityFunction,

      'A': wrapIntoArray(joinChars(bytesToAsciiChars(filterTrailingZerosAndSpaces(identityFunction)))),
      'a': wrapIntoArray(joinChars(bytesToAsciiChars(identityFunction))),

      'u': joinChars(bytesToAsciiChars(uudecode(identityFunction))),
    };

    function readBytes(n) {
      return function(bytes) {
        var chunk = bytes.slice(0, n);
        bytes = bytes.slice(n, bytes.length);
        return { chunk: chunk, rest: bytes };
      }
    }

    function readUnicodeCharChunk(bytes) {
      console.log("readUnicodeCharChunk", bytes);

      function readByte() {
        var result = bytes[0];
        bytes = bytes.slice(1, bytes.length);
        return result;
      }

      var c = readByte(), result = '', extraLength;

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

    var readChunk = {
      'C': readBytes(1),
      'S': readBytes(2),
      'L': readBytes(4),
      'Q': readBytes(8),

      'S>': readBytes(2),
      'L>': readBytes(4),
      'Q>': readBytes(8),

      'c': readBytes(1),
      's': readBytes(2),
      'l': readBytes(4),
      'q': readBytes(8),

      's>': readBytes(2),
      'l>': readBytes(4),
      'q>': readBytes(8),

      'U': readUnicodeCharChunk,

      'A': readBytes(1),
      'a': readBytes(1),

      'u': readUuencodingChunk,
    }

    var autocompletion = {
      'C': true,
      'S': true,
      'L': true,
      'Q': true,

      'S>': true,
      'L>': true,
      'Q>': true,

      'c': true,
      's': true,
      'l': true,
      'q': true,

      's>': true,
      'l>': true,
      'q>': true,

      'U': false,

      'A': false,
      'a': false,

      'u': false,
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
    p [self, format]

    %x{
      var output = [];

      var buffer = utf16LEToBytes(self);
      console.log('buffer = ', buffer);

      function autocomplete(array, size) {
        while (array.length < size) {
          array.push(nil);
        }

        return array;
      }

      function processChunk(directive, count) {
        console.log("Cuting", directive, count, 'from', buffer);

        var chunk = [],
            chunkReader = readChunk[directive];

        if (chunkReader == null) {
          #{raise "Unsupported unpack directive #{`directive`.inspect} (no chunk reader defined)"}
        }

        if (count === Infinity) {
          while (buffer.length > 0) {
            var chunkData = chunkReader(buffer);
            console.log('Sub-chunk data', chunkData);
            buffer = chunkData.rest;
            chunk = chunk.concat(chunkData.chunk);
          }
        } else {
          for (var i = 0; i < count; i++) {
            var chunkData = chunkReader(buffer);
            console.log('Sub-chunk data', chunkData);
            buffer = chunkData.rest;
            chunk = chunk.concat(chunkData.chunk);
          }
        }

        console.log('Processing chunk', chunk);

        var handler = handlers[directive];

        if (handler == null) {
          #{raise "Unsupported unpack directive #{`directive`.inspect} (no handler defined)"}
        }

        return handler(chunk);
      }

      // console.log("parsing", format);

      eachDirectiveAndCount(format, function(directive, count) {
        console.log(directive, '->', count);

        var part = processChunk(directive, count);
        console.log("part = ", part, typeof(part));

        if (count !== Infinity && autocompletion[directive]) {
          autocomplete(part, count);
        }

        output = output.concat(part);
      });

      return output;
    }
  end
end
