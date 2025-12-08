# backtick_javascript: true
# helpers: coerce_to, str
require 'benchmark/ips'

s = "𝌆a𝌆"
short_string = "𝌆"
medi_string = s * 10

pri = `medi_string.valueOf()`
obj = `new String(medi_string)`

class String
  %x{
    const MAX_STR_LEN = Number.MAX_SAFE_INTEGER;
  }

  def gsub_orig(pattern, replacement = undefined, &block)
    %x{
      if (replacement === undefined && block === nil) {
        return #{enum_for :gsub, pattern};
      }

      var result = '', match_data = nil, index = 0, match, _replacement;

      if (pattern.$$is_regexp) {
        pattern = $global_regexp(pattern);
      } else {
        pattern = $coerce_to(pattern, Opal.String, 'to_str');
        pattern = new RegExp(pattern.replace(/[.*+?^${}()|[\]\\]/gu, '\\$&'), 'gmu');
      }

      var lastIndex, s = self.valueOf();
      while (true) {
        match = pattern.exec(s);

        if (match === null) {
          #{$~ = nil}
          result += s.slice(index);
          break;
        }

        match_data = #{::MatchData.new `pattern`, `match`};

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
            replacement = $coerce_to(replacement, Opal.String, 'to_str');
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
            case "`": return slashes.slice(1) + s.slice(0, match.index);
            case "'": return slashes.slice(1) + s.slice(match.index + match[0].length);
            default:  return slashes.slice(1) + (match[command] || '');
            }
          }).replace(/\\\\/g, '\\');
        }

        if (pattern.lastIndex === match.index) {
          result += (s.slice(index, match.index) + _replacement + (s[match.index] || ""));
          pattern.lastIndex += 1;
        }
        else {
          result += (s.slice(index, match.index) + _replacement)
        }
        index = pattern.lastIndex;
      }

      #{$~ = `match_data`}
      return result;
    }
  end

  def gsub_rope(pattern, replacement = undefined, &block)
    %x{
      if (replacement === undefined && block === nil) {
        return #{enum_for :gsub, pattern};
      }

      var result = '', match_data = nil, index = 0, match, _replacement;

      if (pattern.$$is_regexp) {
        pattern = $global_regexp(pattern);
      } else {
        pattern = $coerce_to(pattern, Opal.String, 'to_str');
        pattern = new RegExp(pattern.replace(/[.*+?^${}()|[\]\\]/gu, '\\$&'), 'gmu');
      }

      var lastIndex, s = self.valueOf();

      while (true) {
        match = pattern.exec(s);

        if (match === null) {
          #{$~ = nil}
          result = result + s.slice(index);
          break;
        }

        match_data = #{::MatchData.new `pattern`, `match`};

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
            replacement = $coerce_to(replacement, Opal.String, 'to_str');
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
            case "`": return slashes.slice(1) + s.slice(0, match.index);
            case "'": return slashes.slice(1) + s.slice(match.index + match[0].length);
            default:  return slashes.slice(1) + (match[command] || '');
            }
          }).replace(/\\\\/g, '\\');
        }

        if (pattern.lastIndex === match.index) {
          result = result + (s.slice(index, match.index) + _replacement + (s[match.index] || ""));
          pattern.lastIndex += 1;
        }
        else {
          result = result + (s.slice(index, match.index) + _replacement)
        }
        index = pattern.lastIndex;
      }

      #{$~ = `match_data`}
      return result;
    }
  end

    def mul_orig(count)
    %x{
      count = $coerce_to(count, Opal.Integer, 'to_int');

      if (count < 0) {
        #{::Kernel.raise ::ArgumentError, 'negative argument'}
      }

      if (count === 0) {
        return '';
      }

      var result = '',
          string = self.valueOf();

      // All credit for the bit-twiddling magic code below goes to Mozilla
      // polyfill implementation of String.prototype.repeat() posted here:
      // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/repeat

      if (string.length * count >= MAX_STR_LEN) {
        #{::Kernel.raise ::RangeError, 'multiply count must not overflow maximum string size'}
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

      return result;
    }
  end

    def mul_rope(count)
    %x{
      count = $coerce_to(count, Opal.Integer, 'to_int');

      if (count < 0) {
        #{::Kernel.raise ::ArgumentError, 'negative argument'}
      }

      if (count === 0) {
        return '';
      }

      var result = '',
          string = self.valueOf();

      // All credit for the bit-twiddling magic code below goes to Mozilla
      // polyfill implementation of String.prototype.repeat() posted here:
      // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/repeat

      if (string.length * count >= MAX_STR_LEN) {
        #{::Kernel.raise ::RangeError, 'multiply count must not overflow maximum string size'}
      }

      for (;;) {
        if ((count & 1) === 1) {
          result = result + string;
        }
        count >>>= 1;
        if (count === 0) {
          break;
        }
        string = string + string;
      }

      return result;
    }
  end
end

# The loop is silly, but its purpose is, to make it harder for v8 to optimize
# in the mixed cases. To be fair for all cases, the silly loop is there in all cases.

Benchmark.ips do |x|
  x.report("string gsub orig") do
    medi_string.gsub_orig('a', 'b')
  end

  x.report("string gsub rope") do
    medi_string.gsub_rope('a', 'b')
  end
  x.compare!
end

Benchmark.ips do |x|
  x.report("string mul orig") do
    'a'.mul_orig(100)
  end

  x.report("string mul rope") do
    'a'.mul_rope(100)
  end
  x.compare!
end

Benchmark.ips do |x|
  x.report("medi string mul orig") do
    medi_string.mul_orig(10)
  end

  x.report("medi string mul rope") do
    medi_string.mul_rope(10)
  end
  x.compare!
end
