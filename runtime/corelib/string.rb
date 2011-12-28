class String
  include Comparable

  def self.try_convert(what)
    what.to_str
  rescue
    nil
  end

  def self.new(str = '')
    str.to_s
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
          pattern = self.valueOf();

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
    `self + other`
  end

  def <=>(other)
    %x{
      if (typeof other !== 'string') {
        return nil;
      }

      return self > other ? 1 : (self < other ? -1 : 0);
    }
  end

  def <(other)
    `self < other`
  end

  def <=(other)
    `self <= other`
  end

  def >(other)
    `self > other`
  end

  def >=(other)
    `self >= other`
  end

  def ==(other)
    `self.valueOf() === other.valueOf()`
  end

  alias_method :===, :==

  def =~(other)
    %x{
      if (#{Opal.string?(other)}) {
        #{raise TypeError, 'type mismatch: String given'};
      }

      return #{other =~ self};
    }
  end

  # TODO: implement range based accessors
  # TODO: implement regex based accessors
  def [](index, length = undefined)
    `self.substr(index, length)`
  end

  def capitalize
    `self.charAt(0).toUpperCase() + self.substr(1).toLowerCase()`
  end

  def casecmp(other)
    %x{
      if (#{!Opal.string?(other)}) {
        return other;
      }

      var a = self.toLowerCase(),
          b = other.toLowerCase();

      return a > b ? 1 : (a < b ? -1 : 0);
    }
  end

  def chars
    return enum_for :chars unless block_given?

    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        #{yield `self.charAt(i)`}
      }
    }
  end

  def chomp(separator = $/)
    if separator == "\n"
      sub(/(\n|\r|\r\n)$/, '')
    else
      sub(/#{Regexp.escape(separator)}$/, '')
    end
  end

  def chop
    `self.substr(0, self.length - 1)`
  end

  def chr
    `self.charAt(0)`
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
    `self.toLowerCase()`
  end

  alias_method :each_char, :chars

  def each_line (separator = $/)
    return enum_for :each_line, separator unless block_given?

    %x{
      var splitted = self.split(separator);

      for (var i = 0, length = splitted.length; i < length; i++) {
        #{yield `splitted[i] + separator`}
      }
    }
  end

  def empty?
    `self.length === 0`
  end

  def end_with?(*suffixes)
    %x{
      for (var i = 0, length = suffixes.length; i < length; i++) {
        var suffix = suffixes[i];

        if (self.lastIndexOf(suffix) === self.length - suffix.length) {
          return true;
        }
      }

      return false;
    }
  end

  alias_method :eql?, :==

  def getbyte(index)
    `self.charCodeAt(index)`
  end

  def gsub(pattern, replace = undefined, &block)
    return enum_for :gsub, pattern, replace if !block && Opal.undefined?(pattern)

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
    `self.toString()`
  end

  def hex
    base 16
  end

  def include?(other)
    `self.indexOf(other) !== -1`
  end

  def index(what, offset = undefined)
    unless Opal.object?(what) && (what.is_a?(String) || what.is_a?(Regexp))
      raise TypeError, "type mismatch: #{what.class} given"
    end

    %x{
      var result = -1;

      if (offset !== undefined) {
        if (offset < 0) {
          offset = self.length - offset;
        }

        if (#{what.is_a?(Regexp)}) {
          result = #{what =~ `self.substr(offset)` || -1}
        }
        else {
          result = self.substr(offset).indexOf(substr);
        }

        if (result !== -1) {
          result += offset;
        }
      }
      else {
        if (#{what.is_a?(Regexp)}) {
          result = #{what =~ self || -1}
        }
        else {
          result = self.indexOf(substr);
        }
      }

      return result === -1 ? nil : result;
    }
  end

  def inspect
    `string_inspect(self)`
  end

  def intern
    self
  end

  alias_method :lines, :each_line

  def length
    `self.length`
  end

  def ljust(integer, padstr = ' ')
    raise NotImplementedError
  end

  def lstrip
    `self.replace(/^\s*/, '')`
  end

  def match(pattern, pos = undefined, &block)
    (pattern.is_a?(Regexp) ? pattern : /#{Regexp.escape(pattern)}/).match(self, pos, &block)
  end

  def next
    raise NotImplementedError
  end

  def oct
    base 8
  end

  def ord
    `self.charCodeAt(0)`
  end

  def partition(what)
    %x{
      var result = self.split(what);

      return [result[0], what.toString(), result.slice(1).join(what.toString())];
    }
  end

  def reverse
    `self.split('').reverse().join('')`
  end

  def rpartition(what)
    raise NotImplementedError
  end

  def rstrip
    `self.replace(/\s*$/, '')`
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

      var matches = self.match(pattern);

      for (var i = 0, length = matches.length; i < length; i++) {
        var current = matches[i].match(/^\(|[^\\]\(/) ? matches[i] : matches[i].match(original);

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

  alias_method :size, :length

  alias_method :slice, :[]

  def split(pattern = $; || ' ', limit = undefined)
    `self.split(#{pattern == ' ' ? strip : self}, limit)`
  end

  def squeeze(*sets)
    raise NotImplementedError
  end

  def start_with?(*prefixes)
    %x{
      for (var i = 0, length = prefixes.length; i < length; i++) {
        if (self.indexOf(prefixes[i]) === 0) {
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
      if (block !== nil) {
        return self.replace(pattern, function(str) {
          $opal.match_data = arguments

          return $yielder.call($context, null, str);
        });
      }
      else if (#{Opal.object?(replace)}) {
        if (#{replace.is_a?(Hash)}) {
          return self.replace(pattern, function(str) {
            var value = #{replace[str]};

            return (value === nil) ? undefined : #{value.to_s};
          });
        }
        else {
          replace = #{String.try_convert(replace)};

          if (replace === nil) {
            #{raise TypeError, "can't convert #{replace.class} into String"};
          }

          return self.replace(pattern, replace);
        }
      }
      else {
        return self.replace(pattern, replace.toString());
      }
    }
  end

  alias_method :succ, :next

  def sum(n = 16)
    %x{
      var result = 0;

      for (var i = 0, length = self.length; i < length; i++) {
        result += self.charCodeAt(i) % ((1 << n) - 1);
      }

      return result;
    }
  end

  def swapcase
    %x{
      return self.replace(/([a-z]+)|([A-Z]+)/g, function($0,$1,$2) {
        return $1 ? $0.toUpperCase() : $0.toLowerCase();
      });
    }
  end

  def to_f
    `parseFloat(self)`
  end

  def to_i(base = 10)
    %x{
      var result = parseInt(self, base);

      if (isNaN(result)) {
        return 0;
      }

      return result;
    }
  end

  def to_native
    `self.valueOf()`
  end

  def to_proc
    `return function(iter, arg) { return arg[mid_to_jsid(self)](); };`
  end

  def to_s
    `self.toString()`
  end

  alias_method :to_str, :to_s

  alias_method :to_sym, :intern

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
    `self.toUpperCase()`
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
