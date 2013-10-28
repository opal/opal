class Time
  include Comparable

  %x{
    var days_of_week = #{%w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday]},
        short_days   = #{%w[Sun Mon Tue Wed Thu Fri Sat]},
        short_months = #{%w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]},
        long_months  = #{%w[January Febuary March April May June July August September October November December]};
  }

  def self.at(seconds, frac = 0)
    `new Date(seconds * 1000 + frac)`
  end

  def self.new(year = undefined, month = undefined, day = undefined, hour = undefined, minute = undefined, second = undefined, utc_offset = undefined)
    %x{
      switch (arguments.length) {
        case 1:
          return new Date(year, 0);

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
          #{raise NotImplementedError};

        default:
          return new Date();
      }
    }
  end

  def self.local(year, month = nil, day = nil, hour = nil, minute = nil, second = nil, millisecond = nil)
    if `arguments.length === 10`
      %x{
        var args = $slice.call(arguments).reverse();

        second = args[9];
        minute = args[8];
        hour   = args[7];
        day    = args[6];
        month  = args[5];
        year   = args[4];
      }
    end

    year = year.kind_of?(String) ? year.to_i : Opal.coerce_to(year, Integer, :to_int)

    month = month.kind_of?(String) ? month.to_i : Opal.coerce_to(month || 1, Integer, :to_int)

    unless month.between?(1, 12)
      raise ArgumentError, "month out of range: #{month}"
    end

    day = day.kind_of?(String) ? day.to_i : Opal.coerce_to(day || 1, Integer, :to_int)

    unless day.between?(1, 31)
      raise ArgumentError, "day out of range: #{day}"
    end

    hour = hour.kind_of?(String) ? hour.to_i : Opal.coerce_to(hour || 0, Integer, :to_int)

    unless hour.between?(0, 24)
      raise ArgumentError, "hour out of range: #{hour}"
    end

    minute = minute.kind_of?(String) ? minute.to_i : Opal.coerce_to(minute || 0, Integer, :to_int)

    unless minute.between?(0, 59)
      raise ArgumentError, "minute out of range: #{minute}"
    end

    second = second.kind_of?(String)  ? second.to_i : Opal.coerce_to(second || 0, Integer, :to_int)

    unless second.between?(0, 59)
      raise ArgumentError, "second out of range: #{second}"
    end

    new(*[year, month, day, hour, minute, second].compact)
  end

  def self.gm(year, month = undefined, day = undefined, hour = undefined, minute = undefined, second = undefined, utc_offset = undefined)
    raise TypeError, 'missing year (got nil)' if year.nil?

    %x{
      switch (arguments.length) {
        case 1:
          return new Date(Date.UTC(year, 0));

        case 2:
          return new Date(Date.UTC(year, month - 1));

        case 3:
          return new Date(Date.UTC(year, month - 1, day));

        case 4:
          return new Date(Date.UTC(year, month - 1, day, hour));

        case 5:
          return new Date(Date.UTC(year, month - 1, day, hour, minute));

        case 6:
          return new Date(Date.UTC(year, month - 1, day, hour, minute, second));

        case 7:
          #{raise NotImplementedError};
      }
    }
  end

  class << self
    alias mktime local
    alias utc gm
  end

  def self.now
    `new Date()`
  end

  def +(other)
    if Time === other
      raise TypeError, "time + time?"
    end

    other = Opal.coerce_to other, Integer, :to_int

    `new Date(self.getTime() + (other * 1000))`
  end

  def -(other)
    if Time === other
      `(self.getTime() - other.getTime()) / 1000;`
    else
      other = Opal.coerce_to other, Integer, :to_int

      `new Date(self.getTime() - (other * 1000))`
    end
  end

  def <=>(other)
    to_f <=> other.to_f
  end

  def ==(other)
    `#{to_f} === #{other.to_f}`
  end

  def day
    `self.getDate()`
  end

  def yday
    %x{
      // http://javascript.about.com/library/bldayyear.htm
      var onejan = new Date(self.getFullYear(), 0, 1);
      return Math.ceil((self - onejan) / 86400000);
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
    %x{
      var string = self.toString(),
          result;

      if (string.indexOf('(') == -1) {
        result = string.match(/[A-Z]{3,4}/)[0];
      }
      else {
        result = string.match(/\\([^)]+\\)/)[0].match(/[A-Z]/g).join('');
      }

      if (result == "GMT" && /(GMT\\W*\\d{4})/.test(string)) {
        return RegExp.$1;
      }
      else {
        return result;
      }
    }
  end

  def gmt_offset
    `-self.getTimezoneOffset() * 60`
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
          case 'D': return #{`d`.strftime('%m/%d/%y')};
          case 'F': return #{`d`.strftime('%Y-%m-%d')};
          case 'v': return #{`d`.strftime('%e-%^b-%4Y')};
          case 'x': return #{`d`.strftime('%D')};
          case 'X': return #{`d`.strftime('%T')};
          case 'r': return #{`d`.strftime('%I:%M:%S %p')};
          case 'R': return #{`d`.strftime('%H:%M')};
          case 'T': return #{`d`.strftime('%H:%M:%S')};
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
