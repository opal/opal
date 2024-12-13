# helpers: coerce_to, opal32_init, opal32_add
# backtick_javascript: true
require 'benchmark/ips'

class String
  %x{
    function find_index(str, search_s, search_l, search) {
      let search_f = search_s[0];
      return str.findIndex((c, i, s) => {
        return (c === search_f && (search_l === 1 || s.slice(i, i + search_l).join('') == search)) ?
          true : false;
      });
    }
  }

  def slice_orig(index, length = undefined)
    %x{
      var size = self.length, exclude, range;

      if (index.$$is_range) {
        exclude = index.excl;
        range   = index;
        length  = index.end === nil ? -1 : $coerce_to(index.end, #{::Integer}, 'to_int');
        index   = index.begin === nil ? 0 : $coerce_to(index.begin, #{::Integer}, 'to_int');

        if (Math.abs(index) > size) {
          return nil;
        }

        if (index < 0) {
          index += size;
        }

        if (length < 0) {
          length += size;
        }

        if (!exclude || range.end === nil) {
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
          #{::Kernel.raise ::TypeError}
        }
        return self.indexOf(index) !== -1 ? index : nil;
      }


      if (index.$$is_regexp) {
        var match = self.match(index);

        if (match === null) {
          #{$~ = nil}
          return nil;
        }

        #{$~ = ::MatchData.new(`index`, `match`)}

        if (length == null) {
          return match[0];
        }

        length = $coerce_to(length, #{::Integer}, 'to_int');

        if (length < 0 && -length < match.length) {
          return match[length += match.length];
        }

        if (length >= 0 && length < match.length) {
          return match[length];
        }

        return nil;
      }

      index = $coerce_to(index, #{::Integer}, 'to_int');

      if (index < 0) {
        index += size;
      }

      if (length == null) {
        if (index >= size || index < 0) {
          return nil;
        }
        return self.substr(index, 1);
      }

      length = $coerce_to(length, #{::Integer}, 'to_int');

      if (length < 0) {
        return nil;
      }

      if (index > size || index < 0) {
        return nil;
      }

      return self.substr(index, length);
    }
  end

  def size_orig
    `self.length`
  end


  def center_orig(width, padstr = ' ')
    width  = `$coerce_to(#{width}, #{::Integer}, 'to_int')`
    padstr = `$coerce_to(#{padstr}, #{::String}, 'to_str')`.to_s

    if padstr.empty?
      ::Kernel.raise ::ArgumentError, 'zero width padding'
    end

    return self if `width <= self.length`

    %x{
      var ljustified = #{ljust_orig ((width + `self.length`) / 2).ceil, padstr},
          rjustified = #{rjust_orig ((width + `self.length`) / 2).floor, padstr};

      return rjustified + ljustified.slice(self.length);
    }
  end

  def ljust_orig(width, padstr = ' ')
    width  = `$coerce_to(#{width}, #{::Integer}, 'to_int')`
    padstr = `$coerce_to(#{padstr}, #{::String}, 'to_str')`.to_s

    if padstr.empty?
      ::Kernel.raise ::ArgumentError, 'zero width padding'
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

  def rjust_orig(width, padstr = ' ')
    width  = `$coerce_to(#{width}, #{::Integer}, 'to_int')`
    padstr = `$coerce_to(#{padstr}, #{::String}, 'to_str')`.to_s

    if padstr.empty?
      ::Kernel.raise ::ArgumentError, 'zero width padding'
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

  def delete_prefix_orig(prefix)
    %x{
      if (!prefix.$$is_string) {
        prefix = $coerce_to(prefix, #{::String}, 'to_str');
      }

      if (self.slice(0, prefix.length) === prefix) {
        return self.slice(prefix.length);
      } else {
        return self;
      }
    }
  end

  def delete_suffix_orig(suffix)
    %x{
      if (!suffix.$$is_string) {
        suffix = $coerce_to(suffix, #{::String}, 'to_str');
      }

      if (self.slice(self.length - suffix.length) === suffix) {
        return self.slice(0, self.length - suffix.length);
      } else {
        return self;
      }
    }
  end

  def start_with_orig?(*prefixes)
    %x{
      for (var i = 0, length = prefixes.length; i < length; i++) {
        if (prefixes[i].$$is_regexp) {
          var regexp = prefixes[i];
          var match = regexp.exec(self);

          if (match != null && match.index === 0) {
            #{$~ = ::MatchData.new(`regexp`, `match`)};
            return true;
          } else {
            #{$~ = nil}
          }
        } else {
          var prefix = $coerce_to(prefixes[i], #{::String}, 'to_str').$to_s();

          if (self.length >= prefix.length && self.startsWith(prefix)) {
            return true;
          }
        }
      }

      return false;
    }
  end

  def end_with_orig?(*suffixes)
    %x{
      for (var i = 0, length = suffixes.length; i < length; i++) {
        var suffix = $coerce_to(suffixes[i], #{::String}, 'to_str').$to_s();

        if (self.length >= suffix.length &&
            self.substr(self.length - suffix.length, suffix.length) == suffix) {
          return true;
        }
      }
    }

    false
  end

  def index_orig(search, offset = undefined)
    %x{
      var index,
          match,
          regex;

      if (offset === undefined) {
        offset = 0;
      } else {
        offset = $coerce_to(offset, #{::Integer}, 'to_int');
        if (offset < 0) {
          offset += self.length;
          if (offset < 0) {
            return nil;
          }
        }
      }

      if (search.$$is_regexp) {
        regex = $global_regexp(search);
        while (true) {
          match = regex.exec(self);
          if (match === null) {
            #{$~ = nil};
            index = -1;
            break;
          }
          if (match.index >= offset) {
            #{$~ = ::MatchData.new(`regex`, `match`)}
            index = match.index;
            break;
          }
          regex.lastIndex = match.index + 1;
        }
      } else {
        search = $coerce_to(search, #{::String}, 'to_str');
        if (search.length === 0 && offset > self.length) {
          index = -1;
        } else {
          index = self.indexOf(search, offset);
        }
      }

      return index === -1 ? nil : index;
    }
  end

  def next_orig
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

  def partition_orig(sep)
    %x{
      var i, m;

      if (sep.$$is_regexp) {
        m = sep.exec(self);
        if (m === null) {
          i = -1;
        } else {
          #{::MatchData.new `sep`, `m`};
          sep = m[0];
          i = m.index;
        }
      } else {
        sep = $coerce_to(sep, #{::String}, 'to_str');
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


  def reverse_orig
    `self.split('').reverse().join('')`
  end

  def rindex_orig(search, offset = undefined)
    %x{
      var i, m, r, _m;

      if (offset === undefined) {
        offset = self.length;
      } else {
        offset = $coerce_to(offset, #{::Integer}, 'to_int');
        if (offset < 0) {
          offset += self.length;
          if (offset < 0) {
            return nil;
          }
        }
      }

      if (search.$$is_regexp) {
        m = null;
        r = $global_regexp(search);
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
          #{::MatchData.new `r`, `m`};
          i = m.index;
        }
      } else {
        search = $coerce_to(search, #{::String}, 'to_str');
        i = self.lastIndexOf(search, offset);
      }

      return i === -1 ? nil : i;
    }
  end

  def rpartition_orig(sep)
    %x{
      var i, m, r, _m;

      if (sep.$$is_regexp) {
        m = null;
        r = $global_regexp(sep);

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
          #{::MatchData.new `r`, `m`};
          sep = m[0];
          i = m.index;
        }

      } else {
        sep = $coerce_to(sep, #{::String}, 'to_str');
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

  def tr_orig(from, to)
    %x{
      from = $coerce_to(from, #{::String}, 'to_str').$to_s();
      to = $coerce_to(to, #{::String}, 'to_str').$to_s();

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
            #{::Kernel.raise ::ArgumentError, "invalid range \"#{`String.fromCharCode(start)`}-#{`String.fromCharCode(end)`}\" in string transliteration"}
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
                #{::Kernel.raise ::ArgumentError, "invalid range \"#{`String.fromCharCode(start)`}-#{`String.fromCharCode(end)`}\" in string transliteration"}
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
      return new_str;
    }
  end

  def split_orig(pattern = undefined, limit = undefined)
    %x{
      if (self.length === 0) {
        return [];
      }

      if (limit === undefined) {
        limit = 0;
      } else {
        limit = #{::Opal.coerce_to!(limit, ::Integer, :to_int)};
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
          match_count = 0,
          valid_result_length = 0,
          i, max;

      if (pattern.$$is_regexp) {
        pattern = $global_regexp(pattern);
      } else {
        pattern = $coerce_to(pattern, #{::String}, 'to_str').$to_s();

        if (pattern === ' ') {
          pattern = /\s+/gm;
          string = string.replace(/^\s+/, '');
        }
      }

      result = string.split(pattern);

      if (result.length === 1 && result[0] === string) {
        return [result[0]];
      }

      while ((i = result.indexOf(undefined)) !== -1) {
        result.splice(i, 1);
      }

      if (limit === 0) {
        while (result[result.length - 1] === '') {
          result.pop();
        }
        return result;
      }

      if (!pattern.$$is_regexp) {
        pattern = Opal.escape_regexp(pattern)
        pattern = new RegExp(pattern, 'gm');
      }

      match = pattern.exec(string);

      if (limit < 0) {
        if (match !== null && match[0] === '' && pattern.source.indexOf('(?=') === -1) {
          for (i = 0, max = match.length; i < max; i++) {
            result.push('');
          }
        }
        return result;
      }

      if (match !== null && match[0] === '') {
        valid_result_length = (match.length - 1) * (limit - 1) + limit
        result.splice(valid_result_length - 1, result.length - 1, result.slice(valid_result_length - 1).join(''));
        return result;
      }

      if (limit >= result.length) {
        return result;
      }

      while (match !== null) {
        match_count++;
        index = pattern.lastIndex;
        valid_result_length += match.length
        if (match_count + 1 === limit) {
          break;
        }
        match = pattern.exec(string);
      }
      result.splice(valid_result_length, result.length - 1, string.slice(index));
      return result;
    }
  end

  def capitalize_orig
    `self.charAt(0).toUpperCase() + self.substr(1).toLowerCase()`
  end

  def chomp_orig(separator = $/)
    return self if `separator === nil || self.length === 0`

    separator = ::Opal.coerce_to!(separator, ::String, :to_str).to_s

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
        return result;
      }
    }

    self
  end

  def chop_orig
    %x{
      var length = self.length, result;

      if (length <= 1) {
        result = "";
      } else if (self.charAt(length - 1) === "\n" && self.charAt(length - 2) === "\r") {
        result = self.substr(0, length - 2);
      } else {
        result = self.substr(0, length - 1);
      }

      return result;
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
              #{::Kernel.raise ::ArgumentError, "invalid range \"#{`char_code_from`}-#{`char_code_upto`}\" in string transliteration"}
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
        set = $coerce_to(sets[i], #{::String}, 'to_str');
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
        return '[' + #{::Regexp.escape(`pos_intersection`)} + ']';
      }

      if (neg_intersection.length > 0) {
        return '[^' + #{::Regexp.escape(`neg_intersection`)} + ']';
      }

      return null;
    }
  }

  def count_orig(*sets)
    %x{
      if (sets.length === 0) {
        #{::Kernel.raise ::ArgumentError, 'ArgumentError: wrong number of arguments (0 for 1+)'}
      }
      var char_class = char_class_from_char_sets(sets);
      if (char_class === null) {
        return 0;
      }
      return self.length - self.replace(new RegExp(char_class, 'g'), '').length;
    }
  end

  def delete_orig(*sets)
    %x{
      if (sets.length === 0) {
        #{::Kernel.raise ::ArgumentError, 'ArgumentError: wrong number of arguments (0 for 1+)'}
      }
      var char_class = char_class_from_char_sets(sets);
      if (char_class === null) {
        return self;
      }
      return self.replace(new RegExp(char_class, 'g'), '');
    }
  end
end

s = "𝌆a𝌆"
c = "𝌆a𝌆 𝌆a𝌆" # string for centering
short_string = "𝌆"
medi_string = s * 10
mi = medi_string.size - 2
long_string = s * 13108 # just a few bytes beyond 64k bytes
li = long_string.size - 2
ni = -2
r1 = (30..100)
r2 = ((li-100)..(li-30))
r3 = (-100..-30)

def sep
  puts
  puts '#' * 79
  puts
end

sep

Benchmark.ips do |x|
  x.report("orig short size")    { short_string.size_orig }
  x.report("current short size") { short_string.size }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig medi size")    { medi_string.size_orig }
  x.report("current medi size") { medi_string.size }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig long size")    { long_string.size_orig }
  x.report("current long size") { long_string.size }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig [] short")    { short_string.slice_orig(0) }
  x.report("current [] short") { short_string[0] }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig [] medi+")    { medi_string.slice_orig(mi) }
  x.report("current [] medi+") { medi_string[mi] }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig [] medi-")    { medi_string.slice_orig(-mi) }
  x.report("current [] medi-") { medi_string[-mi] }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig [] long+")    { long_string.slice_orig(li) }
  x.report("current [] long+") { long_string[li] }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig [] long- bc")    { long_string.slice_orig(ni) }
  x.report("current [] long- bc") { long_string[ni] }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig [] long- wc")    { long_string.slice_orig(-li) }
  x.report("current [] long- wc") { long_string[-li] }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig [] range 1")    { long_string.slice_orig(r1) }
  x.report("current [] range 1") { long_string[r1] }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig [] range 2")    { long_string.slice_orig(r2) }
  x.report("current [] range 2") { long_string[r2] }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig [] range 3")    { long_string.slice_orig(r3) }
  x.report("current [] range 3") { long_string[r3] }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig ljust")    { c.ljust_orig(80) }
  x.report("current ljust") { c.ljust(80) }
  x.compare!
end

Benchmark.ips do |x|
  x.report("orig ljust u")    { c.ljust_orig(80, '𝌆') }
  x.report("current ljust u") { c.ljust(80, '𝌆') }
  x.compare!
end

Benchmark.ips do |x|
  x.report("orig ljust u3")    { c.ljust_orig(80, '𝌆𝌆𝌆') }
  x.report("current ljust u3") { c.ljust(80, '𝌆𝌆𝌆') }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig rjust")    { c.rjust_orig(80) }
  x.report("current rjust") { c.rjust(80) }
  x.compare!
end

Benchmark.ips do |x|
  x.report("orig rjust u")    { c.rjust_orig(80, '𝌆') }
  x.report("current rjust u") { c.rjust(80, '𝌆') }
  x.compare!
end

Benchmark.ips do |x|
  x.report("orig rjust u3")    { c.rjust_orig(80, '𝌆𝌆𝌆') }
  x.report("current rjust u3") { c.rjust(80, '𝌆𝌆𝌆') }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig center")    { c.center_orig(80) }
  x.report("current center") { c.center(80) }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig del_pref")    { medi_string.delete_prefix_orig(s) }
  x.report("current del_pref") { medi_string.delete_prefix(s) }
  x.compare!
end

Benchmark.ips do |x|
  x.report("orig del_suff")    { medi_string.delete_suffix_orig(s) }
  x.report("current del_suff") { medi_string.delete_suffix(s) }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig start_w")    { medi_string.start_with_orig?(s) }
  x.report("current start_w") { medi_string.start_with?(s) }
  x.compare!
end

Benchmark.ips do |x|
  x.report("orig end_w")    { medi_string.end_with_orig?(s) }
  x.report("current end_w") { medi_string.end_with?(s) }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig index")    { c.index_orig(' ') }
  x.report("current index") { c.index(' ') }
  x.compare!
end

Benchmark.ips do |x|
  x.report("orig index multi")    { c.index_orig(' 𝌆') }
  x.report("current index multi") { c.index(' 𝌆') }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig next")    { c.next_orig }
  x.report("current next") { c.next }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig partition")    { c.partition_orig(' ') }
  x.report("current partition") { c.partition(' ') }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig reverse medi")    { medi_string.reverse_orig }
  x.report("current reverse medi") { medi_string.reverse }
  x.compare!
end

Benchmark.ips do |x|
  x.report("orig reverse long")    { long_string.reverse_orig }
  x.report("current reverse long") { long_string.reverse }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig rindex")    { c.rindex_orig(' ') }
  x.report("current rindex") { c.rindex(' ') }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig rpartition")    { c.rpartition_orig(' ') }
  x.report("current rpartition") { c.rpartition(' ') }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig tr")    { long_string.tr_orig('a', '𝌆') }
  x.report("current tr") { long_string.tr('a', '𝌆') }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig split e")    { medi_string.split_orig('') }
  x.report("current split e") { medi_string.split('') }
  x.compare!
end

Benchmark.ips do |x|
  x.report("orig split sp")    { medi_string.split_orig(' ') }
  x.report("current split sp") { medi_string.split(' ') }
  x.compare!
end

Benchmark.ips do |x|
  x.report("orig split uc")    { medi_string.split_orig('𝌆') }
  x.report("current split uc") { medi_string.split('𝌆') }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig capitalize")    { medi_string.capitalize_orig }
  x.report("current capitalize") { medi_string.capitalize }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig chomp")    { medi_string.chomp_orig('𝌆') }
  x.report("current chomp") { medi_string.chomp('𝌆') }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig chop")    { medi_string.chop_orig }
  x.report("current chop") { medi_string.chop }
  x.compare!
end

sep

Benchmark.ips do |x|
  x.report("orig count")    { medi_string.count_orig('a𝌆') }
  x.report("current count") { medi_string.count('a𝌆') }
  x.compare!
end

Benchmark.ips do |x|
  x.report("orig delete")    { medi_string.delete_orig('𝌆') }
  x.report("current delete") { medi_string.delete('𝌆') }
  x.compare!
end
