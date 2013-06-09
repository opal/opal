days_of_week = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
short_days = %w[Sun Mon Tue Wed Thu Fri Sat]
short_months = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]
long_months = %w[January Febuary March April May June July August September October November December]

class Time
  include Comparable

  def self.at(seconds, frac = 0)
    `new Date(seconds * 1000 + frac)`
  end

  def self.new(year = undefined, month = undefined, day = undefined, hour = undefined, minute = undefined, second = undefined, millisecond = undefined)
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

  def self.parse(str)
    `Date.parse(str)`
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

  def day
    `#{self}.getDate()`
  end

  def eql?(other)
    other.is_a?(Time) && (self <=> other).zero?
  end

  def friday?
    `#{self}.getDay() === 5`
  end

  def hour
    `#{self}.getHours()`
  end

  def inspect
    `#{self}.toString()`
  end

  alias mday day

  def min
    `#{self}.getMinutes()`
  end

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

  def sec
    `#{self}.getSeconds()`
  end

  def strftime(format = '')
    %x{
      var d = #{self};

      return format.replace(/%(-?.)/g, function(full, m) {
        switch (m) {
          case 'a': return short_days[d.getDay()];
          case 'A': return days_of_week[d.getDay()];
          case 'b': return short_months[d.getMonth()];
          case 'B': return long_months[d.getMonth()];
          case '-d': return d.getDate();
          case 'Y': return d.getFullYear();
          default: return m ;
        }
      });
    }
  end

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

  alias to_s inspect

  def tuesday?
    `#{self}.getDay() === 2`
  end

  def wday
    `#{self}.getDay()`
  end

  def wednesday?
    `#{self}.getDay() === 3`
  end

  def year
    `#{self}.getFullYear()`
  end

  def to_n
    self
  end
end
