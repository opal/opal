%x{
  function executeIOAction(action) {
    try {
      return action();
    } catch (error) {
      if (error.code === 'EACCES' ||
          error.code === 'EISDIR' ||
          error.code === 'EMFILE' ||
          error.code === 'ENOENT' ||
          error.code === 'EPERM') {
        throw Opal.IOError.$new(error.message)
      }
      throw error;
    }
  }

  var regexWhitelist = /[ -~]/;
  var regexSingleEscape = /["'\\\b\f\n\r\t]/;
  var singleEscapes = {
    '"': '\\"',
    '\'': '\\\'',
    '\\': '\\\\',
    '\b': '\\b',
    '\f': '\\f',
    '\n': '\\n',
    '\r': '\\r',
    '\t': '\\t'
    // `\v` is omitted intentionally, because in IE < 9, '\v' == 'v'.
    // '\v': '\\x0B'
  };
 
  function toASCII(buffer) {
    var array = Array.from(buffer);
    var length = array.length;
    var index = -1;
    var result = '';
    while (++index < length) {
      var character = String.fromCharCode(array[index]);
      if (regexWhitelist.test(character)) {
        result += character;
        continue;
      }
      if (regexSingleEscape.test(character)) {
        result += singleEscapes[character];
        continue;
      }
      var hexadecimal = array[index].toString(16).toUpperCase();
      var longhand = hexadecimal.length > 2;
      var escaped = '\\' + (longhand ? 'u' : 'x') + ('0000' + hexadecimal).slice(longhand ? -4 : -2);
      result += escaped;
    }
    return result;
  }
}

class IO
  @__fs__ = node_require :fs
  `var __fs__ = #{@__fs__}`

  attr_reader :eof
  attr_reader :lineno

  def initialize
    @eof = false
    @lineno = 0
  end

  def self.write(path, data)
    File.write(path, data)
  end

  def self.read(path)
    File.read(path)
  end

  def self.binread(path)
    `return executeIOAction(function(){return toASCII(__fs__.readFileSync(#{path}))})`
  end
end

STDOUT.write_proc = ->(string) { `process.stdout.write(string)` }
STDERR.write_proc = ->(string) { `process.stderr.write(string)` }

STDOUT.tty = true
STDERR.tty = true
