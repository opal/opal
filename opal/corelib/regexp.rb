class RegexpError < StandardError; end

class Regexp < `RegExp`
  IGNORECASE = 1
  EXTENDED = 2
  MULTILINE = 4
  FIXEDENCODING = 16
  NOENCODING = 32

  `def.$$is_regexp = true`

  class << self
    def allocate
      allocated = super
      `#{allocated}.uninitialized = true`
      allocated
    end

    def escape(string)
      %x{
        return string.replace(/([-[\]\/{}()*+?.^$\\| ])/g, '\\$1')
                     .replace(/[\n]/g, '\\n')
                     .replace(/[\r]/g, '\\r')
                     .replace(/[\f]/g, '\\f')
                     .replace(/[\t]/g, '\\t');
      }
    end

    def last_match(n=nil)
      if n.nil?
        $~
      else
        $~[n]
      end
    end

    alias quote escape

    def convert(pattern)
      %x{
        if (pattern.$$is_regexp) {
          return pattern;
        } else if (pattern.$$is_array) {
          return #{union(*pattern)};
        } else {
          return #{escape(pattern)};
        }
      }
    end

    def union(*parts)
      %x{
        var part;

        switch (parts.length) {
          case 0:
            return /(?!)/;
          case 1:
            part = parts[0];
            if (part.$$is_array) {
              return #{union(*`part`)};
            } else if (part.$$is_regexp) {
              return part;
            } else {
              part = #{Opal.coerce_to!(`part`, String, :to_str)};
              return #{new(escape(`part`))};
            }
          default:
            var result = [];

            for (var i = 0; i < parts.length; i++) {
              part = parts[i];

              if (part.$$is_regexp) {
                part = #{`part`.to_s}
              } else {
                part = #{escape(Opal.coerce_to!(`part`, String, :to_str))}
              }

              result.push(part);
            }

            result = result.join("|");
            return #{Regexp.new(`result`)};
        }
      }
    end

    %x{
      function generateNativeRegexp(ruby_source, options) {
        var captureRegexp = /(\(\?P?<([\w$]+)>|\((?!\?))/g;

        var ignorecase = options & #{IGNORECASE},
            extended = options & #{EXTENDED},
            multiline = options & #{MULTILINE},
            fixed_encoding = options & #{FIXEDENCODING},
            source = ruby_source,
            flags = [];

        if (ignorecase) {
          flags.push('i');
        }

        if (extended) {
          source = source.replace(/\s*(\\)?#.*/g, function($0, $1) {
            return $1 ? $0 : '';
          }).replace(/\s/g, '');
        }

        source = source.replace("\\A", "^").replace("\\z", "$").replace("\\z", "$");

        var captures = [], named_capture_idx = 1;

        while (true) {
          var md = captureRegexp.exec(source);

          if (md === null) {
            break;
          }

          var capture_name = md[2];

          if (capture_name) {
            captures.push({ capture_name: capture_name, position: md.index });
            source = source.replace(md[0], '(');
            captureRegexp.lastIndex = md.index + 1;
          } else {
            captures.push({ position: md.index });
          }
        }

        try {
          var result = new RegExp(source, flags.join(''));

          result.$$source = ruby_source;
          result.$$multiline = (multiline > 0);
          result.$$ignorecase = (ignorecase > 0);
          result.$$extended = (extended > 0);
          result.$$options = options;
          result.$$fixed_encoding = (fixed_encoding > 0);
          result.$$captures = captures;

          return result;
        } catch(e) {
          #{raise RegexpError, `e.message`}
        }
      }

      function validateRegexpSource(source) {
        var error;

        if (source.match(/\?<=/)) {
          error = "Positive lookbehind is not supported in regular expressions";
        }

        if (source.match(/\?<!/)) {
          error = "Negative lookbehind is not supported in regular expressions";
        }

        if (error) {
          error = error + ": " + source;
          Opal.Kernel.$raise(Opal.SyntaxError, error);
        }
      }
    }

    def new(regexp, options = 0, kcode = undefined)
      %x{
        if (regexp.$$is_regexp) {
          return #{new(regexp.source, regexp.options)};
        }

        if (kcode != null && kcode.$$is_string) {
          code = kcode[0];
          if (code == 'n' || code == 'N') {
            options |= #{NOENCODING};
          }
        }

        var source = #{Opal.coerce_to!(regexp, String, :to_str)};

        if (source.charAt(source.length - 1) === '\\' && source.charAt(source.length - 2) !== '\\') {
          #{raise RegexpError, "too short escape sequence: /#{regexp}/"}
        }

        validateRegexpSource(source);
        return generateNativeRegexp(source, options);
      }
    end

    alias compile new

    def create(string, regopts)
      %x{
        var options = 0,
            encoding = 'US-ASCII',
            fixed_encoding = false,
            encoding_mapping = { e: 'EUC-JP', s: 'Windows-31J', u: 'UTF-8' },
            regexp;

        for (var i = 0; i < regopts.length; i++) {
          var opt = regopts[i];
          switch(opt) {
            case 'i':
              options |= #{IGNORECASE};
              break;
            case 'x':
              options |= #{EXTENDED};
              break;
            case 'm':
              options |= #{MULTILINE};
              break;
            case 'n':
              if (options & #{FIXEDENCODING}) {
                options ^= #{FIXEDENCODING};
              }
              options |= #{NOENCODING};
              fixed_encoding = false;
              encoding = 'US-ASCII';
              break;
            case 'e':
            case 's':
            case 'u':
              if (options & #{NOENCODING}) {
                options ^= #{NOENCODING};
              }
              options |= #{FIXEDENCODING};
              fixed_encoding = true;
              encoding = encoding_mapping[opt];
              break;
            case 'o':
              // This option can't be handled in runtime but it's still valid.
              break;
          }
        }

        if (fixed_encoding) {
          string = #{string.force_encoding(Encoding.find(`encoding`))};
        }

        regexp = #{new(string, `options`)};
        regexp.$$encoding = encoding;
        regexp.$$fixed_encoding = fixed_encoding;

        return regexp;
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

  %x{
    function definedVisibleFlags(regexp) {
      var result = "";
      if (regexp.$$multiline)  { result += "m"; }
      if (regexp.$$ignorecase) { result += "i"; }
      if (regexp.$$extended)   { result += "x"; }
      return result;
    }

    function undefinedVisibleFlags(regexp) {
      var result = "";
      if (!regexp.$$multiline)  { result += "m"; }
      if (!regexp.$$ignorecase) { result += "i"; }
      if (!regexp.$$extended)   { result += "x"; }
      return result;
    }
  }

  def inspect
    %x{
      var escaped = #{source}.replace(/(\\.)|\//g, function($1, $2) {
        return $2 || "\\/";
      });
      var result = "/" + escaped + "/" + definedVisibleFlags(self);
      if (self.$$options & #{NOENCODING}) {
        result += 'n';
      }
      return result;
    }
  end

  def to_s
    %x{
      var undefined_flags = undefinedVisibleFlags(self);

      if (undefined_flags.length > 0) {
        undefined_flags = "-" + undefined_flags;
      }

      return "(?" + definedVisibleFlags(self) + undefined_flags + ":" + #{source} + ")";
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
          #{$~ = MatchData.new(`self`, `md`)}
          return block === nil ? #{$~} : #{block.call($~)};
        }
        re.lastIndex = md.index + 1;
      }
    }
  end

  def ~
    self =~ $_
  end

  def source
    %x{
      if (self.hasOwnProperty('$$source')) {
        return self.$$source;
      } else {
        return self.source;
      }
    }
  end

  def options
    %x{
      if (self.uninitialized) {
        #{raise TypeError, 'uninitialized Regexp'}
      } else if (self.hasOwnProperty('$$options')) {
        return self.$$options;
      } else {
        return 0;
      }
    }
  end

  def casefold?
    `self.ignoreCase`
  end

  def fixed_encoding?
    `!!self.$$fixed_encoding`
  end

  def encoding
    source.encoding
  end

  def named_captures
    %x{
      var result = {},
          capture_idx = 1;

      if (!self.hasOwnProperty('$$captures')) {
        return #{{}};
      }

      for (var i = 0; i < self.$$captures.length; i++) {
        var capture = self.$$captures[i];

        if (capture.hasOwnProperty('capture_name')) {
          var capture_name = capture.capture_name;

          if (result.hasOwnProperty(capture_name)) {
            result[capture_name].push(capture_idx);
          } else {
            result[capture_name] = [capture_idx];
          }
          capture_idx++;
        }
      }

      return Opal.hash2(Object.keys(result), result);
    }
  end

  def names
    named_captures.keys
  end

  def self._load(args)
    self.new(*args)
  end
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
    @named_captures = []
    @named_captures_mapping = {}

    %x{
      for (var i = 0, length = match_groups.length; i < length; i++) {
        var group = match_groups[i],
            capture_idx = i - 1,
            capture_data;

        if (capture_idx >= 0) {
          capture_data = #@regexp.$$captures[capture_idx];
        }

        if (capture_data && capture_data.hasOwnProperty('capture_name')) {
          #@named_captures.push({ capture_name: capture_data.capture_name, matched: group });
          #{@named_captures_mapping[`capture_data.capture_name`] = `group`}
        }

        if (group == null) {
          #@matches.push(nil);
        }
        else {
          #@matches.push(group);
        }
      }
    }
  end

  def [](start, length = undefined)
    %x{
      if (length == null && start.$$is_string) {
        if (#{@named_captures_mapping.has_key?(start)}) {
          return #{@named_captures_mapping[start]};
        } else {
          #{raise IndexError, "undefined group name reference: #{start}"}
        }
      } else {
        return #{@matches[start, length]}
      }
    }
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
      var i, str = "#<MatchData " + #{`#@matches[0]`.inspect};

      if (#@named_captures.length > 0) {
        for (i = 0, length = #@named_captures.length; i < length; i++) {
          var capture = #@named_captures[i];

          str += " " + capture.capture_name + ":" + #{`capture.matched`.inspect};
        }
      } else {
        for (i = 1, length = #@matches.length; i < length; i++) {
          str += " " + i + ":" + #{`#@matches[i]`.inspect};
        }
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
