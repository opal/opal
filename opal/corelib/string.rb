require 'corelib/comparable'

class String
  include Comparable

  `def.$$is_string = true`

  def self.try_convert(what)
    what.to_str
  rescue
    nil
  end

  def self.new(str = '')
    `new String(str)`
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
      if (count < 1) {
        return '';
      }

      var result  = '',
          pattern = self;

      while (count > 0) {
        if (count & 1) {
          result += pattern;
        }

        count >>= 1;
        pattern += pattern;
      }

      return result;
    }
  end

  def +(other)
    other = Opal.coerce_to other, String, :to_str

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

  def <<(other)
    raise NotImplementedError, '#<< not supported. Mutable String methods are not supported in Opal.'
  end

  def ==(other)
    return false unless String === other

    `#{to_s} == #{other.to_s}`
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
      var size = self.length;

      if (index.$$is_range) {
        var exclude = index.exclude,
            length  = #{Opal.coerce_to(`index.end`, Integer, :to_int)},
            index   = #{Opal.coerce_to(`index.begin`, Integer, :to_int)};

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

        return self.substr(index, length);
      }


      if (index.$$is_string) {
        if (length != null) {
          #{raise TypeError}
        }
        return self.indexOf(index) !== -1 ? index : nil;
      }


      if (index.$$is_regexp) {
        var match = self.match(index);

        if (match === null) {
          #{$~ = nil}
          return nil;
        }

        #{$~ = MatchData.new(`index`, `match`)}

        if (length == null) {
          return match[0];
        }

        length = #{Opal.coerce_to(`length`, Integer, :to_int)};

        if (length < 0 && -length < match.length) {
          return match[length += match.length];
        }

        if (length >= 0 && length < match.length) {
          return match[length];
        }

        return nil;
      }


      index = #{Opal.coerce_to(`index`, Integer, :to_int)};

      if (index < 0) {
        index += size;
      }

      if (length == null) {
        if (index >= size || index < 0) {
          return nil;
        }
        return self.substr(index, 1);
      }

      length = #{Opal.coerce_to(`length`, Integer, :to_int)};

      if (length < 0) {
        return nil;
      }

      if (index > size || index < 0) {
        return nil;
      }

      return self.substr(index, length);
    }
  end

  def capitalize
    `self.charAt(0).toUpperCase() + self.substr(1).toLowerCase()`
  end

  alias capitalize! <<

  def casecmp(other)
    other = Opal.coerce_to(other, String, :to_str).to_s

    `self.toLowerCase()` <=> `other.toLowerCase()`
  end

  def center(width, padstr = ' ')
    width  = Opal.coerce_to(width, Integer, :to_int)
    padstr = Opal.coerce_to(padstr, String, :to_str).to_s

    if padstr.empty?
      raise ArgumentError, 'zero width padding'
    end

    return self if `width <= self.length`

    %x{
      var ljustified = #{ljust ((width + @length) / 2).ceil, padstr},
          rjustified = #{rjust ((width + @length) / 2).floor, padstr};

      return rjustified + ljustified.slice(self.length);
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
      if (separator === "\n") {
        return self.replace(/\r?\n?$/, '');
      }
      else if (separator === "") {
        return self.replace(/(\r?\n)+$/, '');
      }
      else if (self.length > separator.length) {
        var tail = self.substr(self.length - separator.length, separator.length);

        if (tail === separator) {
          return self.substr(0, self.length - separator.length);
        }
      }
    }

    self
  end

  alias chomp! <<

  def chop
    %x{
      var length = self.length;

      if (length <= 1) {
        return "";
      }

      if (self.charAt(length - 1) === "\n" && self.charAt(length - 2) === "\r") {
        return self.substr(0, length - 2);
      }
      else {
        return self.substr(0, length - 1);
      }
    }
  end

  alias chop! <<

  def chr
    `self.charAt(0)`
  end

  def clone
    copy = `self.slice()`
    copy.initialize_clone(self)
    copy
  end

  def dup
    copy = `self.slice()`
    copy.initialize_dup(self)
    copy
  end

  def count(str)
    `(self.length - self.replace(new RegExp(str, 'g'), '').length) / str.length`
  end

  alias dup clone

  def downcase
    `self.toLowerCase()`
  end

  alias downcase! <<

  def each_char(&block)
    return enum_for :each_char unless block_given?

    %x{
      for (var i = 0, length = self.length; i < length; i++) {
        #{yield `self.charAt(i)`};
      }
    }

    self
  end

  def each_line(separator = $/)
    return split(separator) unless block_given?

    %x{
      var chomped  = #{chomp},
          trailing = self.length != chomped.length,
          splitted = chomped.split(separator);

      for (var i = 0, length = splitted.length; i < length; i++) {
        if (i < length - 1 || trailing) {
          #{yield `splitted[i] + separator`};
        }
        else {
          #{yield `splitted[i]`};
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
        var suffix = #{Opal.coerce_to(`suffixes[i]`, String, :to_str).to_s};

        if (self.length >= suffix.length &&
            self.substr(self.length - suffix.length, suffix.length) == suffix) {
          return true;
        }
      }
    }

    false
  end

  alias eql? ==
  alias equal? ===

  def gsub(pattern, replace = undefined, &block)
    if String === pattern || pattern.respond_to?(:to_str)
      pattern = /#{Regexp.escape(pattern.to_str)}/
    end

    unless Regexp === pattern
      raise TypeError, "wrong argument type #{pattern.class} (expected Regexp)"
    end

    %x{
      var pattern = pattern.toString(),
          options = pattern.substr(pattern.lastIndexOf('/') + 1) + 'g',
          regexp  = pattern.substr(1, pattern.lastIndexOf('/') - 1);

      self.$sub.$$p = block;
      return self.$sub(new RegExp(regexp, options), replace);
    }
  end

  alias gsub! <<

  def hash
    `self.toString()`
  end

  def hex
    to_i 16
  end

  def include?(other)
    %x{
      if (other.$$is_string) {
        return self.indexOf(other) !== -1;
      }
    }

    unless other.respond_to? :to_str
      raise TypeError, "no implicit conversion of #{other.class} into String"
    end

    `self.indexOf(#{other.to_str}) !== -1`
  end

  def index(what, offset = nil)
    if String === what
      what = what.to_s
    elsif what.respond_to? :to_str
      what = what.to_str.to_s
    elsif not Regexp === what
      raise TypeError, "type mismatch: #{what.class} given"
    end

    result = -1

    if offset
      offset = Opal.coerce_to offset, Integer, :to_int

      %x{
        var size = self.length;

        if (offset < 0) {
          offset = offset + size;
        }

        if (offset > size) {
          return nil;
        }
      }

      if Regexp === what
        result = (what =~ `self.substr(offset)`) || -1
      else
        result = `self.substr(offset).indexOf(what)`
      end

      %x{
        if (result !== -1) {
          result += offset;
        }
      }
    else
      if Regexp === what
        result = (what =~ self) || -1
      else
        result = `self.indexOf(what)`
      end
    end

    unless `result === -1`
      result
    end
  end

  def inspect
    %x{
      var escapable = /[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,
          meta      = {
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
          };

      escapable.lastIndex = 0;

      return escapable.test(self) ? '"' + self.replace(escapable, function(a) {
        var c = meta[a];

        return typeof c === 'string' ? c :
          '\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
      }) + '"' : '"' + self + '"';
    }
  end

  def intern
    self
  end

  def lines(separator = $/)
    each_line(separator).to_a
  end

  def length
    `self.length`
  end

  def ljust(width, padstr = ' ')
    width  = Opal.coerce_to(width, Integer, :to_int)
    padstr = Opal.coerce_to(padstr, String, :to_str).to_s

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

      return self + result.slice(0, width);
    }
  end

  def lstrip
    `self.replace(/^\s*/, '')`
  end

  alias lstrip! <<

  def match(pattern, pos = undefined, &block)
    if String === pattern || pattern.respond_to?(:to_str)
      pattern = Regexp.new(pattern.to_str)
    end

    unless Regexp === pattern
      raise TypeError, "wrong argument type #{pattern.class} (expected Regexp)"
    end

    pattern.match(self, pos, &block)
  end

  def next
    %x{
      var i = self.length;
      if (i === 0) {
        return '';
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
      return result;
    }
  end

  alias next! <<

  def ord
    `self.charCodeAt(0)`
  end

  def partition(str)
    %x{
      var result = self.split(str);
      var splitter = (result[0].length === self.length ? "" : str);

      return [result[0], splitter, result.slice(1).join(str.toString())];
    }
  end

  def reverse
    `self.split('').reverse().join('')`
  end

  alias reverse! <<

  # TODO handle case where search is regexp
  def rindex(search, offset = undefined)
    %x{
      var search_type = (search == null ? Opal.NilClass : search.constructor);
      if (search_type != String && search_type != RegExp) {
        var msg = "type mismatch: " + search_type + " given";
        #{raise TypeError.new(`msg`)};
      }

      if (self.length == 0) {
        return search.length == 0 ? 0 : nil;
      }

      var result = -1;
      if (offset != null) {
        if (offset < 0) {
          offset = self.length + offset;
        }

        if (search_type == String) {
          result = self.lastIndexOf(search, offset);
        }
        else {
          result = self.substr(0, offset + 1).$reverse().search(search);
          if (result !== -1) {
            result = offset - result;
          }
        }
      }
      else {
        if (search_type == String) {
          result = self.lastIndexOf(search);
        }
        else {
          result = self.$reverse().search(search);
          if (result !== -1) {
            result = self.length - 1 - result;
          }
        }
      }

      return result === -1 ? nil : result;
    }
  end

  def rjust(width, padstr = ' ')
    width  = Opal.coerce_to(width, Integer, :to_int)
    padstr = Opal.coerce_to(padstr, String, :to_str).to_s

    if padstr.empty?
      raise ArgumentError, 'zero width padding'
    end

    return self if `width <= self.length`

    %x{
      var chars     = Math.floor(width - self.length),
          patterns  = Math.floor(chars / padstr.length),
          result    = Array(patterns + 1).join(padstr),
          remaining = chars - result.length;

      return result + padstr.slice(0, remaining) + self;
    }
  end

  def rstrip
    `self.replace(/\s*$/, '')`
  end

  def scan(pattern, &block)
    %x{
      if (pattern.global) {
        // should we clear it afterwards too?
        pattern.lastIndex = 0;
      }
      else {
        // rewrite regular expression to add the global flag to capture pre/post match
        pattern = new RegExp(pattern.source, 'g' + (pattern.multiline ? 'm' : '') + (pattern.ignoreCase ? 'i' : ''));
      }

      var result = [];
      var match;

      while ((match = pattern.exec(self)) != null) {
        var match_data = #{MatchData.new `pattern`, `match`};
        if (block === nil) {
          match.length == 1 ? result.push(match[0]) : result.push(match.slice(1));
        }
        else {
          match.length == 1 ? block(match[0]) : block.apply(self, match.slice(1));
        }
      }

      return (block !== nil ? self : result);
    }
  end

  alias size length

  alias slice []
  alias slice! <<

  def split(pattern = $; || ' ', limit = undefined)
    %x{
      if (pattern === nil || pattern === undefined) {
        pattern = #{$;};
      }

      var result = [];
      if (limit !== undefined) {
        limit = #{Opal.coerce_to!(limit, Integer, :to_int)};
      }

      if (self.length === 0) {
        return [];
      }

      if (limit === 1) {
        return [self];
      }

      if (pattern && pattern.$$is_regexp) {
        var pattern_str = pattern.toString();

        /* Opal and JS's repr of an empty RE. */
        var blank_pattern = (pattern_str.substr(0, 3) == '/^/') ||
                  (pattern_str.substr(0, 6) == '/(?:)/');

        /* This is our fast path */
        if (limit === undefined || limit === 0) {
          result = self.split(blank_pattern ? /(?:)/ : pattern);
        }
        else {
          /* RegExp.exec only has sane behavior with global flag */
          if (! pattern.global) {
            pattern = eval(pattern_str + 'g');
          }

          var match_data;
          var prev_index = 0;
          pattern.lastIndex = 0;

          while ((match_data = pattern.exec(self)) !== null) {
            var segment = self.slice(prev_index, match_data.index);
            result.push(segment);

            prev_index = pattern.lastIndex;

            if (match_data[0].length === 0) {
              if (blank_pattern) {
                /* explicitly split on JS's empty RE form.*/
                pattern = /(?:)/;
              }

              result = self.split(pattern);
              /* with "unlimited", ruby leaves a trail on blanks. */
              if (limit !== undefined && limit < 0 && blank_pattern) {
                result.push('');
              }

              prev_index = undefined;
              break;
            }

            if (limit !== undefined && limit > 1 && result.length + 1 == limit) {
              break;
            }
          }

          if (prev_index !== undefined) {
            result.push(self.slice(prev_index, self.length));
          }
        }
      }
      else {
        var splitted = 0, start = 0, lim = 0;

        if (pattern === nil || pattern === undefined) {
          pattern = ' '
        } else {
          pattern = #{Opal.try_convert(pattern, String, :to_str).to_s};
        }

        var string = (pattern == ' ') ? self.replace(/[\r\n\t\v]\s+/g, ' ')
                                      : self;
        var cursor = -1;
        while ((cursor = string.indexOf(pattern, start)) > -1 && cursor < string.length) {
          if (splitted + 1 === limit) {
            break;
          }

          if (pattern == ' ' && cursor == start) {
            start = cursor + 1;
            continue;
          }

          result.push(string.substr(start, pattern.length ? cursor - start : 1));
          splitted++;

          start = cursor + (pattern.length ? pattern.length : 1);
        }

        if (string.length > 0 && (limit < 0 || string.length > start)) {
          if (string.length == start) {
            result.push('');
          }
          else {
            result.push(string.substr(start, string.length));
          }
        }
      }

      if (limit === undefined || limit === 0) {
        while (result[result.length-1] === '') {
          result.length = result.length - 1;
        }
      }

      if (limit > 0) {
        var tail = result.slice(limit - 1).join('');
        result.splice(limit - 1, result.length - 1, tail);
      }

      return result;
    }
  end

  def squeeze(*sets)
    %x{
      if (sets.length === 0) {
        return self.replace(/(.)\1+/g, '$1');
      }
    }

    %x{
      var set = #{Opal.coerce_to(`sets[0]`, String, :to_str).chars};

      for (var i = 1, length = sets.length; i < length; i++) {
        set = #{`set` & Opal.coerce_to(`sets[i]`, String, :to_str).chars};
      }

      if (set.length === 0) {
        return self;
      }

      return self.replace(new RegExp("([" + #{Regexp.escape(`set`.join)} + "])\\1+", "g"), "$1");
    }
  end

  alias squeeze! <<

  def start_with?(*prefixes)
    %x{
      for (var i = 0, length = prefixes.length; i < length; i++) {
        var prefix = #{Opal.coerce_to(`prefixes[i]`, String, :to_str).to_s};

        if (self.indexOf(prefix) === 0) {
          return true;
        }
      }

      return false;
    }
  end

  def strip
    `self.replace(/^\s*/, '').replace(/\s*$/, '')`
  end

  alias strip! <<

  %x{
    // convert Ruby back reference to JavaScript back reference
    function convertReplace(replace) {
      return replace.replace(
        /(^|[^\\])\\(\d)/g, function(a, b, c) { return b + '$' + c }
      ).replace(
        /(^|[^\\])(\\\\)+\\\\(\d)/g, '$1$2\\$3'
      ).replace(
        /(^|[^\\])(?:(\\)\\)+([^\\]|$)/g, '$1$2$3'
      );
    }
  }

  def sub(pattern, replace = undefined, &block)
    %x{
      if (typeof(pattern) !== 'string' && !pattern.$$is_regexp) {
        pattern = #{Opal.coerce_to! pattern, String, :to_str};
      }

      if (replace !== undefined) {
        if (#{replace.is_a?(Hash)}) {
          return self.replace(pattern, function(str) {
            var value = #{replace[str]};

            return (value == null) ? nil : #{value.to_s};
          });
        }
        else {
          if (typeof(replace) !== 'string') {
            replace = #{Opal.coerce_to! replace, String, :to_str};
          }

          replace = convertReplace(replace);
          return self.replace(pattern, replace);
        }

      }
      else if (block != null && block !== nil) {
        return self.replace(pattern, function() {
          // FIXME: this should be a formal MatchData object with all the goodies
          var match_data = []
          for (var i = 0, len = arguments.length; i < len; i++) {
            var arg = arguments[i];
            if (arg == undefined) {
              match_data.push(nil);
            }
            else {
              match_data.push(arg);
            }
          }

          var str = match_data.pop();
          var offset = match_data.pop();
          var match_len = match_data.length;

          // $1, $2, $3 not being parsed correctly in Ruby code
          for (var i = 1; i < match_len; i++) {
            Opal.gvars[String(i)] = match_data[i];
          }
          #{$& = `match_data[0]`};
          #{$~ = `match_data`};
          return block(match_data[0]);
        });
      }
      else {
        #{raise ArgumentError, 'wrong number of arguments (1 for 2)'}
      }
    }
  end

  alias sub! <<

  alias succ next
  alias succ! <<

  def sum(n = 16)
    %x{
      var result = 0;

      for (var i = 0, length = self.length; i < length; i++) {
        result += (self.charCodeAt(i) % ((1 << n) - 1));
      }

      return result;
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

  alias swapcase! <<

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
      var result = parseInt(self, base);

      if (isNaN(result)) {
        return 0;
      }

      return result;
    }
  end

  def to_proc
    # Give name to self in case this proc is passed to instance_eval
    sym = self

    proc do |*args, &block|
      raise ArgumentError, "no receiver given" if args.empty?
      obj = args.shift
      obj.__send__(sym, *args, &block)
    end
  end

  def to_s
    `self.toString()`
  end

  alias to_str to_s

  alias to_sym intern

  def tr(from, to)
    %x{
      if (from.length == 0 || from === to) {
        return self;
      }

      var subs = {};
      var from_chars = from.split('');
      var from_length = from_chars.length;
      var to_chars = to.split('');
      var to_length = to_chars.length;

      var inverse = false;
      var global_sub = null;
      if (from_chars[0] === '^') {
        inverse = true;
        from_chars.shift();
        global_sub = to_chars[to_length - 1]
        from_length -= 1;
      }

      var from_chars_expanded = [];
      var last_from = null;
      var in_range = false;
      for (var i = 0; i < from_length; i++) {
        var ch = from_chars[i];
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
          var start = last_from.charCodeAt(0) + 1;
          var end = ch.charCodeAt(0);
          for (var c = start; c < end; c++) {
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
        for (var i = 0; i < from_length; i++) {
          subs[from_chars[i]] = true;
        }
      }
      else {
        if (to_length > 0) {
          var to_chars_expanded = [];
          var last_to = null;
          var in_range = false;
          for (var i = 0; i < to_length; i++) {
            var ch = to_chars[i];
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
              var start = last_from.charCodeAt(0) + 1;
              var end = ch.charCodeAt(0);
              for (var c = start; c < end; c++) {
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
          for (var i = 0; i < length_diff; i++) {
            to_chars.push(pad_char);
          }
        }

        for (var i = 0; i < from_length; i++) {
          subs[from_chars[i]] = to_chars[i];
        }
      }

      var new_str = ''
      for (var i = 0, length = self.length; i < length; i++) {
        var ch = self.charAt(i);
        var sub = subs[ch];
        if (inverse) {
          new_str += (sub == null ? global_sub : ch);
        }
        else {
          new_str += (sub != null ? sub : ch);
        }
      }
      return new_str;
    }
  end

  alias tr! <<

  def tr_s(from, to)
    %x{
      if (from.length == 0) {
        return self;
      }

      var subs = {};
      var from_chars = from.split('');
      var from_length = from_chars.length;
      var to_chars = to.split('');
      var to_length = to_chars.length;

      var inverse = false;
      var global_sub = null;
      if (from_chars[0] === '^') {
        inverse = true;
        from_chars.shift();
        global_sub = to_chars[to_length - 1]
        from_length -= 1;
      }

      var from_chars_expanded = [];
      var last_from = null;
      var in_range = false;
      for (var i = 0; i < from_length; i++) {
        var ch = from_chars[i];
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
          var start = last_from.charCodeAt(0) + 1;
          var end = ch.charCodeAt(0);
          for (var c = start; c < end; c++) {
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
        for (var i = 0; i < from_length; i++) {
          subs[from_chars[i]] = true;
        }
      }
      else {
        if (to_length > 0) {
          var to_chars_expanded = [];
          var last_to = null;
          var in_range = false;
          for (var i = 0; i < to_length; i++) {
            var ch = to_chars[i];
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
              var start = last_from.charCodeAt(0) + 1;
              var end = ch.charCodeAt(0);
              for (var c = start; c < end; c++) {
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
          for (var i = 0; i < length_diff; i++) {
            to_chars.push(pad_char);
          }
        }

        for (var i = 0; i < from_length; i++) {
          subs[from_chars[i]] = to_chars[i];
        }
      }
      var new_str = ''
      var last_substitute = null
      for (var i = 0, length = self.length; i < length; i++) {
        var ch = self.charAt(i);
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
      return new_str;
    }
  end

  alias tr_s! <<

  def upcase
    `self.toUpperCase()`
  end

  alias upcase! <<

  def freeze
    self
  end

  def frozen?
    true
  end
end

Symbol = String
