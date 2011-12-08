class String
  def self.new(str = '')
    str.to_s
  end

  def <(other)
    `self < other`
  end

  def <=(other)
    `self <= other`
  end

  def >(other)
    `self > other`
  end

  def >=(other)
    `self >= other`
  end

  def +(other)
    `self + other`
  end

  def [](index, length)
    `self.substr(index, length)`
  end

  def ==(other)
    `self.valueOf() === other.valueOf()`
  end

  def =~(other)
    `
      if (typeof other === 'string') rb_raise(RubyTypeError, 'string given');
      return other.m$match$(null, self);
    `
  end

  def <=>(other)
    `
      if (typeof other !== 'string') return nil;
      return self > other ? 1 : (self < other ? -1 : 0);
    `
  end

  def capitalize
    `self.charAt(0).toUpperCase() + self.substr(1).toLowerCase()`
  end

  def casecmp(other)
    `
      if (typeof other !== 'string') return other;
      var a = self.toLowerCase(), b = other.toLowerCase();
      return a > b ? 1 : (a < b ? -1 : 0);
    `
  end

  def downcase
    `self.toLowerCase()`
  end

  def end_with?(suffix)
    `self.lastIndexOf(suffix) === self.length - suffix.length`
  end

  def empty?
    `self.length === 0`
  end

  def gsub(pattern, replace = undefined, &block)
    `
      var re = pattern.toString();
      re = re.substr(1, re.lastIndexOf('/') - 1);
      re = new RegExp(re, 'g');
      return self.m$sub($iterator, re, replace);
    `
  end

  def hash
    `self.$f + '_' + self`
  end

  def include?(other)
    `self.indexOf(other) !== -1`
  end

  def index(substr)
    `
      var result = self.indexOf(substr);
      return result === -1 ? nil : result
    `
  end

  def inspect
    `rb_string_inspect(self)`
  end

  def intern
    self
  end

  def length
    `self.length`
  end

  def lstrip
    `self.replace(/^\s*/, '')`
  end

  def next
    `String.fromCharCode(self.charCodeAt(0))`
  end

  def reverse
    `self.split('').reverse().join('')`
  end

  def split(split, limit = undefined)
    `self.split(split, limit)`
  end

  def sub(pattern, replace = undefined, &block)
    `
      if (block !== nil) {
        return self.replace(pattern, function(str) {
          return $iterator.call($context, null, str);
        });
      }
      else {
        return self.replace(pattern, replace);
      }
    `
  end

  alias_method :succ, :next

  def to_f
    `parseFloat(self)`
  end

  def to_i(base = 10)
    `parseInt(self, base)`
  end

  def to_proc
    `return function(iter, arg) { return arg['m$' + self](); };`
  end

  def to_s
    `self.toString()`
  end

  alias_method :to_sym, :intern

  def upcase
    `self.toUpperCase()`
  end
end

Symbol = String
