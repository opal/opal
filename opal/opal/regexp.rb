class Regexp < `RegExp`
  def self.escape(string)
    `string.replace(/[\\-\\[\\]\\/\\{\\}\\(\\)\\*\\+\\?\\.\\\\\^\\$\\|]/g, '\\\\$&')`
  end

  def self.new(regexp, options = undefined)
    `new RegExp(regexp, options)`
  end

  def ==(other)
    `other.constructor == RegExp && #{self}.toString() === other.toString()`
  end

  alias_native :===, :test

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

      return result ? result.index : nil;
    }
  end

  alias eql? ==

  alias_native :inspect, :toString

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

  def to_s
    `#{self}.source`
  end
end
