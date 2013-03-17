days_of_week = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
short_days = %w[Sun Mon Tue Wed Thu Fri Sat]
short_months = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]
long_months = %w[January Febuary March April May June July August September October November December]

class Time < `Date`
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

  alias_native :inspect, :toString

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

  alias_native :wday, :getDay

  def wednesday?
    `#{self}.getDay() === 3`
  end

  alias_native :year, :getFullYear
end
