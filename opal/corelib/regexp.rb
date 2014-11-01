class Regexp
  `def.$$is_regexp = true`

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

    def new(regexp, options = undefined)
      `new RegExp(regexp, options)`
    end

    def last_match
      $~
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
    }

    false ^ (self =~ str)
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
        re = new RegExp(re.source, 'g' + (re.multiline ? 'm' : '') + (re.ignoreCase ? 'i' : ''));
      }

      var result = re.exec(string);

      if (result) {
        #{$~ = MatchData.new(`re`, `result`)};

        for (var i = 1, ii = result.length; i < ii; i++) {
          Opal.gvars[String(i)] = result[i];
        }

        return result.index;
      }
      else {
        #{$~ = $` = $' = nil};
        return nil;
      }
    }
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
        re = new RegExp(re.source, 'g' + (re.multiline ? 'm' : '') + (re.ignoreCase ? 'i' : ''));
      }

      var result = re.exec(string);

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

  def source
    `self.source`
  end

  alias to_s source
end
