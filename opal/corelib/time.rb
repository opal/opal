require 'corelib/comparable'

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
          return new Date(year, month - 1, day, hour, minute, second);

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
      if (month > 12 || day > 31 || hour > 24 || minute > 59 || second > 59) {
        #{raise ArgumentError};
      }

      var date = new Date(Date.UTC(year, (month || 1) - 1, (day || 1), (hour || 0), (minute || 0), (second || 0)));
      date.tz_offset = 0
      return date;
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

    %x{
      var result = new Date(self.getTime() + (other * 1000));
      result.tz_offset = self.tz_offset;
      return result;
    }
  end

  def -(other)
    if Time === other
      `(self.getTime() - other.getTime()) / 1000`
    else
      other = Opal.coerce_to other, Integer, :to_int

      %x{
        var result = new Date(self.getTime() - (other * 1000));
        result.tz_offset = self.tz_offset;
        return result;
      }
    end
  end

  def <=>(other)
    to_f <=> other.to_f
  end

  def ==(other)
    `#{to_f} === #{other.to_f}`
  end

  def asctime
    strftime '%a %b %e %H:%M:%S %Y'
  end

  alias ctime asctime

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
    `self.getDay() === 5`
  end

  def hour
    `self.getHours()`
  end

  def inspect
    if utc?
      strftime '%Y-%m-%d %H:%M:%S UTC'
    else
      strftime '%Y-%m-%d %H:%M:%S %z'
    end
  end

  alias mday day

  def min
    `self.getMinutes()`
  end

  def mon
    `self.getMonth() + 1`
  end

  def monday?
    `self.getDay() === 1`
  end

  alias month mon

  def saturday?
    `self.getDay() === 6`
  end

  def sec
    `self.getSeconds()`
  end

  def usec
    warn 'Microseconds are not supported'
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
        result = string.match(/\([^)]+\)/)[0].match(/[A-Z]/g).join('');
      }

      if (result == "GMT" && /(GMT\W*\d{4})/.test(string)) {
        return RegExp.$1;
      }
      else {
        return result;
      }
    }
  end

  def getgm
    %x{
      var result = new Date(self.getTime());
      result.tz_offset = 0;
      return result;
    }
  end

  def gmt?
    `self.tz_offset == 0`
  end

  def gmt_offset
    `-self.getTimezoneOffset() * 60`
  end

  def strftime(format)
    %x{
      return format.replace(/%([\-_#^0]*:{0,2})(\d+)?([EO]*)(.)/g, function(full, flags, width, _, conv) {
        var result = "",
            width  = parseInt(width),
            zero   = flags.indexOf('0') !== -1,
            pad    = flags.indexOf('-') === -1,
            blank  = flags.indexOf('_') !== -1,
            upcase = flags.indexOf('^') !== -1,
            invert = flags.indexOf('#') !== -1,
            colons = (flags.match(':') || []).length;

        if (zero && blank) {
          if (flags.indexOf('0') < flags.indexOf('_')) {
            zero = false;
          }
          else {
            blank = false;
          }
        }

        switch (conv) {
          case 'Y':
            result += self.getFullYear();
            break;

          case 'C':
            zero    = !blank;
            result += Match.round(self.getFullYear() / 100);
            break;

          case 'y':
            zero    = !blank;
            result += (self.getFullYear() % 100);
            break;

          case 'm':
            zero    = !blank;
            result += (self.getMonth() + 1);
            break;

          case 'B':
            result += long_months[self.getMonth()];
            break;

          case 'b':
          case 'h':
            blank   = !zero;
            result += short_months[self.getMonth()];
            break;

          case 'd':
            zero    = !blank
            result += self.getDate();
            break;

          case 'e':
            blank   = !zero
            result += self.getDate();
            break;

          case 'j':
            result += #{yday};
            break;

          case 'H':
            zero    = !blank;
            result += self.getHours();
            break;

          case 'k':
            blank   = !zero;
            result += self.getHours();
            break;

          case 'I':
            zero    = !blank;
            result += (self.getHours() % 12 || 12);
            break;

          case 'l':
            blank   = !zero;
            result += (self.getHours() % 12 || 12);
            break;

          case 'P':
            result += (self.getHours() >= 12 ? "pm" : "am");
            break;

          case 'p':
            result += (self.getHours() >= 12 ? "PM" : "AM");
            break;

          case 'M':
            zero    = !blank;
            result += self.getMinutes();
            break;

          case 'S':
            zero    = !blank;
            result += self.getSeconds();
            break;

          case 'L':
            zero    = !blank;
            width   = isNaN(width) ? 3 : width;
            result += self.getMilliseconds();
            break;

          case 'N':
            width   = isNaN(width) ? 9 : width;
            result += #{`self.getMilliseconds().toString()`.rjust(3, '0')};
            result  = #{`result`.ljust(`width`, '0')};
            break;

          case 'z':
            var offset  = self.getTimezoneOffset(),
                hours   = Math.floor(Math.abs(offset) / 60),
                minutes = Math.abs(offset) % 60;

            result += offset < 0 ? "+" : "-";
            result += hours < 10 ? "0" : "";
            result += hours;

            if (colons > 0) {
              result += ":";
            }

            result += minutes < 10 ? "0" : "";
            result += minutes;

            if (colons > 1) {
              result += ":00";
            }

            break;

          case 'Z':
            result += #{zone};
            break;

          case 'A':
            result += days_of_week[self.getDay()];
            break;

          case 'a':
            result += short_days[self.getDay()];
            break;

          case 'u':
            result += (self.getDay() + 1);
            break;

          case 'w':
            result += self.getDay();
            break;

          // TODO: week year
          // TODO: week number

          case 's':
            result += parseInt(self.getTime() / 1000)
            break;

          case 'n':
            result += "\n";
            break;

          case 't':
            result += "\t";
            break;

          case '%':
            result += "%";
            break;

          case 'c':
            result += #{strftime('%a %b %e %T %Y')};
            break;

          case 'D':
          case 'x':
            result += #{strftime('%m/%d/%y')};
            break;

          case 'F':
            result += #{strftime('%Y-%m-%d')};
            break;

          case 'v':
            result += #{strftime('%e-%^b-%4Y')};
            break;

          case 'r':
            result += #{strftime('%I:%M:%S %p')};
            break;

          case 'R':
            result += #{strftime('%H:%M')};
            break;

          case 'T':
          case 'X':
            result += #{strftime('%H:%M:%S')};
            break;

          default:
            return full;
        }

        if (upcase) {
          result = result.toUpperCase();
        }

        if (invert) {
          result = result.replace(/[A-Z]/, function(c) { c.toLowerCase() }).
                          replace(/[a-z]/, function(c) { c.toUpperCase() });
        }

        if (pad && (zero || blank)) {
          result = #{`result`.rjust(`isNaN(width) ? 2 : width`, `blank ? " " : "0"`)};
        }

        return result;
      });
    }
  end

  def sunday?
    `self.getDay() === 0`
  end

  def thursday?
    `self.getDay() === 4`
  end

  def to_a
    [sec, min, hour, day, month, year, wday, yday, isdst, zone]
  end

  def to_f
    `self.getTime() / 1000`
  end

  def to_i
    `parseInt(self.getTime() / 1000)`
  end

  alias to_s inspect

  def tuesday?
    `self.getDay() === 2`
  end

  alias utc? gmt?

  def utc_offset
    `self.getTimezoneOffset() * -60`
  end

  def wday
    `self.getDay()`
  end

  def wednesday?
    `self.getDay() === 3`
  end

  def year
    `self.getFullYear()`
  end
end
