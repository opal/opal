class String < `String`
  include Comparable

  `def._isString = true`

  def self.try_convert(what)
    what.to_str
  rescue
    nil
  end

  def self.new(str = '')
    %x{
      return new String(str)
    }
  end

  def %(data)
    if data.is_a?(Array)
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
    `other == String(#{self})`
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

  def [](index, length = undefined)
    %x{
      var size = #{self}.length;

      if (index._isRange) {
        var exclude = index.exclude,
            length  = index.end,
            index   = index.begin;

        if (index < 0) {
          index += size;
        }

        if (length < 0) {
          length += size;
        }

        if (!exclude) {
          length += 1;
        }

        if (index > size) {
          return nil;
        }

        length = length - index;

        if (length < 0) {
          length = 0;
        }

        return #{self}.substr(index, length);
      }

      if (index < 0) {
        index += #{self}.length;
      }

      if (length == null) {
        if (index >= #{self}.length || index < 0) {
          return nil;
        }

        return #{self}.substr(index, 1);
      }

      if (index > #{self}.length || index < 0) {
        return nil;
      }

      return #{self}.substr(index, length);
    }
  end

  def as_json
    self
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

  def clone
    `#{self}.slice()`
  end

  def count(str)
    `(#{self}.length - #{self}.replace(new RegExp(str,"g"), '').length) / str.length`
  end

  def dasherize
    `#{self}.replace(/[-\\s]+/g, '-')
                .replace(/([A-Z\\d]+)([A-Z][a-z])/g, '$1-$2')
                .replace(/([a-z\\d])([A-Z])/g, '$1-$2')
                .toLowerCase()`
  end

  def demodulize
    %x{
      var idx = #{self}.lastIndexOf('::');

      if (idx > -1) {
        return #{self}.substr(idx + 2);
      }
      
      return #{self};
    }
  end

  alias dup clone

  alias_native :downcase, :toLowerCase

  alias each_char chars

  def each_line (separator = $/)
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

  alias_native :getbyte, :charCodeAt

  def gsub(pattern, replace = undefined, &block)
    if pattern.is_a?(String)
      pattern = /#{Regexp.escape(pattern)}/
    end

    %x{
      var pattern = pattern.toString(),
          options = pattern.substr(pattern.lastIndexOf('/') + 1) + 'g',
          regexp  = pattern.substr(1, pattern.lastIndexOf('/') - 1);

      #{self}.$sub._p = block;
      return #{self}.$sub(new RegExp(regexp, options), replace);
    }
  end

  alias_native :hash, :toString

  def hex
    to_i 16
  end

  def include?(other)
    `#{self}.indexOf(other) !== -1`
  end

  def index(what, offset)
    %x{
      if (!what._isString && !what._isRegexp) {
        throw new Error('type mismatch');
      }

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

  def match(pattern, pos = undefined, &block)
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

  def sub(pattern, replace = undefined, &block)
    %x{
      if (typeof(replace) === 'string') {
        return #{self}.replace(pattern, replace);
      }
      if (block !== nil) {
        return #{self}.replace(pattern, function(str, a) {
          #{ $1 = `a` };
          return block(str);
        });
      }
      else if (replace !== undefined) {
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

      if (#{self}._klass === String) {
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
      var name = '$' + #{self};

      return function(arg) {
        var meth = arg[name];
        return meth ? meth.call(arg) : arg.$method_missing(name);
      };
    }
  end

  alias_native :to_s, :toString

  alias to_str to_s

  alias to_sym intern

  def tr(from, to)
    %x{
      if (from.length == 0 || from === to) {
        return #{self};
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
        var char = from_chars[i];
        if (last_from == null) {
          last_from = char;
          from_chars_expanded.push(char);
        }
        else if (char === '-') {
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
          var end = char.charCodeAt(0);
          for (var c = start; c < end; c++) {
            from_chars_expanded.push(String.fromCharCode(c));
          }
          from_chars_expanded.push(char);
          in_range = null;
          last_from = null;
        }
        else {
          from_chars_expanded.push(char);
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
            var char = to_chars[i];
            if (last_from == null) {
              last_from = char;
              to_chars_expanded.push(char);
            }
            else if (char === '-') {
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
              var end = char.charCodeAt(0);
              for (var c = start; c < end; c++) {
                to_chars_expanded.push(String.fromCharCode(c));
              }
              to_chars_expanded.push(char);
              in_range = null;
              last_from = null;
            }
            else {
              to_chars_expanded.push(char);
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
      for (var i = 0, length = #{self}.length; i < length; i++) {
        var char = #{self}.charAt(i);
        var sub = subs[char];
        if (inverse) {
          new_str += (sub == null ? global_sub : char);
        }
        else {
          new_str += (sub != null ? sub : char);
        }
      }
      return new_str;
    }
  end

  def tr_s(from, to)
    %x{
      if (from.length == 0) {
        return #{self};
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
        var char = from_chars[i];
        if (last_from == null) {
          last_from = char;
          from_chars_expanded.push(char);
        }
        else if (char === '-') {
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
          var end = char.charCodeAt(0);
          for (var c = start; c < end; c++) {
            from_chars_expanded.push(String.fromCharCode(c));
          }
          from_chars_expanded.push(char);
          in_range = null;
          last_from = null;
        }
        else {
          from_chars_expanded.push(char);
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
            var char = to_chars[i];
            if (last_from == null) {
              last_from = char;
              to_chars_expanded.push(char);
            }
            else if (char === '-') {
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
              var end = char.charCodeAt(0);
              for (var c = start; c < end; c++) {
                to_chars_expanded.push(String.fromCharCode(c));
              }
              to_chars_expanded.push(char);
              in_range = null;
              last_from = null;
            }
            else {
              to_chars_expanded.push(char);
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
      for (var i = 0, length = #{self}.length; i < length; i++) {
        var char = #{self}.charAt(i);
        var sub = subs[char]
        if (inverse) {
          if (sub == null) {
            if (last_substitute == null) {
              new_str += global_sub;
              last_substitute = true;
            }
          }
          else {
            new_str += char;
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
            new_str += char;
            last_substitute = null;
          }
        }
      }
      return new_str;
    }
  end
  
  def underscore
    `#{self}.replace(/[-\\s]+/g, '_')
            .replace(/([A-Z\\d]+)([A-Z][a-z])/g, '$1_$2')
            .replace(/([a-z\\d])([A-Z])/g, '$1_$2')
            .toLowerCase()`
  end

  alias_native :upcase, :toUpperCase
end

Symbol = String
