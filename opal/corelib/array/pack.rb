require 'corelib/pack_unpack/format_string_parser'

class Array
  %x{
    // Format Parser
    var eachDirectiveAndCount = Opal.PackUnpack.eachDirectiveAndCount;

    function identityFunction(value) { return value; }

    function utf8BytesToUtf16LEString(bytes) {
      var str = String.fromCharCode.apply(null, bytes), out = "", i = 0, len = str.length, c, char2, char3;
      while (i < len) {
        c = str.charCodeAt(i++);
        switch (c >> 4) {
          case 0:
          case 1:
          case 2:
          case 3:
          case 4:
          case 5:
          case 6:
          case 7:
            // 0xxxxxxx
            out += str.charAt(i - 1);
            break;
          case 12:
          case 13:
            // 110x xxxx 10xx xxxx
            char2 = str.charCodeAt(i++);
            out += String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F));
            break;
          case 14:
            // 1110 xxxx10xx xxxx10xx xxxx
            char2 = str.charCodeAt(i++);
            char3 = str.charCodeAt(i++);
            out += String.fromCharCode(((c & 0x0F) << 12) | ((char2 & 0x3F) << 6) | ((char3 & 0x3F) << 0));
            break;
        }
      }
      return out;
    }

    function asciiBytesToUtf16LEString(bytes) {
      return String.fromCharCode.apply(null, bytes);
    }

    function asciiStringFromUnsignedInt(bytes, callback) {
      return function(data) {
        var buffer = callback(data);

        return buffer.map(function(item) {
          var result = [];

          for (var i = 0; i < bytes; i++) {
            var bit = item & 255;
            result.push(bit);
            item = item >> 8;
          };

          return asciiBytesToUtf16LEString(result);
        });
      }
    }

    function asciiStringFromSignedInt(bytes, callback) {
      return function(data) {
        var buffer = callback(data),
            bits = bytes * 8,
            limit = Math.pow(2, bits);

        return buffer.map(function(item) {
          if (item < 0) {
            item += limit;
          }

          var result = [];

          for (var i = 0; i < bytes; i++) {
            var bit = item & 255;
            result.push(bit);
            item = item >> 8;
          };

          return asciiBytesToUtf16LEString(result);
        });
      }
    }

    function toInt(callback) {
      return function(data) {
        var buffer = callback(data);

        return buffer.map(function(item) {
          return #{Opal.coerce_to `item`, Integer, :to_int}
        });
      }
    }

    function ToStr(callback) {
      return function(data) {
        var buffer = callback(data);

        return buffer.map(function(item) {
          return #{Opal.coerce_to `item`, String, :to_str}
        });
      }
    }

    function joinChars(callback) {
      return function(data) {
        var buffer = callback(data);
        return buffer.join('');
      }
    }

    var handlers = {
      // Integer
      'C': joinChars(asciiStringFromUnsignedInt(1, toInt(identityFunction))),
      'S': joinChars(asciiStringFromUnsignedInt(2, toInt(identityFunction))),
      'L': joinChars(asciiStringFromUnsignedInt(4, toInt(identityFunction))),
      'Q': joinChars(asciiStringFromUnsignedInt(8, toInt(identityFunction))),
      'J': null,

      'S>': null,
      'L>': null,
      'Q>': null,

      'c': joinChars(asciiStringFromSignedInt(1, toInt(identityFunction))),
      's': joinChars(asciiStringFromSignedInt(2, toInt(identityFunction))),
      'l': joinChars(asciiStringFromSignedInt(4, toInt(identityFunction))),
      'q': joinChars(asciiStringFromSignedInt(8, toInt(identityFunction))),
      'j': null,

      's>': null,
      'l>': null,
      'q>': null,

      'n': null,
      'N': null,
      'v': null,
      'V': null,

      'U': null,
      'w': null,

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
      'A': joinChars(identityFunction),
      'a': joinChars(identityFunction),
      'Z': null,
      'B': null,
      'b': null,
      'H': null,
      'h': null,
      'u': null,
      'M': null,
      'm': null,

      'P': null,
      'p': null,
    };

    function readNTimesFromBufferAndMerge(callback) {
      return function(buffer, count) {
        var chunk = [];

        if (count === Infinity) {
          while (buffer.length > 0) {
            var chunkData = callback(buffer);
            buffer = chunkData.rest;
            chunk = chunk.concat(chunkData.chunk);
          }
        } else {
          if (buffer.length < count) {
            #{raise ArgumentError, 'too few arguments'};
          }
          for (var i = 0; i < count; i++) {
            var chunkData = callback(buffer);
            buffer = chunkData.rest;
            chunk = chunk.concat(chunkData.chunk);
          }
        }

        return { chunk: chunk, rest: buffer };
      }
    }

    function readItem(buffer) {
      var chunk = buffer.slice(0, 1);
      buffer = buffer.slice(1, buffer.length);
      return { chunk: chunk, rest: buffer };
    }

    function readNCharsFromTheFirstItemAndMergeWithFallback(fallback, callback) {
      return function(buffer, count) {
        var chunk = [], source = buffer[0];

        if (source === nil) {
          source = '';
        } else if (source === undefined) {
          #{raise ArgumentError, 'too few arguments'};
        } else {
          source = #{Opal.coerce_to `source`, String, :to_str};
        }

        buffer = buffer.slice(1, buffer.length);

        function infiniteReeder() {
          var chunkData = callback(source);
          source = chunkData.rest;
          var subChunk = chunkData.chunk;

          if (subChunk.length === 1 && subChunk[0] === nil) {
            subChunk = []
          }

          chunk = chunk.concat(subChunk);
        }

        function finiteReeder() {
          var chunkData = callback(source);
          source = chunkData.rest;
          var subChunk = chunkData.chunk;

          if (subChunk.length === 0) {
            subChunk = [fallback];
          }

          if (subChunk.length === 1 && subChunk[0] === nil) {
            subChunk = [fallback];
          }

          chunk = chunk.concat(subChunk);
        }

        if (count === Infinity) {
          while (source.length > 0) {
            infiniteReeder();
          }
        } else {
          for (var i = 0; i < count; i++) {
            finiteReeder();
          }
        }

        return { chunk: chunk, rest: buffer };
      }
    }

    var readChunk = {
      // Integer
      'C': readNTimesFromBufferAndMerge(readItem),
      'S': readNTimesFromBufferAndMerge(readItem),
      'L': readNTimesFromBufferAndMerge(readItem),
      'Q': readNTimesFromBufferAndMerge(readItem),
      'J': null,

      'S>': null,
      'L>': null,
      'Q>': null,

      'c': readNTimesFromBufferAndMerge(readItem),
      's': readNTimesFromBufferAndMerge(readItem),
      'l': readNTimesFromBufferAndMerge(readItem),
      'q': readNTimesFromBufferAndMerge(readItem),
      'j': null,

      's>': null,
      'l>': null,
      'q>': null,

      'n': null,
      'N': null,
      'v': null,
      'V': null,

      'U': null,
      'w': null,

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
      'A': readNCharsFromTheFirstItemAndMergeWithFallback(" ", readItem),
      'a': readNCharsFromTheFirstItemAndMergeWithFallback("\x00", readItem),
      'Z': null,
      'B': null,
      'b': null,
      'H': null,
      'h': null,
      'u': null,
      'M': null,
      'm': null,

      'P': null,
      'p': null,
    };

    var autocompletion = {
      // Integer
      'C': false,
      'S': false,
      'L': false,
      'Q': false,
      'J': null,

      'S>': null,
      'L>': null,
      'Q>': null,

      'c': false,
      's': false,
      'l': false,
      'q': false,
      'j': null,

      's>': null,
      'l>': null,
      'q>': null,

      'n': null,
      'N': null,
      'v': null,
      'V': null,

      'U': null,
      'w': null,

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
      'Z': null,
      'B': null,
      'b': null,
      'H': null,
      'h': null,
      'u': null,
      'M': null,
      'm': null,

      'P': null,
      'p': null,
    };
  }

  def pack(format)
    format = Opal.coerce_to!(format, String, :to_str).gsub(/\s/, '').gsub("\000", '')

    %x{
      var output = '';

      var buffer = self.slice();

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
          #{raise "Unsupported pack directive #{`directive`.inspect} (no chunk reader defined)"}
        }

        var chunkData = chunkReader(buffer, count);
        chunk = chunkData.chunk;
        buffer = chunkData.rest;

        var handler = handlers[directive];

        if (handler == null) {
          #{raise "Unsupported pack directive #{`directive`.inspect} (no handler defined)"}
        }

        return handler(chunk);
      }

      eachDirectiveAndCount(format, function(directive, count) {
        var part = processChunk(directive, count);

        if (count !== Infinity) {
          var shouldAutocomplete = autocompletion[directive]

          if (shouldAutocomplete == null) {
            #{raise "Unsupported pack directive #{`directive`.inspect} (no autocompletion rule defined)"}
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
end
