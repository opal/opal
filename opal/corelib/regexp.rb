class RegexpError < StandardError; end

class Regexp < `RegExp`
  IGNORECASE = 1
  MULTILINE = 4
  
  `def.$$is_regexp = true`  

  class << self
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

        if (regexp.charAt(regexp.length - 1) === '\\') {
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
    `#{match(string)} !== nil`
  end

  def =~(string)
    match(string) && $~.begin(0)
  end

  alias eql? ==

  def inspect
    `self.toString()`
  end

  def match(string, pos = undefined, &block)
    %x{
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

      // global RegExp maintains state, so not using self/this
      var md, re = new RegExp(self.source, 'gm' + (self.ignoreCase ? 'i' : ''));

      while (true) {
        md = re.exec(string);
        if (md === null) {
          return #{$~ = nil};
        }
        if (md.index >= pos) {
          #{$~ = MatchData.new(`re`, `md`)}
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
    `self.source`
  end
  
  def options
    # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/RegExp/flags is still experimental
    # we need the flags and source does not give us that
    %x{
      var as_string, text_flags, result, text_flag;
      as_string = self.toString();
      if (as_string == "/(?:)/") {
        #{raise TypeError, 'uninitialized Regexp'}
      }
      text_flags = as_string.replace(self.source, '').match(/\w+/);
      result = 0;
      // may have no flags
      if (text_flags == null) {
        return result;
      }
      // first match contains all of our flags
      text_flags = text_flags[0];
      for (var i=0; i < text_flags.length; i++) {
        text_flag = text_flags[i];
        switch(text_flag) {
          case 'i':
            result |= #{IGNORECASE};
            break;
          case 'm':
            result |= #{MULTILINE};
            break;
          default:
            #{raise "RegExp flag #{`text_flag`} does not have a match in Ruby"}
        }
      }
      
      return result;
    }  
  end
  
  def casefold?
    `self.ignoreCase`
  end

  alias to_s source
end
