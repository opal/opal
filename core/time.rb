class Time
  include Comparable

  def self.at(seconds, frac = 0)
    result = allocate
    `result.time = new Date(seconds * 1000 + frac)`
    result
  end

  def self.now
    result = allocate
    `result.time = new Date()`
    result
  end

  def initialize
    `this.time = new Date()`
  end

  def +(other)
    %x{
      var res = #{Time.allocate};
      res.time = new Date(#{to_f + other.to_f});
      return res;
    }
  end

  def -(other)
    %x{
      var res = #{Time.allocate};
      res.time = new Date(#{to_f - other.to_f});
      return res;
    }
  end

  def <=>(other)
    to_f <=> other.to_f
  end

  def day
    `this.time.getDate()`
  end

  def eql?(other)
    other.is_a?(Time) && (self <=> other).zero?
  end

  def friday?
    `this.time.getDay() === 5`
  end

  def hour
    `this.time.getHours()`
  end

  alias mday day

  def min
    `this.time.getMinutes()`
  end

  def mon
    `this.time.getMonth() + 1`
  end

  def monday?
    `this.time.getDay() === 1`
  end

  alias month mon

  def saturday?
    `this.time.getDay() === 6`
  end

  def sec
    `this.time.getSeconds()`
  end

  def sunday?
    `this.time.getDay() === 0`
  end

  def thursday?
    `this.time.getDay() === 4`
  end

  def to_f
    `this.time.getTime() / 1000`
  end

  def to_i
    `parseInt(this.time.getTime() / 1000)`
  end

  def tuesday?
    `this.time.getDay() === 2`
  end

  def wday
    `this.time.getDay()`
  end

  def wednesday?
    `this.time.getDay() === 3`
  end

  def year
    `this.time.getFullYear()`
  end
end
