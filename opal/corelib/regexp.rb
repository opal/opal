class Regexp
  `def.$$is_regexp = true`

  IGNORECASE  = 1
  EXTENDED    = 2
  MULTILINE   = 4

  class << self
    def escape(string)
      %x{
        return string.replace(/([-[\]/{}()*+?.^$\\| ])/g, '\\$1')
                     .replace(/[\n]/g, '\\n')
                     .replace(/[\r]/g, '\\r')
                     .replace(/[\f]/g, '\\f')
                     .replace(/[\t]/g, '\\t');
      }
    end

    alias quote escape

    def union(*parts)
      `new RegExp(parts.join(''))`
    end

    def new(regexp, options = undefined, lang = nil)
      flags = "g"
      unless options.nil?
        if regexp.is_a? Regexp
          warn "warning: flags ignored"
        elsif options.is_a? Fixnum
          flags = "g#{ "i" if options&IGNORECASE > 0 }#{ "x" if options&EXTENDED > 0 }#{ "m" if options&MULTILINE > 0 }"
        elsif options != false
          flags = "gi"
        end
      end
      re = `XRegExp(regexp, flags)`
      re.instance_variable_set(:@extended, options&EXTENDED > 0)
      re.instance_variable_set(:@src, regexp)
      re.instance_variable_set(:@flags, flags)
      return re
    end
  end

  def ==(other)
    `other.constructor == RegExp && self.toString() === other.toString()`
  end

  def ===(str)
    %x{
      if (!str.$$is_string && #{str.respond_to?(:to_str)}) {
        #{str = str.to_str};
      }

      if (!str.$$is_string) {
        return false;
      }

      return self.test(str);
    }
  end

  def =~(string)
    if `string === nil`
      $~ = $` = $' = nil

      return
    end

    string = Opal.coerce_to(string, String, :to_str).to_s

    %x{
      var re = self;

      if (re.global) {
        // should we clear it afterwards too?
        re.lastIndex = 0;
      }
      else {
        // rewrite regular expression to add the global flag to capture pre/post match
        re = XRegExp(re.source, 'g' + (re.multiline ? 'm' : '') + (re.ignoreCase ? 'i' : ''));
      }

      var result = XRegExp.exec(string, re);

      if (result) {
        #{$~ = MatchData.new(`re`, `result`)};
      }
      else {
        #{$~ = $` = $' = nil};
      }

      return result ? result.index : nil;
    }
  end

  def casefold?
    `self.ignoreCase`
  end

  alias eql? ==

  def inspect
    `self.toString()`
  end

  def match(string, pos = undefined, &block)
    if `string === nil`
      $~ = $` = $' = nil

      return
    end

    if `string.$$is_string == null`
      unless string.respond_to? :to_str
        raise TypeError, "no implicit conversion of #{string.class} into String"
      end

      string = string.to_str
    end

    %x{
      var re = self;

      if (re.global) {
        // should we clear it afterwards too?
        re.lastIndex = 0;
      }
      else {
        re = new XRegExp(re.source, 'g' + (re.multiline ? 'm' : '') + (re.ignoreCase ? 'i' : ''));
      }

      var result = XRegExp.exec(string, re);

      if (result) {
        result = #{$~ = MatchData.new(`re`, `result`)};

        if (block === nil) {
          return result;
        }
        else {
          return #{block.call(`result`)};
        }
      }
      else {
        return #{$~ = $` = $' = nil};
      }
    }
  end

  def names
    re = self
    %x{
        console.log(re.xregexp.captureNames);
        if (re.xregexp.captureNames == null) {
          return nil
        }
        else {
          return re.xregexp.captureNames
        }
      }
  end

  def options
    result = 0
    result = result | IGNORECASE if `self.ignoreCase`
    result = result | EXTENDED if @extended
    result = result | MULTILINE if `self.multiline`
  end

  def source
    @src
  end

  alias to_s source
end
