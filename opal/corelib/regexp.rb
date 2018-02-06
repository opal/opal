class RegexpError < StandardError; end

class Regexp < `RegExp`
  IGNORECASE = 1
  EXTENDED = 2
  MULTILINE = 4

  `def.$$is_regexp = true`

  class << self
    def allocate
      allocated = super
      `#{allocated}.uninitialized = true`
      allocated
    end

    def escape(string)
      `Opal.escape_regexp(string)`
    end

    def last_match(n = nil)
      if n.nil?
        $~
      else
        $~[n]
      end
    end

    alias quote escape

    def union(*parts)
      %x{
        var is_first_part_array, quoted_validated, part, options, each_part_options;
        if (parts.length == 0) {
          return /(?!)/;
        }
        // cover the 2 arrays passed as arguments case
        is_first_part_array = parts[0].$$is_array;
        if (parts.length > 1 && is_first_part_array) {
          #{raise TypeError, 'no implicit conversion of Array into String'}
        }
        // deal with splat issues (related to https://github.com/opal/opal/issues/858)
        if (is_first_part_array) {
          parts = parts[0];
        }
        options = undefined;
        quoted_validated = [];
        for (var i=0; i < parts.length; i++) {
          part = parts[i];
          if (part.$$is_string) {
            quoted_validated.push(#{escape(`part`)});
          }
          else if (part.$$is_regexp) {
            each_part_options = #{`part`.options};
            if (options != undefined && options != each_part_options) {
              #{raise TypeError, 'All expressions must use the same options'}
            }
            options = each_part_options;
            quoted_validated.push('('+part.source+')');
          }
          else {
            quoted_validated.push(#{escape(`part`.to_str)});
          }
        }
      }
      # Take advantage of logic that can parse options from JS Regex
      new(`quoted_validated`.join('|'), `options`)
    end

    def new(regexp, options = undefined)
      %x{
        if (regexp.$$is_regexp) {
          return new RegExp(regexp);
        }

        regexp = #{Opal.coerce_to!(regexp, String, :to_str)};

        if (regexp.charAt(regexp.length - 1) === '\\' && regexp.charAt(regexp.length - 2) !== '\\') {
          #{raise RegexpError, "too short escape sequence: /#{regexp}/"}
        }

        if (options === undefined || #{!options}) {
          return new RegExp(regexp);
        }

        if (options.$$is_number) {
          var temp = '';
          if (#{IGNORECASE} & options) { temp += 'i'; }
          if (#{MULTILINE}  & options) { temp += 'm'; }
          options = temp;
        }
        else {
          options = 'i';
        }

        return new RegExp(regexp, options);
      }
    end
  end

  def ==(other)
    `other.constructor == RegExp && self.toString() === other.toString()`
  end

  def ===(string)
    `#{match(Opal.coerce_to?(string, String, :to_str))} !== nil`
  end

  def =~(string)
    match(string) && $~.begin(0)
  end

  alias eql? ==

  def inspect
    # Use a regexp to extract the regular expression and the optional mode modifiers from the string.
    # In the regular expression, escape any front slash (not already escaped) with a backslash.
    %x{
      var regexp_format = /^\/(.*)\/([^\/]*)$/;
      var value = self.toString();
      var matches = regexp_format.exec(value);
      if (matches) {
        var regexp_pattern = matches[1];
        var regexp_flags = matches[2];
        var chars = regexp_pattern.split('');
        var chars_length = chars.length;
        var char_escaped = false;
        var regexp_pattern_escaped = '';
        for (var i = 0; i < chars_length; i++) {
          var current_char = chars[i];
          if (!char_escaped && current_char == '/') {
            regexp_pattern_escaped = regexp_pattern_escaped.concat('\\');
          }
          regexp_pattern_escaped = regexp_pattern_escaped.concat(current_char);
          if (current_char == '\\') {
            if (char_escaped) {
              // does not over escape
              char_escaped = false;
            } else {
              char_escaped = true;
            }
          } else {
            char_escaped = false;
          }
        }
        return '/' + regexp_pattern_escaped + '/' + regexp_flags;
      } else {
        return value;
      }
    }
  end

  def match(string, pos = undefined, &block)
    %x{
      if (self.uninitialized) {
        #{raise TypeError, 'uninitialized Regexp'}
      }

      if (pos === undefined) {
        pos = 0;
      } else {
        pos = #{Opal.coerce_to(pos, Integer, :to_int)};
      }

      if (string === nil) {
        return #{$~ = nil};
      }

      string = #{Opal.coerce_to(string, String, :to_str)};

      if (pos < 0) {
        pos += string.length;
        if (pos < 0) {
          return #{$~ = nil};
        }
      }

      var source = self.source;
      var flags = 'g';
      // m flag + a . in Ruby will match white space, but in JS, it only matches beginning/ending of lines, so we get the equivalent here
      if (self.multiline) {
        source = source.replace('.', "[\\s\\S]");
        flags += 'm';
      }

      // global RegExp maintains state, so not using self/this
      var md, re = new RegExp(source, flags + (self.ignoreCase ? 'i' : ''));

      while (true) {
        md = re.exec(string);
        if (md === null) {
          return #{$~ = nil};
        }
        if (md.index >= pos) {
          #{$~ = MatchData.new(`re`, `md`)}
          return block === nil ? #{$~} : #{yield $~};
        }
        re.lastIndex = md.index + 1;
      }
    }
  end

  def match?(string, pos = undefined)
    %x{
      if (self.uninitialized) {
        #{raise TypeError, 'uninitialized Regexp'}
      }

      if (pos === undefined) {
        pos = 0;
      } else {
        pos = #{Opal.coerce_to(pos, Integer, :to_int)};
      }

      if (string === nil) {
        return false;
      }

      string = #{Opal.coerce_to(string, String, :to_str)};

      if (pos < 0) {
        pos += string.length;
        if (pos < 0) {
          return false;
        }
      }

      var source = self.source;
      var flags = 'g';
      // m flag + a . in Ruby will match white space, but in JS, it only matches beginning/ending of lines, so we get the equivalent here
      if (self.multiline) {
        source = source.replace('.', "[\\s\\S]");
        flags += 'm';
      }

      // global RegExp maintains state, so not using self/this
      var md, re = new RegExp(source, flags + (self.ignoreCase ? 'i' : ''));

      md = re.exec(string);
      if (md === null || md.index < pos) {
        return false;
      } else {
        return true;
      }
    }
  end

  def ~
    self =~ $_
  end

  def source
    `self.source`
  end

  def options
    # Flags would be nice to use with this, but still experimental - https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/flags
    %x{
      if (self.uninitialized) {
        #{raise TypeError, 'uninitialized Regexp'}
      }
      var result = 0;
      // should be supported in IE6 according to https://msdn.microsoft.com/en-us/library/7f5z26w4(v=vs.94).aspx
      if (self.multiline) {
        result |= #{MULTILINE};
      }
      if (self.ignoreCase) {
        result |= #{IGNORECASE};
      }
      return result;
    }
  end

  def casefold?
    `self.ignoreCase`
  end

  alias to_s source
end

class MatchData
  attr_reader :post_match, :pre_match, :regexp, :string

  def initialize(regexp, match_groups)
    $~          = self
    @regexp     = regexp
    @begin      = `match_groups.index`
    @string     = `match_groups.input`
    @pre_match  = `match_groups.input.slice(0, match_groups.index)`
    @post_match = `match_groups.input.slice(match_groups.index + match_groups[0].length)`
    @matches    = []

    %x{
      for (var i = 0, length = match_groups.length; i < length; i++) {
        var group = match_groups[i];

        if (group == null) {
          #@matches.push(nil);
        }
        else {
          #@matches.push(group);
        }
      }
    }
  end

  def [](*args)
    @matches[*args]
  end

  def offset(n)
    %x{
      if (n !== 0) {
        #{raise ArgumentError, 'MatchData#offset only supports 0th element'}
      }
      return [self.begin, self.begin + self.matches[n].length];
    }
  end

  def ==(other)
    return false unless MatchData === other

    `self.string == other.string` &&
      `self.regexp.toString() == other.regexp.toString()` &&
      `self.pre_match == other.pre_match` &&
      `self.post_match == other.post_match` &&
      `self.begin == other.begin`
  end

  alias eql? ==

  def begin(n)
    %x{
      if (n !== 0) {
        #{raise ArgumentError, 'MatchData#begin only supports 0th element'}
      }
      return self.begin;
    }
  end

  def end(n)
    %x{
      if (n !== 0) {
        #{raise ArgumentError, 'MatchData#end only supports 0th element'}
      }
      return self.begin + self.matches[n].length;
    }
  end

  def captures
    `#@matches.slice(1)`
  end

  def inspect
    %x{
      var str = "#<MatchData " + #{`#@matches[0]`.inspect};

      for (var i = 1, length = #@matches.length; i < length; i++) {
        str += " " + i + ":" + #{`#@matches[i]`.inspect};
      }

      return str + ">";
    }
  end

  def length
    `#@matches.length`
  end

  alias size length

  def to_a
    @matches
  end

  def to_s
    `#@matches[0]`
  end

  def values_at(*args)
    %x{
      var i, a, index, values = [];

      for (i = 0; i < args.length; i++) {

        if (args[i].$$is_range) {
          a = #{`args[i]`.to_a};
          a.unshift(i, 1);
          Array.prototype.splice.apply(args, a);
        }

        index = #{Opal.coerce_to!(`args[i]`, Integer, :to_int)};

        if (index < 0) {
          index += #@matches.length;
          if (index < 0) {
            values.push(nil);
            continue;
          }
        }

        values.push(#@matches[index]);
      }

      return values;
    }
  end
end
