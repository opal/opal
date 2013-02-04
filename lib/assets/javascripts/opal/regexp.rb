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

  alias_native :===, :test

  def =~(string)
    %x{
      var result = #{self}.exec(string);

      if (result) {
        result.$to_s    = match_to_s;
        result.$inspect = match_inspect;
        result._klass = #{MatchData};

        #{$~ = `result`};
      }
      else {
        #{$~ = nil};
      }

      return result ? result.index : nil;
    }
  end

  alias eql? ==

  alias_native :inspect, :toString

  def match(pattern)
    %x{
      var result  = #{self}.exec(pattern);

      if (result) {
        result.$to_s    = match_to_s;
        result.$inspect = match_inspect;
        result._klass = #{MatchData};

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

  %x{
    function match_to_s() {
      return this[0];
    }

    function match_inspect() {
      return "<#MatchData " + this[0].$inspect() + ">";
    }
  }
end

class MatchData
end