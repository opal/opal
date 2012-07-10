class String < `String`
  `String.prototype._isString = true`

  include Comparable

  def self.try_convert(what)
    what.to_str
  rescue
    nil
  end

  def self.new(str = '')
    %x{
      var s = new String(#{str.to_s});
      s.$m  = #{self}.$m_tbl;
      s.$k  = #{self};
      return s;
    }
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
          pattern = #{self}.valueOf();

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
    `#{self}.toString() + other`
  end

  def <=>(other)
    %x{
      if (typeof other !== 'string') {
        return nil;
      }

      return #{self} > other ? 1 : (#{self} < other ? -1 : 0);
    }
  end

  def <(other)
    `#{self} < other`
  end

  def <=(other)
    `#{self} <= other`
  end

  def >(other)
    `#{self} > other`
  end

  def >=(other)
    `#{self} >= other`
  end

  def ==(other)
    `#{self} == other`
  end

  alias === ==

  def =~(other)
    %x{
      if (typeof other === 'string') {
        #{ raise 'string given' };
      }

      return #{other =~ self};
    }
  end

  # TODO: implement range based accessors
  def [](index, length)
    %x{
      if (length == null) {
        if (index < 0) {
          index += #{self}.length;
        }

        if (index >= #{self}.length || index < 0) {
          return nil;
        }

        return #{self}.substr(index, 1);
      }

      if (index < 0) {
        index += #{self}.length + 1;
      }

      if (index > #{self}.length || index < 0) {
        return nil;
      }

      return #{self}.substr(index, length);
    }
  end

  def capitalize
    `#{self}.charAt(0).toUpperCase() + #{self}.substr(1).toLowerCase()`
  end

  def casecmp(other)
    %x{
      if (typeof other !== 'string') {
        return other;
      }

      var a = #{self}.toLowerCase(),
          b = other.toLowerCase();

      return a > b ? 1 : (a < b ? -1 : 0);
    }
  end

  def chars
    return enum_for :chars unless block_given?

    %x{
      for (var i = 0, length = #{self}.length; i < length; i++) {
        #{yield `#{self}.charAt(i)`}
      }
    }
  end

  def chomp(separator = $/)
    %x{
      if (separator === "\\n") {
        return #{self}.replace(/(\\n|\\r|\\r\\n)$/, '');
      }
      else if (separator === "") {
        return #{self}.replace(/(\\n|\\r\\n)+$/, '');
      }
      return #{self}.replace(new RegExp(separator + '$'), '');
    }
  end

  def chop
    `#{self}.substr(0, #{self}.length - 1)`
  end

  def chr
    `#{self}.charAt(0)`
  end

  def downcase
    `#{self}.toLowerCase()`
  end

  alias each_char chars

  def each_line (separator = $/)
    return enum_for :each_line, separator unless block_given?

    %x{
      var splitted = #{self}.split(separator);

      for (var i = 0, length = splitted.length; i < length; i++) {
        #{yield `splitted[i] + separator`}
      }
    }
  end

  def empty?
    `#{self}.length === 0`
  end

  def end_with?(*suffixes)
    %x{
      for (var i = 0, length = suffixes.length; i < length; i++) {
        var suffix = suffixes[i];

        if (#{self}.lastIndexOf(suffix) === #{self}.length - suffix.length) {
          return true;
        }
      }

      return false;
    }
  end

  alias eql? ==

  def equal?(val)
    `#{self}.toString() === val.toString()`
  end

  def getbyte(idx)
    `#{self}.charCodeAt(idx)`
  end

  def gsub(pattern, replace, &block)
    return enum_for :gsub, pattern, replace if !block && `pattern == null`

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
    `#{self}.toString()`
  end

  def hex
    to_i 16
  end

  def include?(other)
    `#{self}.indexOf(other) !== -1`
  end

  def index(what, offset)
    unless String === what || Regexp === what
      raise TypeError, "type mismatch: #{what.class} given"
    end

    %x{
      var result = -1;

      if (offset != null) {
        if (offset < 0) {
          offset = #{self}.length - offset;
        }

        if (#{what.is_a?(Regexp)}) {
          result = #{what =~ `#{self}.substr(offset)` || -1}
        }
        else {
          result = #{self}.substr(offset).indexOf(substr);
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
          result = #{self}.indexOf(substr);
        }
      }

      return result === -1 ? nil : result;
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

      return escapable.test(#{self}) ? '"' + #{self}.replace(escapable, function(a) {
        var c = meta[a];

        return typeof c === 'string' ? c :
          '\\\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
      }) + '"' : '"' + #{self} + '"';
  }
  end

  def intern
    self
  end

  alias lines each_line

  def length
    `#{self}.length`
  end

  def ljust(integer, padstr = ' ')
    raise NotImplementedError
  end

  def lstrip
    `#{self}.replace(/^\\s*/, '')`
  end

  def match(pattern, pos, &block)
    (pattern.is_a?(Regexp) ? pattern : /#{Regexp.escape(pattern)}/).match(self, pos, &block)
  end

  def next
    %x{
      if (#{self}.length === 0) {
        return "";
      }

      var initial = #{self}.substr(0, #{self}.length - 1);
      var last    = String.fromCharCode(#{self}.charCodeAt(#{self}.length - 1) + 1);

      return initial + last;
    }
  end

  def ord
    `#{self}.charCodeAt(0)`
  end

  def partition(str)
    %x{
      var result = #{self}.split(str);
      var splitter = (result[0].length === #{self}.length ? "" : str);

      return [result[0], splitter, result.slice(1).join(str.toString())];
    }
  end

  def reverse
    `#{self}.split('').reverse().join('')`
  end

  def rstrip
    `#{self}.replace(/\\s*$/, '')`
  end

  alias size length

  alias slice []

  def split(pattern = $; || ' ', limit = undefined)
    `#{self}.split(pattern, limit)`
  end

  def start_with?(*prefixes)
    %x{
      for (var i = 0, length = prefixes.length; i < length; i++) {
        if (#{self}.indexOf(prefixes[i]) === 0) {
          return true;
        }
      }

      return false;
    }
  end

  def strip
    `#{self}.replace(/^\\s*/, '').replace(/\\s*$/, '')`
  end

  def sub(pattern, replace, &block)
    %x{
      if (typeof(replace) === 'string') {
        return #{self}.replace(pattern, replace);
      }
      if (block !== nil) {
        return #{self}.replace(pattern, function(str) {
          return block.call(__context, str);
        });
      }
      else if (replace != null) {
        if (#{replace.is_a?(Hash)}) {
          return #{self}.replace(pattern, function(str) {
            var value = #{replace[str]};

            return (value == null) ? nil : #{value.to_s};
          });
        }
        else {
          replace = #{String.try_convert(replace)};

          if (replace == null) {
            #{raise TypeError, "can't convert #{replace.class} into String"};
          }

          return #{self}.replace(pattern, replace);
        }
      }
      else {
        return #{self}.replace(pattern, replace.toString());
      }
    }
  end

  alias succ next

  def sum(n = 16)
    %x{
      var result = 0;

      for (var i = 0, length = #{self}.length; i < length; i++) {
        result += (#{self}.charCodeAt(i) % ((1 << n) - 1));
      }

      return result;
    }
  end

  def swapcase
    %x{
      var str = #{self}.replace(/([a-z]+)|([A-Z]+)/g, function($0,$1,$2) {
        return $1 ? $0.toUpperCase() : $0.toLowerCase();
      });

      if (#{self}.$k === String) {
        return str;
      }

      return #{self.class.new `str`};
    }
  end

  def to_a
    %x{
      if (#{self}.length === 0) {
        return [];
      }

      return [#{self}];
    }
  end

  def to_f
    %x{
      var result = parseFloat(#{self});

      return isNaN(result) ? 0 : result;
    }
  end

  def to_i(base = 10)
    %x{
      var result = parseInt(#{self}, base);

      if (isNaN(result)) {
        return 0;
      }

      return result;
    }
  end

  alias to_json inspect

  def to_proc
    %x{
      var name = #{self};

      return function(s, m, arg) { return arg.$m[name](arg, name); };
    }
  end

  def to_s
    `#{self}.toString()`
  end

  alias to_str to_s

  alias to_sym intern

  def upcase
    `#{self}.toUpperCase()`
  end
end

Symbol = String