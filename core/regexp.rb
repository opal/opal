class Regexp < `RegExp`
  def self.escape(string)
    `string.replace(/([.*+?^=!:${}()|[\]\\/\\])/g, '\\$1')`
  end

  def self.new(string, options = undefined)
    `new RegExp(string, options)`
  end

  def ==(other)
    `other.constructor == RegExp && #{self}.toString() === other.toString()`
  end

  def ===(obj)
    `#{self}.test(obj)`
  end

  def =~(string)
    %x{
      var result = #{self}.exec(string);

      if (result) {
        var matchdata = #{MatchData};
        result.$k = matchdata;
        result.$m = matchdata.$m_tbl;

        #{$~ = `result`};
      }
      else {
        #{$~ = nil};
      }

      return result ? result.index : nil;
    }
  end

  alias eql? ==

  def inspect
    `#{self}.toString()`
  end

  def match(pattern)
    %x{
      var result  = #{self}.exec(pattern);

      if (result) {
        var matchdata = #{MatchData};
        result.$k = matchdata;
        result.$m = matchdata.$m_tbl;

        return #{$~ = `result`};
      }
      else {
        return #{$~ = nil};
      }
    }
  end

  def to_s
    `#{self}.source`
  end
end

class MatchData
  def [](idx)
    `#{self}[idx]`
  end

  def inspect
    "#<MatchData #{self[0].inspect}>"
  end

  def to_a
    `#{self}.slice()`
  end

  def to_s
    self[0]
  end
end