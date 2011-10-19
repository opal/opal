class Regexp
  def self.escape(string)
    `string.replace(/([.*+?^=!:${}()|[\]\/\\])/g, '\\$1')`
  end

  def self.new(string, options = undefined)
    `new RegExp(string, options)`
  end

  def inspect
    `self.toString()`
  end

  def to_s
    `self.source`
  end

  def ==(other)
    `other.constructor == RegExp && self.toString() === other.toString()`
  end

  alias_method :eql?, :==

  def ===(obj)
    `self.test(obj)`
  end

  def =~(string)
    `
      var result = self.exec(string);
      $rb.X      = result;

      return result ? result.index : nil;
    `
  end

  def match(pattern)
    self =~ pattern

    $~
  end
end
