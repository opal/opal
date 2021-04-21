# helpers: coerce_to, respond_to

require 'corelib/comparable'
require 'corelib/regexp'

class String < `String`
  include Comparable

  %x{
    Opal.defineProperty(#{self}.$$prototype, '$$is_string', true);

    Opal.defineProperty(#{self}.$$prototype, '$$cast', function(string) {
      var klass = this.$$class;
      if (klass.$$constructor === String) {
        return string;
      } else {
        return new klass.$$constructor(string);
      }
    });
  }

  def __id__
    `self.toString()`
  end

  alias object_id __id__

  def self.try_convert(what)
    Opal.coerce_to?(what, String, :to_str)
  end

  def self.new(str = '')
    str = `$coerce_to(str, #{String}, 'to_str')`
    `new self.$$constructor(str)`
  end

  def initialize(str = undefined)
    %x{
      if (str === undefined) {
        return self;
      }
    }
    raise NotImplementedError, 'Mutable strings are not supported in Opal.'
  end

  def %(data)
    if Array === data
      format(self, *data)
    else
      format(self, data)
    end
  end

  def *(count)
    %x{
      count = $coerce_to(count, #{Integer}, 'to_int');

      if (count < 0) {
        #{raise ArgumentError, 'negative argument'}
      }

      if (count === 0) {
        return self.$$cast('');
      }

      var result = '',
          string = self.toString();

      // All credit for the bit-twiddling magic code below goes to Mozilla
      // polyfill implementation of String.prototype.repeat() posted here:
      // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/repeat

      if (string.length * count >= 1 << 28) {
        #{raise RangeError, 'multiply count must not overflow maximum string size'}
      }

      for (;;) {
        if ((count & 1) === 1) {
          result += string;
        }
        count >>>= 1;
        if (count === 0) {
          break;
        }
        string += string;
      }

      return self.$$cast(result);
    }
  end

  def +(other)
    other = `$coerce_to(#{other}, #{String}, 'to_str')`

    `self + #{other.to_s}`
  end

  def <=>(other)
    if other.respond_to? :to_str
      other = other.to_str.to_s

      `self > other ? 1 : (self < other ? -1 : 0)`
    else
      %x{
        var cmp = #{other <=> self};

        if (cmp === nil) {
          return nil;
        }
        else {
          return cmp > 0 ? -1 : (cmp < 0 ? 1 : 0);
        }
      }
    end
  end

  def ==(other)
    %x{
      if (other.$$is_string) {
        return self.toString() === other.toString();
      }
      if ($respond_to(other, '$to_str')) {
        return #{other == self};
      }
      return false;
    }
  end

  alias eql? ==
  alias === ==

  def =~(other)
    %x{
      if (other.$$is_string) {
        #{raise TypeError, 'type mismatch: String given'};
      }

      return #{other =~ self};
    }
  end

  def [](index, length = undefined)
    %x{
      var size = self.length, exclude;

      if (index.$$is_range) {
        exclude = index.excl;
        length  = $coerce_to(index.end, #{Integer}, 'to_int');
        index   = $coerce_to(index.begin, #{Integer}, 'to_int');

        if (Math.abs(index) > size) {
          return nil;
        }

        if (index < 0) {
          index += size;
        }

        if (length < 0) {
          length += size;
        }

        if (!exclude) {
          length += 1;
        }

        length = length - index;

        if (length < 0) {
          length = 0;
        }

        return self.$$cast(self.substr(index, length));
      }


      if (index.$$is_string) {
        if (length != null) {
          #{raise TypeError}
        }
        return self.indexOf(index) !== -1 ? self.$$cast(index) : nil;
      }


      if (index.$$is_regexp) {
        var match = self.match(index);

        if (match === null) {
          #{$~ = nil}
          return nil;
        }

        #{$~ = MatchData.new(`index`, `match`)}

        if (length == null) {
          return self.$$cast(match[0]);
        }

        length = $coerce_to(length, #{Integer}, 'to_int');

        if (length < 0 && -length < match.length) {
          return self.$$cast(match[length += match.length]);
        }

        if (length >= 0 && length < match.length) {
          return self.$$cast(match[length]);
        }

        return nil;
      }


      index = $coerce_to(index, #{Integer}, 'to_int');

      if (index < 0) {
        index += size;
      }

      if (length == null) {
        if (index >= size || index < 0) {
          return nil;
        }
        return self.$$cast(self.substr(index, 1));
      }

      length = $coerce_to(length, #{Integer}, 'to_int');

      if (length < 0) {
        return nil;
      }

      if (index > size || index < 0) {
        return nil;
      }

      return self.$$cast(self.substr(index, length));
    }
  end

  alias byteslice []

  def b
    force_encoding('binary')
  end

  def capitalize
    `self.$$cast(self.charAt(0).toUpperCase() + self.substr(1).toLowerCase())`
  end

  def casecmp(other)
    return nil unless other.respond_to?(:to_str)
    other = `$coerce_to(other, #{String}, 'to_str')`.to_s
    %x{
      var ascii_only = /^[\x00-\x7F]*$/;
      if (ascii_only.test(self) && ascii_only.test(other)) {
        self = self.toLowerCase();
        other = other.toLowerCase();
      }
    }
    self <=> other
  end

  def casecmp?(other)
    %x{
      var cmp = #{casecmp(other)};
      if (cmp === nil) {
        return nil;
      } else {
        return cmp === 0;
      }
    }
  end

  def center(width, padstr = ' ')
    width  = `$coerce_to(#{width}, #{Integer}, 'to_int')`
    padstr = `$coerce_to(#{padstr}, #{String}, 'to_str')`.to_s

    if padstr.empty?
      raise ArgumentError, 'zero width padding'
    end

    return self if `width <= self.length`

    %x{
      var ljustified = #{ljust ((width + `self.length`) / 2).ceil, padstr},
          rjustified = #{rjust ((width + `self.length`) / 2).floor, padstr};

      return self.$$cast(rjustified + ljustified.slice(self.length));
    }
  end

  def chars(&block)
    return each_char.to_a unless block

    each_char(&block)
  end

  def chomp(separator = $/)
    return self if `separator === nil || self.length === 0`

    separator = Opal.coerce_to!(separator, String, :to_str).to_s

    %x{
      var result;

      if (separator === "\n") {
        result = self.replace(/\r?\n?$/, '');
      }
      else if (separator === "") {
        result = self.replace(/(\r?\n)+$/, '');
      }
      else if (self.length >= separator.length) {
        var tail = self.substr(self.length - separator.length, separator.length);

        if (tail === separator) {
          result = self.substr(0, self.length - separator.length);
        }
      }

      if (result != null) {
        return self.$$cast(result);
      }
    }

    self
  end

  def chop
    %x{
      var length = self.length, result;

      if (length <= 1) {
        result = "";
      } else if (self.charAt(length - 1) === "\n" && self.charAt(length - 2) === "\r") {
        result = self.substr(0, length - 2);
      } else {
        result = self.substr(0, length - 1);
      }

      return self.$$cast(result);
    }
  end

  def chr
    `self.charAt(0)`
  end

  def clone
    copy = `new String(self)`
    copy.copy_singleton_methods(self)
    copy.initialize_clone(self)
    copy
  end

  def dup
    copy = `new String(self)`
    copy.initialize_dup(self)
    copy
  end

  def count(*sets)
    %x{
      if (sets.length === 0) {
        #{raise ArgumentError, 'ArgumentError: wrong number of arguments (0 for 1+)'}
      }
      var char_class = char_class_from_char_sets(sets);
      if (char_class === null) {
        return 0;
      }
      return self.length - self.replace(new RegExp(char_class, 'g'), '').length;
    }
  end

  def delete(*sets)
    %x{
      if (sets.length === 0) {
        #{raise ArgumentError, 'ArgumentError: wrong number of arguments (0 for 1+)'}
      }
      var char_class = char_class_from_char_sets(sets);
      if (char_class === null) {
        return self;
      }
      return self.$$cast(self.replace(new RegExp(char_class, 'g'), ''));
    }
  end

  def delete_prefix(prefix)
    %x{
      if (!prefix.$$is_string) {
        prefix = $coerce_to(prefix, #{String}, 'to_str');
      }

      if (self.slice(0, prefix.length) === prefix) {
        return self.$$cast(self.slice(prefix.length));
      } else {
        return self;
      }
    }
  end

  def delete_suffix(suffix)
    %x{
      if (!suffix.$$is_string) {
        suffix = $coerce_to(suffix, #{String}, 'to_str');
      }

      if (self.slice(self.length - suffix.length) === suffix) {
        return self.$$cast(self.slice(0, self.length - suffix.length));
      } else {
        return self;
      }
    }
  end

  def downcase
    `self.$$cast(self.toLowerCase())`
  end

  def each_char(&block)
    return enum_for(:each_char) { size } unless block_given?

    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        Opal.yield1(block, self.charAt(i));
      }
    }

    self
  end

  def each_line(separator = $/, &block)
    return enum_for :each_line, separator unless block_given?

    %x{
      if (separator === nil) {
        Opal.yield1(block, self);

        return self;
      }

      separator = $coerce_to(separator, #{String}, 'to_str')

      var a, i, n, length, chomped, trailing, splitted;

      if (separator.length === 0) {
        for (a = self.split(/(\n{2,})/), i = 0, n = a.length; i < n; i += 2) {
          if (a[i] || a[i + 1]) {
            var value = (a[i] || "") + (a[i + 1] || "");
            Opal.yield1(block, self.$$cast(value));
          }
        }

        return self;
      }

      chomped  = #{chomp(separator)};
      trailing = self.length != chomped.length;
      splitted = chomped.split(separator);

      for (i = 0, length = splitted.length; i < length; i++) {
        if (i < length - 1 || trailing) {
          Opal.yield1(block, self.$$cast(splitted[i] + separator));
        }
        else {
          Opal.yield1(block, self.$$cast(splitted[i]));
        }
      }
    }

    self
  end

  def empty?
    `self.length === 0`
  end

  def end_with?(*suffixes)
    %x{
      for (var i = 0, length = suffixes.length; i < length; i++) {
        var suffix = $coerce_to(suffixes[i], #{String}, 'to_str').$to_s();

        if (self.length >= suffix.length &&
            self.substr(self.length - suffix.length, suffix.length) == suffix) {
          return true;
        }
      }
    }

    false
  end

  alias equal? ===

  def gsub(pattern, replacement = undefined, &block)
    %x{
      if (replacement === undefined && block === nil) {
        return #{enum_for :gsub, pattern};
      }

      var result = '', match_data = nil, index = 0, match, _replacement;

      if (pattern.$$is_regexp) {
        pattern = Opal.global_multiline_regexp(pattern);
      } else {
        pattern = $coerce_to(pattern, #{String}, 'to_str');
        pattern = new RegExp(pattern.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gm');
      }

      var lastIndex;
      while (true) {
        match = pattern.exec(self);

        if (match === null) {
          #{$~ = nil}
          result += self.slice(index);
          break;
        }

        match_data = #{MatchData.new `pattern`, `match`};

        if (replacement === undefined) {
          lastIndex = pattern.lastIndex;
          _replacement = block(match[0]);
          pattern.lastIndex = lastIndex; // save and restore lastIndex
        }
        else if (replacement.$$is_hash) {
          _replacement = #{`replacement`[`match[0]`].to_s};
        }
        else {
          if (!replacement.$$is_string) {
            replacement = $coerce_to(replacement, #{String}, 'to_str');
          }
          _replacement = replacement.replace(/([\\]+)([0-9+&`'])/g, function (original, slashes, command) {
            if (slashes.length % 2 === 0) {
              return original;
            }
            switch (command) {
            case "+":
              for (var i = match.length - 1; i > 0; i--) {
                if (match[i] !== undefined) {
                  return slashes.slice(1) + match[i];
                }
              }
              return '';
            case "&": return slashes.slice(1) + match[0];
            case "`": return slashes.slice(1) + self.slice(0, match.index);
            case "'": return slashes.slice(1) + self.slice(match.index + match[0].length);
            default:  return slashes.slice(1) + (match[command] || '');
            }
          }).replace(/\\\\/g, '\\');
        }

        if (pattern.lastIndex === match.index) {
          result += (self.slice(index, match.index) + _replacement + (self[match.index] || ""));
          pattern.lastIndex += 1;
        }
        else {
          result += (self.slice(index, match.index) + _replacement)
        }
        index = pattern.lastIndex;
      }

      #{$~ = `match_data`}
      return self.$$cast(result);
    }
  end

  def hash
    `self.toString()`
  end

  def hex
    to_i 16
  end

  def include?(other)
    %x{
      if (!other.$$is_string) {
        other = $coerce_to(other, #{String}, 'to_str');
      }
      return self.indexOf(other) !== -1;
    }
  end

  def index(search, offset = undefined)
    %x{
      var index,
          match,
          regex;

      if (offset === undefined) {
        offset = 0;
      } else {
        offset = $coerce_to(offset, #{Integer}, 'to_int');
        if (offset < 0) {
          offset += self.length;
          if (offset < 0) {
            return nil;
          }
        }
      }

      if (search.$$is_regexp) {
        regex = Opal.global_multiline_regexp(search);
        while (true) {
          match = regex.exec(self);
          if (match === null) {
            #{$~ = nil};
            index = -1;
            break;
          }
          if (match.index >= offset) {
            #{$~ = MatchData.new(`regex`, `match`)}
            index = match.index;
            break;
          }
          regex.lastIndex = match.index + 1;
        }
      } else {
        search = $coerce_to(search, #{String}, 'to_str');
        if (search.length === 0 && offset > self.length) {
          index = -1;
        } else {
          index = self.indexOf(search, offset);
        }
      }

      return index === -1 ? nil : index;
    }
  end

  def inspect
    %x{
      var escapable = /[\\\"\x00-\x1f\u007F-\u009F\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
          meta = {
            '\u0007': '\\a',
            '\u001b': '\\e',
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '\v': '\\v',
            '"' : '\\"',
            '\\': '\\\\'
          },
          escaped = self.replace(escapable, function (chr) {
            return meta[chr] || '\\u' + ('0000' + chr.charCodeAt(0).toString(16).toUpperCase()).slice(-4);
          });
      return '"' + escaped.replace(/\#[\$\@\{]/g, '\\$&') + '"';
    }
  end

  def intern
    `self.toString()`
  end

  def lines(separator = $/, &block)
    e = each_line(separator, &block)
    block ? self : e.to_a
  end

  def length
    `self.length`
  end

  def ljust(width, padstr = ' ')
    width  = `$coerce_to(#{width}, #{Integer}, 'to_int')`
    padstr = `$coerce_to(#{padstr}, #{String}, 'to_str')`.to_s

    if padstr.empty?
      raise ArgumentError, 'zero width padding'
    end

    return self if `width <= self.length`

    %x{
      var index  = -1,
          result = "";

      width -= self.length;

      while (++index < width) {
        result += padstr;
      }

      return self.$$cast(self + result.slice(0, width));
    }
  end

  def lstrip
    `self.replace(/^\s*/, '')`
  end

  def ascii_only?
    # non-ASCII-compatible encoding must return false
    # NOTE: Encoding::UTF_16LE is also non-ASCII-compatible encoding,
    # but since the default encoding in JavaScript is UTF_16LE,
    # we cannot return false otherwise the following will (incorrectly) return false: "hello".ascii_only?
    # In other words, we cannot tell the difference between:
    # - "hello".force_encoding("UTF-16LE")
    # - "hello"
    # The problem is that "ascii_only" should return false in the first case and true in the second case.
    if encoding == Encoding::UTF_16BE
      return false
    end
    `/^[\x00-\x7F]*$/.test(self)`
  end

  def match(pattern, pos = undefined, &block)
    if String === pattern || pattern.respond_to?(:to_str)
      pattern = Regexp.new(pattern.to_str)
    end

    unless Regexp === pattern
      raise TypeError, "wrong argument type #{pattern.class} (expected Regexp)"
    end

    pattern.match(self, pos, &block)
  end

  def match?(pattern, pos = undefined)
    if String === pattern || pattern.respond_to?(:to_str)
      pattern = Regexp.new(pattern.to_str)
    end

    unless Regexp === pattern
      raise TypeError, "wrong argument type #{pattern.class} (expected Regexp)"
    end

    pattern.match?(self, pos)
  end

  def next
    %x{
      var i = self.length;
      if (i === 0) {
        return self.$$cast('');
      }
      var result = self;
      var first_alphanum_char_index = self.search(/[a-zA-Z0-9]/);
      var carry = false;
      var code;
      while (i--) {
        code = self.charCodeAt(i);
        if ((code >= 48 && code <= 57) ||
          (code >= 65 && code <= 90) ||
          (code >= 97 && code <= 122)) {
          switch (code) {
          case 57:
            carry = true;
            code = 48;
            break;
          case 90:
            carry = true;
            code = 65;
            break;
          case 122:
            carry = true;
            code = 97;
            break;
          default:
            carry = false;
            code += 1;
          }
        } else {
          if (first_alphanum_char_index === -1) {
            if (code === 255) {
              carry = true;
              code = 0;
            } else {
              carry = false;
              code += 1;
            }
          } else {
            carry = true;
          }
        }
        result = result.slice(0, i) + String.fromCharCode(code) + result.slice(i + 1);
        if (carry && (i === 0 || i === first_alphanum_char_index)) {
          switch (code) {
          case 65:
            break;
          case 97:
            break;
          default:
            code += 1;
          }
          if (i === 0) {
            result = String.fromCharCode(code) + result;
          } else {
            result = result.slice(0, i) + String.fromCharCode(code) + result.slice(i);
          }
          carry = false;
        }
        if (!carry) {
          break;
        }
      }
      return self.$$cast(result);
    }
  end

  def oct
    %x{
      var result,
          string = self,
          radix = 8;

      if (/^\s*_/.test(string)) {
        return 0;
      }

      string = string.replace(/^(\s*[+-]?)(0[bodx]?)(.+)$/i, function (original, head, flag, tail) {
        switch (tail.charAt(0)) {
        case '+':
        case '-':
          return original;
        case '0':
          if (tail.charAt(1) === 'x' && flag === '0x') {
            return original;
          }
        }
        switch (flag) {
        case '0b':
          radix = 2;
          break;
        case '0':
        case '0o':
          radix = 8;
          break;
        case '0d':
          radix = 10;
          break;
        case '0x':
          radix = 16;
          break;
        }
        return head + tail;
      });

      result = parseInt(string.replace(/_(?!_)/g, ''), radix);
      return isNaN(result) ? 0 : result;
    }
  end

  def ord
    `self.charCodeAt(0)`
  end

  def partition(sep)
    %x{
      var i, m;

      if (sep.$$is_regexp) {
        m = sep.exec(self);
        if (m === null) {
          i = -1;
        } else {
          #{MatchData.new `sep`, `m`};
          sep = m[0];
          i = m.index;
        }
      } else {
        sep = $coerce_to(sep, #{String}, 'to_str');
        i = self.indexOf(sep);
      }

      if (i === -1) {
        return [self, '', ''];
      }

      return [
        self.slice(0, i),
        self.slice(i, i + sep.length),
        self.slice(i + sep.length)
      ];
    }
  end

  def reverse
    `self.split('').reverse().join('')`
  end

  def rindex(search, offset = undefined)
    %x{
      var i, m, r, _m;

      if (offset === undefined) {
        offset = self.length;
      } else {
        offset = $coerce_to(offset, #{Integer}, 'to_int');
        if (offset < 0) {
          offset += self.length;
          if (offset < 0) {
            return nil;
          }
        }
      }

      if (search.$$is_regexp) {
        m = null;
        r = Opal.global_multiline_regexp(search);
        while (true) {
          _m = r.exec(self);
          if (_m === null || _m.index > offset) {
            break;
          }
          m = _m;
          r.lastIndex = m.index + 1;
        }
        if (m === null) {
          #{$~ = nil}
          i = -1;
        } else {
          #{MatchData.new `r`, `m`};
          i = m.index;
        }
      } else {
        search = $coerce_to(search, #{String}, 'to_str');
        i = self.lastIndexOf(search, offset);
      }

      return i === -1 ? nil : i;
    }
  end

  def rjust(width, padstr = ' ')
    width  = `$coerce_to(#{width}, #{Integer}, 'to_int')`
    padstr = `$coerce_to(#{padstr}, #{String}, 'to_str')`.to_s

    if padstr.empty?
      raise ArgumentError, 'zero width padding'
    end

    return self if `width <= self.length`

    %x{
      var chars     = Math.floor(width - self.length),
          patterns  = Math.floor(chars / padstr.length),
          result    = Array(patterns + 1).join(padstr),
          remaining = chars - result.length;

      return self.$$cast(result + padstr.slice(0, remaining) + self);
    }
  end

  def rpartition(sep)
    %x{
      var i, m, r, _m;

      if (sep.$$is_regexp) {
        m = null;
        r = Opal.global_multiline_regexp(sep);

        while (true) {
          _m = r.exec(self);
          if (_m === null) {
            break;
          }
          m = _m;
          r.lastIndex = m.index + 1;
        }

        if (m === null) {
          i = -1;
        } else {
          #{MatchData.new `r`, `m`};
          sep = m[0];
          i = m.index;
        }

      } else {
        sep = $coerce_to(sep, #{String}, 'to_str');
        i = self.lastIndexOf(sep);
      }

      if (i === -1) {
        return ['', '', self];
      }

      return [
        self.slice(0, i),
        self.slice(i, i + sep.length),
        self.slice(i + sep.length)
      ];
    }
  end

  def rstrip
    `self.replace(/[\s\u0000]*$/, '')`
  end

  def scan(pattern, &block)
    %x{
      var result = [],
          match_data = nil,
          match;

      if (pattern.$$is_regexp) {
        pattern = Opal.global_multiline_regexp(pattern);
      } else {
        pattern = $coerce_to(pattern, #{String}, 'to_str');
        pattern = new RegExp(pattern.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gm');
      }

      while ((match = pattern.exec(self)) != null) {
        match_data = #{MatchData.new `pattern`, `match`};
        if (block === nil) {
          match.length == 1 ? result.push(match[0]) : result.push(#{`match_data`.captures});
        } else {
          match.length == 1 ? block(match[0]) : block.call(self, #{`match_data`.captures});
        }
        if (pattern.lastIndex === match.index) {
          pattern.lastIndex += 1;
        }
      }

      #{$~ = `match_data`}

      return (block !== nil ? self : result);
    }
  end

  alias size length

  alias slice []

  def split(pattern = undefined, limit = undefined)
    %x{
      if (self.length === 0) {
        return [];
      }

      if (limit === undefined) {
        limit = 0;
      } else {
        limit = #{Opal.coerce_to!(limit, Integer, :to_int)};
        if (limit === 1) {
          return [self];
        }
      }

      if (pattern === undefined || pattern === nil) {
        pattern = #{$; || ' '};
      }

      var result = [],
          string = self.toString(),
          index = 0,
          match,
          i, ii;

      if (pattern.$$is_regexp) {
        pattern = Opal.global_multiline_regexp(pattern);
      } else {
        pattern = $coerce_to(pattern, #{String}, 'to_str').$to_s();
        if (pattern === ' ') {
          pattern = /\s+/gm;
          string = string.replace(/^\s+/, '');
        } else {
          pattern = new RegExp(pattern.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'gm');
        }
      }

      result = string.split(pattern);

      if (result.length === 1 && result[0] === string) {
        return [self.$$cast(result[0])];
      }

      while ((i = result.indexOf(undefined)) !== -1) {
        result.splice(i, 1);
      }

      function castResult() {
        for (i = 0; i < result.length; i++) {
          result[i] = self.$$cast(result[i]);
        }
      }

      if (limit === 0) {
        while (result[result.length - 1] === '') {
          result.length -= 1;
        }
        castResult();
        return result;
      }

      match = pattern.exec(string);

      if (limit < 0) {
        if (match !== null && match[0] === '' && pattern.source.indexOf('(?=') === -1) {
          for (i = 0, ii = match.length; i < ii; i++) {
            result.push('');
          }
        }
        castResult();
        return result;
      }

      if (match !== null && match[0] === '') {
        result.splice(limit - 1, result.length - 1, result.slice(limit - 1).join(''));
        castResult();
        return result;
      }

      if (limit >= result.length) {
        castResult();
        return result;
      }

      i = 0;
      while (match !== null) {
        i++;
        index = pattern.lastIndex;
        if (i + 1 === limit) {
          break;
        }
        match = pattern.exec(string);
      }
      result.splice(limit - 1, result.length - 1, string.slice(index));
      castResult();
      return result;
    }
  end

  def squeeze(*sets)
    %x{
      if (sets.length === 0) {
        return self.$$cast(self.replace(/(.)\1+/g, '$1'));
      }
      var char_class = char_class_from_char_sets(sets);
      if (char_class === null) {
        return self;
      }
      return self.$$cast(self.replace(new RegExp('(' + char_class + ')\\1+', 'g'), '$1'));
    }
  end

  def start_with?(*prefixes)
    %x{
      for (var i = 0, length = prefixes.length; i < length; i++) {
        if (prefixes[i].$$is_regexp) {
          var prefix = prefixes[i];
          var match = prefix.exec(self);

          if (match != null && match.index === 0) {
            #{$~ = MatchData.new(`prefix`, `match`)};
            return true;
          } else {
            #{$~ = nil}
          }
        } else {
          var prefix = $coerce_to(prefixes[i], #{String}, 'to_str').$to_s();

          if (self.indexOf(prefix) === 0) {
            return true;
          }
        }
      }

      return false;
    }
  end

  def strip
    `self.replace(/^\s*/, '').replace(/[\s\u0000]*$/, '')`
  end

  def sub(pattern, replacement = undefined, &block)
    %x{
      if (!pattern.$$is_regexp) {
        pattern = $coerce_to(pattern, #{String}, 'to_str');
        pattern = new RegExp(pattern.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
      }

      var result, match = pattern.exec(self);

      if (match === null) {
        #{$~ = nil}
        result = self.toString();
      } else {
        #{MatchData.new `pattern`, `match`}

        if (replacement === undefined) {

          if (block === nil) {
            #{raise ArgumentError, 'wrong number of arguments (1 for 2)'}
          }
          result = self.slice(0, match.index) + block(match[0]) + self.slice(match.index + match[0].length);

        } else if (replacement.$$is_hash) {

          result = self.slice(0, match.index) + #{`replacement`[`match[0]`].to_s} + self.slice(match.index + match[0].length);

        } else {

          replacement = $coerce_to(replacement, #{String}, 'to_str');

          replacement = replacement.replace(/([\\]+)([0-9+&`'])/g, function (original, slashes, command) {
            if (slashes.length % 2 === 0) {
              return original;
            }
            switch (command) {
            case "+":
              for (var i = match.length - 1; i > 0; i--) {
                if (match[i] !== undefined) {
                  return slashes.slice(1) + match[i];
                }
              }
              return '';
            case "&": return slashes.slice(1) + match[0];
            case "`": return slashes.slice(1) + self.slice(0, match.index);
            case "'": return slashes.slice(1) + self.slice(match.index + match[0].length);
            default:  return slashes.slice(1) + (match[command] || '');
            }
          }).replace(/\\\\/g, '\\');

          result = self.slice(0, match.index) + replacement + self.slice(match.index + match[0].length);
        }
      }

      return self.$$cast(result);
    }
  end

  alias succ next

  def sum(n = 16)
    %x{
      n = $coerce_to(n, #{Integer}, 'to_int');

      var result = 0,
          length = self.length,
          i = 0;

      for (; i < length; i++) {
        result += self.charCodeAt(i);
      }

      if (n <= 0) {
        return result;
      }

      return result & (Math.pow(2, n) - 1);
    }
  end

  def swapcase
    %x{
      var str = self.replace(/([a-z]+)|([A-Z]+)/g, function($0,$1,$2) {
        return $1 ? $0.toUpperCase() : $0.toLowerCase();
      });

      if (self.constructor === String) {
        return str;
      }

      return #{self.class.new `str`};
    }
  end

  def to_f
    %x{
      if (self.charAt(0) === '_') {
        return 0;
      }

      var result = parseFloat(self.replace(/_/g, ''));

      if (isNaN(result) || result == Infinity || result == -Infinity) {
        return 0;
      }
      else {
        return result;
      }
    }
  end

  def to_i(base = 10)
    %x{
      var result,
          string = self.toLowerCase(),
          radix = $coerce_to(base, #{Integer}, 'to_int');

      if (radix === 1 || radix < 0 || radix > 36) {
        #{raise ArgumentError, "invalid radix #{`radix`}"}
      }

      if (/^\s*_/.test(string)) {
        return 0;
      }

      string = string.replace(/^(\s*[+-]?)(0[bodx]?)(.+)$/, function (original, head, flag, tail) {
        switch (tail.charAt(0)) {
        case '+':
        case '-':
          return original;
        case '0':
          if (tail.charAt(1) === 'x' && flag === '0x' && (radix === 0 || radix === 16)) {
            return original;
          }
        }
        switch (flag) {
        case '0b':
          if (radix === 0 || radix === 2) {
            radix = 2;
            return head + tail;
          }
          break;
        case '0':
        case '0o':
          if (radix === 0 || radix === 8) {
            radix = 8;
            return head + tail;
          }
          break;
        case '0d':
          if (radix === 0 || radix === 10) {
            radix = 10;
            return head + tail;
          }
          break;
        case '0x':
          if (radix === 0 || radix === 16) {
            radix = 16;
            return head + tail;
          }
          break;
        }
        return original
      });

      result = parseInt(string.replace(/_(?!_)/g, ''), radix);
      return isNaN(result) ? 0 : result;
    }
  end

  def to_proc
    method_name = '$' + `self.valueOf()`

    proc do |*args, &block|
      %x{
        if (args.length === 0) {
          #{raise ArgumentError, 'no receiver given'}
        }

        var recv = args[0];

        if (recv == null) recv = nil;

        var body = recv[#{method_name}];

        if (!body) {
          return recv.$method_missing.apply(recv, args);
        }

        if (typeof block === 'function') {
          body.$$p = block;
        }

        if (args.length === 1) {
          return body.call(recv);
        } else {
          return body.apply(recv, args.slice(1));
        }
      }
    end
  end

  def to_s
    `self.toString()`
  end

  alias to_str to_s

  alias to_sym intern

  def tr(from, to)
    %x{
      from = $coerce_to(from, #{String}, 'to_str').$to_s();
      to = $coerce_to(to, #{String}, 'to_str').$to_s();

      if (from.length == 0 || from === to) {
        return self;
      }

      var i, in_range, c, ch, start, end, length;
      var subs = {};
      var from_chars = from.split('');
      var from_length = from_chars.length;
      var to_chars = to.split('');
      var to_length = to_chars.length;

      var inverse = false;
      var global_sub = null;
      if (from_chars[0] === '^' && from_chars.length > 1) {
        inverse = true;
        from_chars.shift();
        global_sub = to_chars[to_length - 1]
        from_length -= 1;
      }

      var from_chars_expanded = [];
      var last_from = null;
      in_range = false;
      for (i = 0; i < from_length; i++) {
        ch = from_chars[i];
        if (last_from == null) {
          last_from = ch;
          from_chars_expanded.push(ch);
        }
        else if (ch === '-') {
          if (last_from === '-') {
            from_chars_expanded.push('-');
            from_chars_expanded.push('-');
          }
          else if (i == from_length - 1) {
            from_chars_expanded.push('-');
          }
          else {
            in_range = true;
          }
        }
        else if (in_range) {
          start = last_from.charCodeAt(0);
          end = ch.charCodeAt(0);
          if (start > end) {
            #{raise ArgumentError, "invalid range \"#{`String.fromCharCode(start)`}-#{`String.fromCharCode(end)`}\" in string transliteration"}
          }
          for (c = start + 1; c < end; c++) {
            from_chars_expanded.push(String.fromCharCode(c));
          }
          from_chars_expanded.push(ch);
          in_range = null;
          last_from = null;
        }
        else {
          from_chars_expanded.push(ch);
        }
      }

      from_chars = from_chars_expanded;
      from_length = from_chars.length;

      if (inverse) {
        for (i = 0; i < from_length; i++) {
          subs[from_chars[i]] = true;
        }
      }
      else {
        if (to_length > 0) {
          var to_chars_expanded = [];
          var last_to = null;
          in_range = false;
          for (i = 0; i < to_length; i++) {
            ch = to_chars[i];
            if (last_to == null) {
              last_to = ch;
              to_chars_expanded.push(ch);
            }
            else if (ch === '-') {
              if (last_to === '-') {
                to_chars_expanded.push('-');
                to_chars_expanded.push('-');
              }
              else if (i == to_length - 1) {
                to_chars_expanded.push('-');
              }
              else {
                in_range = true;
              }
            }
            else if (in_range) {
              start = last_to.charCodeAt(0);
              end = ch.charCodeAt(0);
              if (start > end) {
                #{raise ArgumentError, "invalid range \"#{`String.fromCharCode(start)`}-#{`String.fromCharCode(end)`}\" in string transliteration"}
              }
              for (c = start + 1; c < end; c++) {
                to_chars_expanded.push(String.fromCharCode(c));
              }
              to_chars_expanded.push(ch);
              in_range = null;
              last_to = null;
            }
            else {
              to_chars_expanded.push(ch);
            }
          }

          to_chars = to_chars_expanded;
          to_length = to_chars.length;
        }

        var length_diff = from_length - to_length;
        if (length_diff > 0) {
          var pad_char = (to_length > 0 ? to_chars[to_length - 1] : '');
          for (i = 0; i < length_diff; i++) {
            to_chars.push(pad_char);
          }
        }

        for (i = 0; i < from_length; i++) {
          subs[from_chars[i]] = to_chars[i];
        }
      }

      var new_str = ''
      for (i = 0, length = self.length; i < length; i++) {
        ch = self.charAt(i);
        var sub = subs[ch];
        if (inverse) {
          new_str += (sub == null ? global_sub : ch);
        }
        else {
          new_str += (sub != null ? sub : ch);
        }
      }
      return self.$$cast(new_str);
    }
  end

  def tr_s(from, to)
    %x{
      from = $coerce_to(from, #{String}, 'to_str').$to_s();
      to = $coerce_to(to, #{String}, 'to_str').$to_s();

      if (from.length == 0) {
        return self;
      }

      var i, in_range, c, ch, start, end, length;
      var subs = {};
      var from_chars = from.split('');
      var from_length = from_chars.length;
      var to_chars = to.split('');
      var to_length = to_chars.length;

      var inverse = false;
      var global_sub = null;
      if (from_chars[0] === '^' && from_chars.length > 1) {
        inverse = true;
        from_chars.shift();
        global_sub = to_chars[to_length - 1]
        from_length -= 1;
      }

      var from_chars_expanded = [];
      var last_from = null;
      in_range = false;
      for (i = 0; i < from_length; i++) {
        ch = from_chars[i];
        if (last_from == null) {
          last_from = ch;
          from_chars_expanded.push(ch);
        }
        else if (ch === '-') {
          if (last_from === '-') {
            from_chars_expanded.push('-');
            from_chars_expanded.push('-');
          }
          else if (i == from_length - 1) {
            from_chars_expanded.push('-');
          }
          else {
            in_range = true;
          }
        }
        else if (in_range) {
          start = last_from.charCodeAt(0);
          end = ch.charCodeAt(0);
          if (start > end) {
            #{raise ArgumentError, "invalid range \"#{`String.fromCharCode(start)`}-#{`String.fromCharCode(end)`}\" in string transliteration"}
          }
          for (c = start + 1; c < end; c++) {
            from_chars_expanded.push(String.fromCharCode(c));
          }
          from_chars_expanded.push(ch);
          in_range = null;
          last_from = null;
        }
        else {
          from_chars_expanded.push(ch);
        }
      }

      from_chars = from_chars_expanded;
      from_length = from_chars.length;

      if (inverse) {
        for (i = 0; i < from_length; i++) {
          subs[from_chars[i]] = true;
        }
      }
      else {
        if (to_length > 0) {
          var to_chars_expanded = [];
          var last_to = null;
          in_range = false;
          for (i = 0; i < to_length; i++) {
            ch = to_chars[i];
            if (last_from == null) {
              last_from = ch;
              to_chars_expanded.push(ch);
            }
            else if (ch === '-') {
              if (last_to === '-') {
                to_chars_expanded.push('-');
                to_chars_expanded.push('-');
              }
              else if (i == to_length - 1) {
                to_chars_expanded.push('-');
              }
              else {
                in_range = true;
              }
            }
            else if (in_range) {
              start = last_from.charCodeAt(0);
              end = ch.charCodeAt(0);
              if (start > end) {
                #{raise ArgumentError, "invalid range \"#{`String.fromCharCode(start)`}-#{`String.fromCharCode(end)`}\" in string transliteration"}
              }
              for (c = start + 1; c < end; c++) {
                to_chars_expanded.push(String.fromCharCode(c));
              }
              to_chars_expanded.push(ch);
              in_range = null;
              last_from = null;
            }
            else {
              to_chars_expanded.push(ch);
            }
          }

          to_chars = to_chars_expanded;
          to_length = to_chars.length;
        }

        var length_diff = from_length - to_length;
        if (length_diff > 0) {
          var pad_char = (to_length > 0 ? to_chars[to_length - 1] : '');
          for (i = 0; i < length_diff; i++) {
            to_chars.push(pad_char);
          }
        }

        for (i = 0; i < from_length; i++) {
          subs[from_chars[i]] = to_chars[i];
        }
      }
      var new_str = ''
      var last_substitute = null
      for (i = 0, length = self.length; i < length; i++) {
        ch = self.charAt(i);
        var sub = subs[ch]
        if (inverse) {
          if (sub == null) {
            if (last_substitute == null) {
              new_str += global_sub;
              last_substitute = true;
            }
          }
          else {
            new_str += ch;
            last_substitute = null;
          }
        }
        else {
          if (sub != null) {
            if (last_substitute == null || last_substitute !== sub) {
              new_str += sub;
              last_substitute = sub;
            }
          }
          else {
            new_str += ch;
            last_substitute = null;
          }
        }
      }
      return self.$$cast(new_str);
    }
  end

  def upcase
    `self.$$cast(self.toUpperCase())`
  end

  def upto(stop, excl = false, &block)
    return enum_for :upto, stop, excl unless block_given?
    %x{
      var a, b, s = self.toString();

      stop = $coerce_to(stop, #{String}, 'to_str');

      if (s.length === 1 && stop.length === 1) {

        a = s.charCodeAt(0);
        b = stop.charCodeAt(0);

        while (a <= b) {
          if (excl && a === b) {
            break;
          }

          block(String.fromCharCode(a));

          a += 1;
        }

      } else if (parseInt(s, 10).toString() === s && parseInt(stop, 10).toString() === stop) {

        a = parseInt(s, 10);
        b = parseInt(stop, 10);

        while (a <= b) {
          if (excl && a === b) {
            break;
          }

          block(a.toString());

          a += 1;
        }

      } else {

        while (s.length <= stop.length && s <= stop) {
          if (excl && s === stop) {
            break;
          }

          block(s);

          s = #{`s`.succ};
        }

      }
      return self;
    }
  end

  %x{
    function char_class_from_char_sets(sets) {
      function explode_sequences_in_character_set(set) {
        var result = '',
            i, len = set.length,
            curr_char,
            skip_next_dash,
            char_code_from,
            char_code_upto,
            char_code;
        for (i = 0; i < len; i++) {
          curr_char = set.charAt(i);
          if (curr_char === '-' && i > 0 && i < (len - 1) && !skip_next_dash) {
            char_code_from = set.charCodeAt(i - 1);
            char_code_upto = set.charCodeAt(i + 1);
            if (char_code_from > char_code_upto) {
              #{raise ArgumentError, "invalid range \"#{`char_code_from`}-#{`char_code_upto`}\" in string transliteration"}
            }
            for (char_code = char_code_from + 1; char_code < char_code_upto + 1; char_code++) {
              result += String.fromCharCode(char_code);
            }
            skip_next_dash = true;
            i++;
          } else {
            skip_next_dash = (curr_char === '\\');
            result += curr_char;
          }
        }
        return result;
      }

      function intersection(setA, setB) {
        if (setA.length === 0) {
          return setB;
        }
        var result = '',
            i, len = setA.length,
            chr;
        for (i = 0; i < len; i++) {
          chr = setA.charAt(i);
          if (setB.indexOf(chr) !== -1) {
            result += chr;
          }
        }
        return result;
      }

      var i, len, set, neg, chr, tmp,
          pos_intersection = '',
          neg_intersection = '';

      for (i = 0, len = sets.length; i < len; i++) {
        set = $coerce_to(sets[i], #{String}, 'to_str');
        neg = (set.charAt(0) === '^' && set.length > 1);
        set = explode_sequences_in_character_set(neg ? set.slice(1) : set);
        if (neg) {
          neg_intersection = intersection(neg_intersection, set);
        } else {
          pos_intersection = intersection(pos_intersection, set);
        }
      }

      if (pos_intersection.length > 0 && neg_intersection.length > 0) {
        tmp = '';
        for (i = 0, len = pos_intersection.length; i < len; i++) {
          chr = pos_intersection.charAt(i);
          if (neg_intersection.indexOf(chr) === -1) {
            tmp += chr;
          }
        }
        pos_intersection = tmp;
        neg_intersection = '';
      }

      if (pos_intersection.length > 0) {
        return '[' + #{Regexp.escape(`pos_intersection`)} + ']';
      }

      if (neg_intersection.length > 0) {
        return '[^' + #{Regexp.escape(`neg_intersection`)} + ']';
      }

      return null;
    }
  }

  def instance_variables
    []
  end

  def self._load(*args)
    new(*args)
  end

  def unicode_normalize(form = :nfc)
    raise ArgumentError, "Invalid normalization form #{form}" unless %i[nfc nfd nfkc nfkd].include?(form)
    `self.normalize(#{form.upcase})`
  end

  def unicode_normalized?(form = :nfc)
    unicode_normalize(form) == self
  end

  def unpack(format)
    raise "To use String#unpack, you must first require 'corelib/string/unpack'."
  end

  def unpack1(format)
    raise "To use String#unpack1, you must first require 'corelib/string/unpack'."
  end
end

Symbol = String
