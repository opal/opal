days_of_week = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
short_days = %w[Sun Mon Tue Wed Thu Fri Sat]
short_months = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]
long_months = %w[January Febuary March April May June July August September October November December]

class Time
  include Comparable

  def self.at(seconds, frac = 0)
    `new Date(seconds * 1000 + frac)`
  end

  def self.new(year = undefined, month = undefined, day = undefined, hour = undefined, minute = undefined, second = undefined, utc_offset = undefined)
    %x{
      switch (arguments.length) {
        case 1:  return new Date(year, 0);
        case 2:  return new Date(year, month - 1);
        case 3:  return new Date(year, month - 1, day);
        case 4:  return new Date(year, month - 1, day, hour);
        case 5:  return new Date(year, month - 1, day, hour, minute);
        case 6:  return new Date(year, month - 1, day, hour, minute, second);
        case 7: #{raise NotImplementedError};
        default: return new Date();
      }
    }
  end

  def self.local(year, month = nil, day = nil, hour = nil, minute = nil, second = nil, millisecond = nil)
    if `arguments.length === 10`
      reverse_args = Native::Array.new(`arguments`).to_a

      second      = reverse_args[0]
      minute      = reverse_args[1]
      hour        = reverse_args[2]
      day         = reverse_args[3]
      month       = reverse_args[4]
      year        = reverse_args[5]
      wday        = nil
      yday        = nil
      isdst       = nil
      tz          = nil
      millisecond = nil
    end

    raise TypeError, 'missing year (got nil)' if year.nil?
    year   = year.kind_of?(String)    ? year.to_i   : (year.respond_to?(:to_int)    ? year.to_int   : year)
    day    = day.kind_of?(String)     ? day.to_i    : (day.respond_to?(:to_int)     ? day.to_int    : day)
    hour   = hour.kind_of?(String)    ? hour.to_i   : (hour.respond_to?(:to_int)    ? hour.to_int   : hour)
    minute = minute.kind_of?(String)  ? minute.to_i : (minute.respond_to?(:to_int)  ? minute.to_int : minute)
    month  = month.kind_of?(String)   ? month.to_i  : (month.respond_to?(:to_int)   ? month.to_int  : month)
    second = second.kind_of?(String)  ? second.to_i : (second.respond_to?(:to_int)  ? second.to_int : second)
    millisecond  = millisecond.kind_of?(String)   ? millisecond.to_i  : (millisecond.respond_to?(:to_int)   ? millisecond.to_int  : millisecond)

    raise ArgumentError, "month out of range: #{month.inspect}"   unless month.nil?  || (1..12).include?(month)
    raise ArgumentError, "day out of range: #{day.inspect}"       unless day.nil?    || (1..31).include?(day)
    raise ArgumentError, "hour out of range: #{hour.inspect}"     unless hour.nil?   || (0..24).include?(hour)
    raise ArgumentError, "minute out of range: #{minute.inspect}" unless minute.nil? || (0..59).include?(minute)
    raise ArgumentError, "second out of range: #{second.inspect}" unless second.nil? || (0..59).include?(second)

    args = [year, month, day, hour, minute, second, millisecond].compact!
    new(*args)
  end

  def self.gm(year, month = undefined, day = undefined, hour = undefined, minute = undefined, second = undefined, utc_offset = undefined)
    raise TypeError, 'missing year (got nil)' if year.nil?
    %x{
      switch (arguments.length) {
        case 1: return new Date( Date.UTC(year, 0) );
        case 2: return new Date( Date.UTC(year, month - 1) );
        case 3: return new Date( Date.UTC(year, month - 1, day) );
        case 4: return new Date( Date.UTC(year, month - 1, day, hour) );
        case 5: return new Date( Date.UTC(year, month - 1, day, hour, minute) );
        case 6: return new Date( Date.UTC(year, month - 1, day, hour, minute, second) );
        case 7: #{raise NotImplementedError};
      }
    }
  end

  class << self
    alias :mktime :local
    alias :utc :gm
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

  def ==(other)
    `#{to_f} === #{other.to_f}`
  end

  def day
    `#{self}.getDate()`
  end

  def yday
    %x{
      // http://javascript.about.com/library/bldayyear.htm
      var onejan = new Date(this.getFullYear(),0,1);
      return Math.ceil((this - onejan) / 86400000);
    }
  end

  def isdst
    raise NotImplementedError
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

  def usec
    $stderr.puts 'Microseconds are not supported'
    0
  end

  def zone
    `#{self}.getTimezoneOffset()`.to_s
  end

  def strftime(format = '')
    %x{
      var d = #{self};

      return format.replace(/%(-?.)/g, function(full, m) {
        switch (m) {
          case 'a': return short_days[d.getDay()];
          case '^a': return short_days[d.getDay()].toUpperCase();
          case 'A': return days_of_week[d.getDay()];
          case '^A': return days_of_week[d.getDay()].toUpperCase();
          case 'b': return short_months[d.getMonth()];
          case '^b': return short_months[d.getMonth()].toUpperCase();
          case 'h': return short_months[d.getMonth()];
          case 'B': return long_months[d.getMonth()];
          case '^B': return long_months[d.getMonth()].toUpperCase();
          case 'u': return d.getDay() + 1;
          case 'w': return d.getDay();
          case 'm':
            var month = d.getMonth() + 1;
            return month < 10 ? '0' + month : month;
          case '-m': return d.getMonth() + 1
          case 'd': return (d.getDate() < 10 ? '0' + d.getDate() : d.getDate());
          case '-d': return d.getDate();
          case 'e': return (d.getDate() < 10 ? ' ' + d.getDate() : d.getDate());
          case 'Y': return d.getFullYear();
          case 'C': return Math.round(d.getFullYear() / 100);
          case 'y': return d.getFullYear() % 100;
          case 'H': return (d.getHours() < 10 ? '0' + d.getHours() : d.getHours());
          case 'k': return (d.getHours() < 10 ? ' ' + d.getHours() : d.getHours());
          case 'M': return (d.getMinutes() < 10 ? '0' + d.getMinutes() : d.getMinutes());
          case 'S': return (d.getSeconds() < 10 ? '0' + d.getSeconds() : d.getSeconds());
          case 's': return d.getTime();
          case 'n': return "\\n";
          case 't': return "\\t";
          case '%': return "%";
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

  def to_a
    [sec, min, hour, day, month, year, wday, yday, isdst, zone]
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
