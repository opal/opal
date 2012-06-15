class Time < `Date`
  include Comparable

  # def self.at(seconds, frac = 0)
  #   allocate `seconds * 1000 + frac`
  # end

  # def self.new(year, month, day, hour, minute, second, millisecond)
  #   %x{
  #     switch (arguments.length) {
  #       case 1:
  #         return new Date(year);
  #       case 2:
  #         return new Date(year, month - 1);
  #       case 3:
  #         return new Date(year, month - 1, day);
  #       case 4:
  #         return new Date(year, month - 1, day, hour);
  #       case 5:
  #         return new Date(year, month - 1, day, hour, minute);
  #       case 6:
  #         return new Date(year, month - 1, day, hour, minute, second);
  #       case 7:
  #         return new Date(year, month - 1, day, hour, minute, second, millisecond);
  #       default:
  #         return new Date();
  #     }
  #   }
  # end

  # def self.now
  #   allocate
  # end

  def +(other)
    Time.allocate(self.to_f + other.to_f)
  end

  def -(other)
    Time.allocate(self.to_f - other.to_f)
  end

  def <=>(other)
    to_f <=> other.to_f
  end

  def day
    `this.getDate()`
  end

  def eql?(other)
    other.is_a?(Time) && (self <=> other).zero?
  end

  def friday?
    `this.getDay() === 5`
  end

  def hour
    `this.getHours()`
  end

  alias mday day

  def min
    `this.getMinutes()`
  end

  def mon
    `this.getMonth() + 1`
  end

  def monday?
    `this.getDay() === 1`
  end

  alias month mon

  def saturday?
    `this.getDay() === 6`
  end

  def sec
    `this.getSeconds()`
  end

  def sunday?
    `this.getDay() === 0`
  end

  def thursday?
    `this.getDay() === 4`
  end

  def to_f
    `this.getTime() / 1000`
  end

  def to_i
    `parseInt(this.getTime() / 1000)`
  end

  def tuesday?
    `this.getDay() === 2`
  end

  def wday
    `this.getDay()`
  end

  def wednesday?
    `this.getDay() === 3`
  end

  def year
    `this.getFullYear()`
  end
end