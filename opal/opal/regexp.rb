class Regexp
  def self.escape(string)
    `string.replace(/[\\-\\[\\]\\/\\{\\}\\(\\)\\*\\+\\?\\.\\\\\^\\$\\|]/g, '\\\\$&')`
  end

  def self.new(regexp, options = undefined)
    `options? new RegExp(regexp, options) : new RegExp(regexp)`
  end

  def ==(other)
    `other.constructor == RegExp && #{self}.toString() === other.toString()`
  end

  def ===(str)
    `#{self}.test(str)`
  end

  def =~(string)
    %x{
      var re = #{self};
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

      return result ? result.index : null;
    }
  end

  alias eql? ==

  def inspect
    `#{self}.toString()`
  end

  def match(string, pos = undefined)
    %x{
      var re = #{self};
      if (re.global) {
        // should we clear it afterwards too?
        re.lastIndex = 0;
      }
      else {
        re = new RegExp(re.source, 'g' + (#{self}.multiline ? 'm' : '') + (#{self}.ignoreCase ? 'i' : ''));
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
    `#{self}.source`
  end

  alias to_s source
end
