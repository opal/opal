class Regexp
  def self.escape(string)
    `string.replace(/([.*+?^=!:${}()|[\]\\/\\])/g, '\\$1')`
  end

  def self.new(string, options = undefined)
    `new RegExp(string, options)`
  end

  def ==(other)
    `other.constructor == RegExp && self.toString() === other.toString()`
  end

  def ===(obj)
    `self.test(obj)`
  end

  def =~(string)
    %x{
      var result       = self.exec(string);
      $opal.match_data = result;

      return result ? result.index : nil;
    }
  end

  alias_method :eql?, :==

  def inspect
    `self.toString()`
  end

  def match(pattern)
    self =~ pattern

    $~
  end

  def to_native
    self
  end

  def to_s
    `self.source`
  end
end
