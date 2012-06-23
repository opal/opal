class Regexp < `RegExp`
  def self.escape(string)
    `string.replace(/([.*+?^=!:${}()|[\]\\/\\])/g, '\\$1')`
  end

  def self.new(string, options = undefined)
    `new RegExp(string, options)`
  end

  def ==(other)
    `other.constructor == RegExp && this.toString() === other.toString()`
  end

  def ===(obj)
    `this.test(obj)`
  end

  def =~(string)
    %x{
      var result = this.exec(string);

      if (result) {
        result.$to_s    = match_to_s;
        result.$inspect = match_inspect;
        result._real    = result._klass = #{ MatchData };

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
    `this.toString()`
  end

  def match(pattern)
    %x{
      var result  = this.exec(pattern);

      if (result) {
        result.$to_s    = match_to_s;
        result.$inspect = match_inspect;
        result._real    = result._klass = #{ MatchData };

        return #{$~ = `result`};
      }
      else {
        return #{$~ = nil};
      }
    }
  end

  def to_s
    `this.source`
  end

  %x{
    function match_inspect() {
      return "<#MatchData " + this[0].$inspect() + ">";
    }

    function match_to_s() {
      return this[0];
    }
  }
end

class MatchData
end