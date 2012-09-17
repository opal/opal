class Time < `Date`
  include Comparable

  def self.at(seconds, frac = 0)
    `new Date(seconds * 1000 + frac)`
  end

  def self.new(year, month, day, hour, minute, second, millisecond)
    %x{
      switch (arguments.length) {
        case 1:
          return new Date(year);
        case 2:
          return new Date(year, month - 1);
        case 3:
          return new Date(year, month - 1, day);
        case 4:
          return new Date(year, month - 1, day, hour);
        case 5:
          return new Date(year, month - 1, day, hour, minute);
        case 6:
          return new Date(year, month - 1, day, hour, minute, second);
        case 7:
          return new Date(year, month - 1, day, hour, minute, second, millisecond);
        default:
          return new Date();
      }
    }
  end

  def self.now
    `new Date()`
  end

  def +(other)
    Time.allocate(self.to_f + other.to_f)
  end

  def -(other)
    Time.allocate(self.to_f - other.to_f)
  end

  def <=>(other)
    to_f <=> other.to_f
  end

  alias_native :day, :getDate

  def eql?(other)
    other.is_a?(Time) && (self <=> other).zero?
  end

  def friday?
    `#{self}.getDay() === 5`
  end

  alias_native :hour, :getHours

  alias mday day

  alias_native :min, :getMinutes

  def mon
    `#{self}.getMonth() + 1`
  end

  def monday?
    `#{self}.getDay() === 1`
  end

  alias month mon

  def saturday?
    `#{self}.getDay() === 6`
  end

  alias_native :sec, :getSeconds

  def sunday?
    `#{self}.getDay() === 0`
  end

  def thursday?
    `#{self}.getDay() === 4`
  end

  def to_f
    `#{self}.getTime() / 1000`
  end

  def to_i
    `parseInt(#{self}.getTime() / 1000)`
  end

  def tuesday?
    `#{self}.getDay() === 2`
  end

  alias_native :wday, :getDay

  def wednesday?
    `#{self}.getDay() === 3`
  end

  alias_native :year, :getFullYear
end