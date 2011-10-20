# encoding: utf-8

class String
  # TODO: mutable thing and whatever
  def self.new(string = '')
    `new String(string)`
  end

  def ==(other)
    `self.valueOf() === other.valueOf()`
  end

  def +(other)
    `return self + other`
  end

  def capitalize
    `self.charAt(0).toUpperCase() + self.substr(1).toLowerCase()`
  end

  def downcase
    `self.toLowerCase()`
  end

  def upcase
    `self.toUpperCase()`
  end

  def inspect
    `VM.si(self)`
  end

  def length
    @length
  end

  def to_sym
    `$rb.Y(self)`
  end

  def intern
    `$rb.Y(self)`
  end

  def reverse
    `self.split('').reverse().join('')`
  end

  def succ
    `String.fromCharCode(self.charCodeAt(0))`
  end

  def [](what, what2 = nil)
    case what
    when Numeric
      if what2.is_a?(Numeric)
        `self.substr(what, what2 < 0 ? self.length + what2 : what2)`
      else
        `self.charAt(idx)`
      end

    when Range
      `self.substr(#{what.begin}, #{what.end < 0} ? self.length + #{what.end} : #{what.end})`

    when Regexp
      `self.match(what)[0]`
    end
  end

  def sub(pattern, replace = nil)
    raise ArgumentError, 'wrong number of arguments (1 for 1..2)' if replace.nil? && !block_given?

    `
      return self.replace(pattern, replace || function (str) {
        return #{yield `str`};
      })
    `
  end

  def gsub(pattern, replace = nil)
    raise ArgumentError, 'wrong number of arguments (1 for 1..2)' if replace.nil? && !block_given?

    `
      var re = pattern.toString();
          re = re.substr(1, re.lastIndexOf('/') - 1);
          re = new RegExp(re, 'g');

      return self.replace(re, replace || function (str) {
        return #{yield `str`}
      });
    `
  end

  def slice(start, finish = undefined)
    `self.substr(start, finish)`
  end

  def split(split, limit = undefined)
    `self.split(split, limit)`
  end

  def <=>(other)
    return unless Object === other && other.is_a?(String)

    if `self > other`    then  1
    elsif `self < other` then -1
    else                       0
    end
  end

  def =~(object)
    raise TypeError, 'type mismatch: String given' if Object === other && other.is_a?(String)

    object =~ self
  end

  def casecmp(other)
    return unless Object === other && other.is_a?(String)

    `
      var a = self.toLowerCase(),
          b = other.toLowerCase();

      if (a > b) {
        return 1;
      }
      else if (a < b) {
        return -1;
      }
      else {
        return 0
      }
    `
  end

  def empty?
    `self.length == 0`
  end

  def end_with?(suffix)
    `self.lastIndexOf(suffix) == self.length - suffix.length`
  end

  def eql?(other)
    `self == other`
  end

  def include?(other)
    `self.indexOf(other) != -1`
  end

  def index(substr)
    `
      var result = self.indexOf(substr);

      return result == -1 ? null : result
    `
  end

  def lstrip
    `self.replace(/^\s*/, '')`
  end

  def to_mutable
    String.new(self)
  end

  def to_i (base=10)
    `parseInt(self, base)`.to_i
  end

  def to_f
    `parseFloat(self)`.to_f
  end

  def to_s
    `self.toString()`
  end
end
