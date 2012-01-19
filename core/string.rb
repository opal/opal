class String
  def self.new(str = '')
    str.to_s
  end

  def <(other)
    `this < other`
  end

  def <=(other)
    `this <= other`
  end

  def >(other)
    `this > other`
  end

  def >=(other)
    `this >= other`
  end

  def +(other)
    `this + other`
  end

  def [](index, length)
    `this.substr(index, length)`
  end

  def ==(other)
    `this.valueOf() === other.valueOf()`
  end

  def =~(other)
    %x{
      if (typeof other === 'string') {
        throw RubyTypeError.$new('string given');
      }

      return #{other =~ self};
    }
  end

  def <=>(other)
    %x{
      if (typeof other !== 'string') {
        return nil;
      }

      return this > other ? 1 : (this < other ? -1 : 0);
    }
  end

  def capitalize
    `this.charAt(0).toUpperCase() + this.substr(1).toLowerCase()`
  end

  def casecmp(other)
    %x{
      if (typeof other !== 'string') {
        return other;
      }

      var a = this.toLowerCase(),
          b = other.toLowerCase();

      return a > b ? 1 : (a < b ? -1 : 0);
    }
  end

  def downcase
    `this.toLowerCase()`
  end

  def end_with?(suffix)
    `this.lastIndexOf(suffix) === this.length - suffix.length`
  end

  def empty?
    `this.length === 0`
  end

  def gsub(pattern, replace = undefined, &block)
    %x{
      var re = pattern.toString();
          re = re.substr(1, re.lastIndexOf('/') - 1);
          re = new RegExp(re, 'g');

      return #{sub re, replace, &block};
    }
  end

  def hash
    `this.toString()`
  end

  def include?(other)
    `this.indexOf(other) !== -1`
  end

  def index(substr)
    %x{
      var result = this.indexOf(substr);
      return result === -1 ? nil : result
    }
  end

  def inspect
    %x{
      var escapable = /[\\\\\\"\\x00-\\x1f\\x7f-\\x9f\\u00ad\\u0600-\\u0604\\u070f\\u17b4\\u17b5\\u200c-\\u200f\\u2028-\\u202f\\u2060-\\u206f\\ufeff\\ufff0-\\uffff]/g,
          meta      = {
            '\\b': '\\\\b',
            '\\t': '\\\\t',
            '\\n': '\\\\n',
            '\\f': '\\\\f',
            '\\r': '\\\\r',
            '"' : '\\\\"',
            '\\\\': '\\\\\\\\'
          };

      escapable.lastIndex = 0;

      return escapable.test(this) ? '"' + this.replace(escapable, function(a) {
        var c = meta[a];

        return typeof c === 'string' ? c :
          '\\\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
      }) + '"' : '"' + this + '"';
  }
  end

  def intern
    self
  end

  def length
    `this.length`
  end

  def lstrip
    `this.replace(/^\s*/, '')`
  end

  def next
    `String.fromCharCode(this.charCodeAt(0))`
  end

  def reverse
    `this.split('').reverse().join('')`
  end

  def split(split, limit = undefined)
    `this.split(split, limit)`
  end

  def start_with?(prefix)
    `this.indexOf(prefix) === 0`
  end

  def sub(pattern, replace = undefined, &block)
    %x{
      if (block !== nil) {
        return this.replace(pattern, function(str) {
          return $yield.call($context, str);
        });
      }
      else {
        return this.replace(pattern, replace);
      }
    }
  end

  alias succ next

  def to_f
    `parseFloat(this)`
  end

  def to_i(base = 10)
    `parseInt(this, base)`
  end

  def to_proc
    %x{
      var self = this;
      return function(iter, arg) { return arg['$' + self](); };
    }
  end

  def to_s
    `this.toString()`
  end

  alias to_sym intern

  def upcase
    `this.toUpperCase()`
  end
end

Symbol = String
