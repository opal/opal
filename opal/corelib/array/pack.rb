# helpers: coerce_to
# backtick_javascript: true

require 'corelib/pack_unpack/format_string_parser'

class ::Array
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
          return $coerce_to(item, #{::Integer}, 'to_int')
        });
      }
    }

    function ToStr(callback) {
      return function(data) {
        var buffer = callback(data);

        return buffer.map(function(item) {
          return $coerce_to(item, #{::String}, 'to_str')
        });
      }
    }

    function toFloat(callback) {
      return function(data) {
        var buffer = callback(data);

        return buffer.map(function(item) {
          if (!Opal.is_a(item, Opal.Numeric)) {
            #{::Kernel.raise ::TypeError, "can't convert Object into Float"};
          }
          return $coerce_to(item, #{::Float}, 'to_f');
        });
      }
    }

    var hostLittleEndian = (function() {
      var uint32 = new Uint32Array([0x11223344]);
      return new Uint8Array(uint32.buffer)[0] === 0x44;
    })();

    function asciiStringFromFloat(bytes, little, callback) {
      return function(data) {
        var buffer = callback(data);

        return buffer.map(function(item) {
          var arr = new ArrayBuffer(bytes);
          var view = new DataView(arr);
          if (bytes === 4) {
            view.setFloat32(0, item, little);
          } else {
            view.setFloat64(0, item, little);
          }
          var uint8 = new Uint8Array(arr);
          return asciiBytesToUtf16LEString(Array.from(uint8));
        });
      }
    }

    function fromCodePoint(callback) {
      return function(data) {
        var buffer = callback(data);
        return buffer.map(function(item) {
          try {
            return String.fromCodePoint(item);
          } catch (error) {
            if (error instanceof RangeError) {
              #{::Kernel.raise ::RangeError, 'value out of range'};
            }
            throw error;
          }
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

      'U': joinChars(fromCodePoint(toInt(identityFunction))),
      'w': null,

      'x': function(chunk) {
        return asciiBytesToUtf16LEString(chunk);
      },

      // Float
      'D': joinChars(asciiStringFromFloat(8, hostLittleEndian, toFloat(identityFunction))),
      'd': joinChars(asciiStringFromFloat(8, hostLittleEndian, toFloat(identityFunction))),
      'F': joinChars(asciiStringFromFloat(4, hostLittleEndian, toFloat(identityFunction))),
      'f': joinChars(asciiStringFromFloat(4, hostLittleEndian, toFloat(identityFunction))),
      'E': joinChars(asciiStringFromFloat(8, true, toFloat(identityFunction))),
      'e': joinChars(asciiStringFromFloat(4, true, toFloat(identityFunction))),
      'G': joinChars(asciiStringFromFloat(8, false, toFloat(identityFunction))),
      'g': joinChars(asciiStringFromFloat(4, false, toFloat(identityFunction))),

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
      'p': null
    };

    function readNTimesFromBufferAndMerge(callback) {
      return function(buffer, count) {
        var chunk = [], chunkData;

        if (count === Infinity) {
          while (buffer.length > 0) {
            chunkData = callback(buffer);
            buffer = chunkData.rest;
            chunk = chunk.concat(chunkData.chunk);
          }
        } else {
          if (buffer.length < count) {
            #{::Kernel.raise ::ArgumentError, 'too few arguments'};
          }
          for (var i = 0; i < count; i++) {
            chunkData = callback(buffer);
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
          #{::Kernel.raise ::ArgumentError, 'too few arguments'};
        } else {
          source = $coerce_to(source, #{::String}, 'to_str');
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

      'U': readNTimesFromBufferAndMerge(readItem),
      'w': null,
      'x': function(buffer, count) {
        if (count === Infinity) count = 1;
        return { chunk: new Array(count).fill(0), rest: buffer };
      },

      // Float
      'D': readNTimesFromBufferAndMerge(readItem),
      'd': readNTimesFromBufferAndMerge(readItem),
      'F': readNTimesFromBufferAndMerge(readItem),
      'f': readNTimesFromBufferAndMerge(readItem),
      'E': readNTimesFromBufferAndMerge(readItem),
      'e': readNTimesFromBufferAndMerge(readItem),
      'G': readNTimesFromBufferAndMerge(readItem),
      'g': readNTimesFromBufferAndMerge(readItem),

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
      'p': null
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

      'U': false,
      'w': null,
      'x': false,

      // Float
      'D': false,
      'd': false,
      'F': false,
      'f': false,
      'E': false,
      'e': false,
      'G': false,
      'g': false,

      // String
      'A': false,
      'a': false,
      'Z': null,
      'B': null,
      'b': null,
      'H': null,
      'h': null,
      'u': false,
      'M': null,
      'm': null,

      'P': null,
      'p': null
    };
  }

  def pack(format)
    format = ::Opal.coerce_to!(format, ::String, :to_str)
                   .gsub(/#.*/, '')
                   .gsub(/\s/, '')
                   .delete("\000")

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
          #{::Kernel.raise "Unsupported pack directive #{`directive`.inspect} (no chunk reader defined)"}
        }

        var chunkData = chunkReader(buffer, count);
        chunk = chunkData.chunk;
        buffer = chunkData.rest;

        var handler = handlers[directive];

        if (handler == null) {
          #{::Kernel.raise "Unsupported pack directive #{`directive`.inspect} (no handler defined)"}
        }

        return handler(chunk);
      }

      eachDirectiveAndCount(format, function(directive, count) {
        var part = processChunk(directive, count);

        if (count !== Infinity) {
          var shouldAutocomplete = autocompletion[directive]

          if (shouldAutocomplete == null) {
            #{::Kernel.raise "Unsupported pack directive #{`directive`.inspect} (no autocompletion rule defined)"}
          }

          if (shouldAutocomplete) {
            autocomplete(part, count);
          }
        }

        output = output.concat(part);
      });

      if (format.match(/^(U\*?)+$/)) {
        return output;
      }
      else {
        return Opal.str(output, "binary");
      }
    }
  end
end
