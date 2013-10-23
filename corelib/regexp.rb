class Regexp
  `def._isRegexp = true`

  def self.escape(string)
    `string.replace(/[\\-\\[\\]\\/\\{\\}\\(\\)\\*\\+\\?\\.\\\\\^\\$\\|]/g, '\\\\$&')`
  end

  def self.union(*parts)
    `new RegExp(parts.join(''))`
  end

  def self.new(regexp, options = undefined)
    `new RegExp(regexp, options)`
  end

  def ==(other)
    `other.constructor == RegExp && #{self}.toString() === other.toString()`
  end

  def ===(str)
    if `str._isString == null` && str.respond_to?(:to_str)
      str = str.to_str
    end

    if `str._isString == null`
      return false
    end

    `self.test(str)`
  end

  def =~(string)
    if `string === nil`
      $~ = $` = $' = nil

      return
    end

    if `string._isString == null`
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
        // rewrite regular expression to add the global flag to capture pre/post match
        re = new RegExp(re.source, 'g' + (re.multiline ? 'm' : '') + (re.ignoreCase ? 'i' : ''));
      }

      var result = re.exec(string);

      if (result) {
        #{$~ = MatchData.new(`re`, `result`)};
      }
      else {
        #{$~ = $` = $' = nil};
      }

      return result ? result.index : nil;
    }
  end

  alias eql? ==

  def inspect
    `self.toString()`
  end

  def match(string, pos = undefined)
    if `string._isString == null`
      unless string.respond_to? :to_str
        raise TypeError, "no implicit conversion of #{other.class.name} into String"
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
        return #{$~ = MatchData.new(`re`, `result`)};
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

  def to_n
    `self.valueOf()`
  end
end
