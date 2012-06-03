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
        var match       = new #{MatchData}._alloc();
            match.$data = result;

        #{$~ = `match`};
      }
      else {
        #{$~ = nil};
      }

      return result ? result.index : null;
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
        var match   = new #{MatchData}._alloc();
        match.$data = result;

        return #{$~ = `match`};
      }
      else {
        return #{$~ = nil};
      }
    }
  end

  def to_s
    `this.source`
  end
end
