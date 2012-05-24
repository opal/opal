class String
  include Comparable

  def self.try_convert(what)
    what.to_str
  rescue
    null
  end

  def self.new(str = '')
    allocate str.to_s
  end

  def %(data)
    sprintf self, data
  end

  def *(count)
    %x{
      if (count < 1) {
        return '';
      }

      var result  = '',
          pattern = this.valueOf();

      while (count > 0) {
        if (count & 1) {
          result += pattern;
        }

        count >>= 1, pattern += pattern;
      }

      return result;
    }
  end

  def +(other)
    `this + other`
  end

  def <=>(other)
    %x{
      if (typeof other !== 'string') {
        return null;
      }

      return this > other ? 1 : (this < other ? -1 : 0);
    }
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

  def ==(other)
    `this == other`
  end

  alias === ==

  def =~(other)
    %x{
      if (typeof other === 'string') {
        throw RubyTypeError.$new(null, 'string given');
      }

      return #{other =~ self};
    }
  end

  # TODO: implement range based accessors
  # TODO: implement regex based accessors
  def [](index, length = undefined)
    `this.substr(index, length)`
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

  def chars
    return enum_for :chars unless block_given?

    %x{
      for (var i = 0, length = this.length; i < length; i++) {
        #{yield `this.charAt(i)`}
      }
    }
  end

  def chomp(separator = $/)
    %x{
      if (separator === "\\n") {
        return this.replace(/(\\n|\\r|\\r\\n)$/, '');
      }
      else if (separator === "") {
        return this.replace(/(\\n|\\r\\n)+$/, '');
      }
      return this.replace(new RegExp(separator + '$'), '');
    }
  end

  def chop
    `this.substr(0, this.length - 1)`
  end

  def chr
    `this.charAt(0)`
  end

  def count (*sets)
    raise NotImplementedError
  end

  def crypt
    raise NotImplementedError
  end

  def delete (*sets)
    raise NotImplementedErrois
  end

  def downcase
    `this.toLowerCase()`
  end

  alias each_char chars

  def each_line (separator = $/)
    return enum_for :each_line, separator unless block_given?

    %x{
      var splitted = this.split(separator);

      for (var i = 0, length = splitted.length; i < length; i++) {
        #{yield `splitted[i] + separator`}
      }
    }
  end

  def empty?
    `this.length === 0`
  end

  def end_with?(*suffixes)
    %x{
      for (var i = 0, length = suffixes.length; i < length; i++) {
        var suffix = suffixes[i];

        if (this.lastIndexOf(suffix) === this.length - suffix.length) {
          return true;
        }
      }

      return false;
    }
  end

  alias eql? ==

  def equal?(val)
    `this.toString() === val.toString()`
  end

  def getbyte(index)
    `this.charCodeAt(index)`
  end

  def gsub(pattern, replace = undefined, &block)
    return enum_for :gsub, pattern, replace if !block && `pattern === undefined`

    if pattern.is_a?(String)
      pattern = /#{Regexp.escape(pattern)}/
    end

    %x{
      var pattern = pattern.toString(),
          options = pattern.substr(pattern.lastIndexOf('/') + 1) + 'g',
          regexp  = pattern.substr(1, pattern.lastIndexOf('/') - 1);

      return #{sub `new RegExp(regexp, options)`, replace, &block};
    }
  end

  def hash
    `this.toString()`
  end

  def hex
    to_i 16
  end

  def include?(other)
    `this.indexOf(other) !== -1`
  end

  def index(what, offset = undefined)
    unless String === what || Regexp === what
      raise TypeError, "type mismatch: #{what.class} given"
    end

    %x{
      var result = -1;

      if (offset !== undefined) {
        if (offset < 0) {
          offset = this.length - offset;
        }

        if (#{what.is_a?(Regexp)}) {
          result = #{what =~ `this.substr(offset)` || -1}
        }
        else {
          result = this.substr(offset).indexOf(substr);
        }

        if (result !== -1) {
          result += offset;
        }
      }
      else {
        if (#{what.is_a?(Regexp)}) {
          result = #{(what =~ self) || -1}
        }
        else {
          result = this.indexOf(substr);
        }
      }

      return result === -1 ? null : result;
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

  alias lines each_line

  def length
    `this.length`
  end

  def ljust(integer, padstr = ' ')
    raise NotImplementedError
  end

  def lstrip
    `this.replace(/^\s*/, '')`
  end

  def match(pattern, pos = undefined, &block)
    (pattern.is_a?(Regexp) ? pattern : /#{Regexp.escape(pattern)}/).match(self, pos, &block)
  end

  def next
    `String.fromCharCode(this.charCodeAt(0) + 1)`
  end

  def oct
    to_i 8
  end

  def ord
    `this.charCodeAt(0)`
  end

  def partition(what)
    %x{
      var result = this.split(what);

      return [result[0], what.toString(), result.slice(1).join(what.toString())];
    }
  end

  def reverse
    `this.split('').reverse().join('')`
  end

  def rpartition(what)
    raise NotImplementedError
  end

  def rstrip
    `this.replace(/\s*$/, '')`
  end

  def scan(pattern)
    if pattern.is_a?(String)
      pattern = /#{Regexp.escape(pattern)}/
    end

    result   = []
    original = pattern

    %x{
      var pattern = pattern.toString(),
          options = pattern.substr(pattern.lastIndexOf('/') + 1) + 'g',
          regexp  = pattern.substr(1, pattern.lastIndexOf('/') - 1);

      var matches = this.match(pattern);

      for (var i = 0, length = matches.length; i < length; i++) {
        var current = matches[i].match(/^\\(|[^\\\\]\\(/) ? matches[i] : matches[i].match(original);

        if (#{block_given?}) {
          #{yield current};
        }
        else {
          result.push(current);
        }
      }
    }

    block_given? ? self : result
  end

  alias size length

  alias slice []

  def split(pattern = $; || ' ', limit = undefined)
    `this.split(pattern === ' ' ? strip : this, limit)`
  end

  def squeeze(*sets)
    raise NotImplementedError
  end

  def start_with?(*prefixes)
    %x{
      for (var i = 0, length = prefixes.length; i < length; i++) {
        if (this.indexOf(prefixes[i]) === 0) {
          return true;
        }
      }

      return false;
    }
  end

  def strip
    lstrip.rstrip
  end

  def sub(pattern, replace = undefined, &block)
    %x{
      if (block !== null) {
        return this.replace(pattern, function(str) {
          $opal.match_data = arguments

          return $yielder.call($context, null, str);
        });
      }
      else if (#{Object === replace}) {
        if (#{replace.is_a?(Hash)}) {
          return this.replace(pattern, function(str) {
            var value = #{replace[str]};

            return (value === null) ? undefined : #{value.to_s};
          });
        }
        else {
          replace = #{String.try_convert(replace)};

          if (replace === null) {
            #{raise TypeError, "can't convert #{replace.class} into String"};
          }

          return this.replace(pattern, replace);
        }
      }
      else {
        return this.replace(pattern, replace.toString());
      }
    }
  end

  alias succ next

  def sum(n = 16)
    %x{
      var result = 0;

      for (var i = 0, length = this.length; i < length; i++) {
        result += this.charCodeAt(i) % ((1 << n) - 1);
      }

      return result;
    }
  end

  def swapcase
    %x{
      return this.replace(/([a-z]+)|([A-Z]+)/g, function($0,$1,$2) {
        return $1 ? $0.toUpperCase() : $0.toLowerCase();
      });
    }
  end

  def to_f
    `parseFloat(this)`
  end

  def to_i(base = 10)
    %x{
      var result = parseInt(this, base);

      if (isNaN(result)) {
        return 0;
      }

      return result;
    }
  end

  def to_proc
    %x{
      var self = this;

      return function(iter, arg) { return arg[mid_to_jsid(self)](); };
    }
  end

  def to_s
    `this.toString()`
  end

  alias to_str to_s

  alias to_sym intern

  def tr(from, to)
    raise NotImplementedError
  end

  def tr_s(from, to)
    raise NotImplementedError
  end

  def unpack(format)
    raise NotImplementedError
  end

  def upcase
    `this.toUpperCase()`
  end

  def upto(other, exclusive = false)
    return enum_for :upto, other, exclusive unless block_given?

    current = self

    until current == other
      yield current

      current = current.next
    end

    yield current unless exclusive

    self
  end
end

Symbol = String
