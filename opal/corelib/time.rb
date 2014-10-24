require 'corelib/comparable'

class Time < `Date`
  include Comparable

  %x{
    var days_of_week = #{%w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday]},
        short_days   = #{%w[Sun Mon Tue Wed Thu Fri Sat]},
        short_months = #{%w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]},
        long_months  = #{%w[January February March April May June July August September October November December]};
  }

  def self.at(seconds, frac = undefined)
    %x{
      var result;

      if (#{Time === seconds}) {
        if (frac !== undefined) {
          #{raise TypeError, "can't convert Time into an exact number"}
        }
        result = new Date(seconds.getTime());
        result.is_utc = seconds.is_utc;
        return result;
      }

      if (!seconds.$$is_number) {
        seconds = #{Opal.coerce_to!(seconds, Integer, :to_int)};
      }

      if (frac === undefined) {
        return new Date(seconds * 1000);
      }

      if (!frac.$$is_number) {
        frac = #{Opal.coerce_to!(frac, Integer, :to_int)};
      }

      return new Date(seconds * 1000 + (frac / 1000));
    }
  end

  %x{
    function time_params(year, month, day, hour, min, sec) {
      if (year.$$is_string) {
        year = parseInt(year, 10);
      } else {
        year = #{Opal.coerce_to!(`year`, Integer, :to_int)};
      }

      if (month === nil) {
        month = 1;
      } else if (!month.$$is_number) {
        if (#{`month`.respond_to?(:to_str)}) {
          month = #{`month`.to_str};
          switch (month.toLowerCase()) {
          case 'jan': month =  1; break;
          case 'feb': month =  2; break;
          case 'mar': month =  3; break;
          case 'apr': month =  4; break;
          case 'may': month =  5; break;
          case 'jun': month =  6; break;
          case 'jul': month =  7; break;
          case 'aug': month =  8; break;
          case 'sep': month =  9; break;
          case 'oct': month = 10; break;
          case 'nov': month = 11; break;
          case 'dec': month = 12; break;
          default: month = #{`month`.to_i};
          }
        } else {
          month = #{Opal.coerce_to!(`month`, Integer, :to_int)};
        }
      }

      if (month < 1 || month > 12) {
        #{raise ArgumentError, "month out of range: #{`month`}"}
      }
      month = month - 1;

      if (day === nil) {
        day = 1;
      } else if (day.$$is_string) {
        day = parseInt(day, 10);
      } else {
        day = #{Opal.coerce_to!(`day`, Integer, :to_int)};
      }

      if (day < 1 || day > 31) {
        #{raise ArgumentError, "day out of range: #{`day`}"}
      }

      if (hour === nil) {
        hour = 0;
      } else if (hour.$$is_string) {
        hour = parseInt(hour, 10);
      } else {
        hour = #{Opal.coerce_to!(`hour`, Integer, :to_int)};
      }

      if (hour < 0 || hour > 24) {
        #{raise ArgumentError, "hour out of range: #{`hour`}"}
      }

      if (min === nil) {
        min = 0;
      } else if (min.$$is_string) {
        min = parseInt(min, 10);
      } else {
        min = #{Opal.coerce_to!(`min`, Integer, :to_int)};
      }

      if (min < 0 || min > 59) {
        #{raise ArgumentError, "min out of range: #{`min`}"}
      }

      if (sec === nil) {
        sec = 0;
      } else if (!sec.$$is_number) {
        if (sec.$$is_string) {
          sec = parseInt(sec, 10);
        } else {
          sec = #{Opal.coerce_to!(`sec`, Integer, :to_int)};
        }
      }

      if (sec < 0 || sec > 60) {
        #{raise ArgumentError, "sec out of range: #{`sec`}"}
      }

      return [year, month, day, hour, min, sec];
    }
  }

  def self.new(year = undefined, month = nil, day = nil, hour = nil, min = nil, sec = nil, utc_offset = nil)
    %x{
      var args, result;

      if (year === undefined) {
        return new Date();
      }

      if (utc_offset !== nil) {
        #{raise ArgumentError, 'Opal does not support explicitly specifying UTC offset for Time'}
      }

      args  = time_params(year, month, day, hour, min, sec);
      year  = args[0];
      month = args[1];
      day   = args[2];
      hour  = args[3];
      min   = args[4];
      sec   = args[5];

      result = new Date(year, month, day, hour, min, 0, sec * 1000);
      if (year < 100) {
        result.setFullYear(year);
      }
      return result;
    }
  end

  def self.local(year, month = nil, day = nil, hour = nil, min = nil, sec = nil, millisecond = nil)
    %x{
      var args, result;

      if (arguments.length === 10) {
        args  = $slice.call(arguments);
        year  = args[5];
        month = args[4];
        day   = args[3];
        hour  = args[2];
        min   = args[1];
        sec   = args[0];
      }

      args  = time_params(year, month, day, hour, min, sec);
      year  = args[0];
      month = args[1];
      day   = args[2];
      hour  = args[3];
      min   = args[4];
      sec   = args[5];

      result = new Date(year, month, day, hour, min, 0, sec * 1000);
      if (year < 100) {
        result.setFullYear(year);
      }
      return result;
    }
  end

  def self.gm(year, month = nil, day = nil, hour = nil, min = nil, sec = nil, millisecond = nil)
    %x{
      var args, result;

      if (arguments.length === 10) {
        args  = $slice.call(arguments);
        year  = args[5];
        month = args[4];
        day   = args[3];
        hour  = args[2];
        min   = args[1];
        sec   = args[0];
      }

      args  = time_params(year, month, day, hour, min, sec);
      year  = args[0];
      month = args[1];
      day   = args[2];
      hour  = args[3];
      min   = args[4];
      sec   = args[5];

      result = new Date(Date.UTC(year, month, day, hour, min, 0, sec * 1000));
      if (year < 100) {
        result.setUTCFullYear(year);
      }
      result.is_utc = true;
      return result;
    }
  end

  class << self
    alias mktime local
    alias utc gm
  end

  def self.now
    new
  end

  def +(other)
    if Time === other
      raise TypeError, "time + time?"
    end

    %x{
      if (!other.$$is_number) {
        other = #{Opal.coerce_to!(other, Integer, :to_int)};
      }
      var result = new Date(self.getTime() + (other * 1000));
      result.is_utc = self.is_utc;
      return result;
    }
  end

  def -(other)
    if Time === other
      return `(self.getTime() - other.getTime()) / 1000`
    end

    %x{
      if (!other.$$is_number) {
        other = #{Opal.coerce_to!(other, Integer, :to_int)};
      }
      var result = new Date(self.getTime() - (other * 1000));
      result.is_utc = self.is_utc;
      return result;
    }
  end

  def <=>(other)
    if Time === other
      to_f <=> other.to_f
    else
      r = other <=> self
      if r.nil?
        nil
      elsif r > 0
        -1
      elsif r < 0
        1
      else
        0
      end
    end
  end

  def ==(other)
    `#{to_f} === #{other.to_f}`
  end

  def asctime
    strftime '%a %b %e %H:%M:%S %Y'
  end

  alias ctime asctime

  def day
    `self.is_utc ? self.getUTCDate() : self.getDate()`
  end

  def yday
    #http://javascript.about.com/library/bldayyear.htm
    jan01 = Time.new(self.year)
    ((self-jan01) / 86400).ceil
  end

  def isdst
    %x{
      var jan = new Date(self.getFullYear(), 0, 1),
          jul = new Date(self.getFullYear(), 6, 1);
      return self.getTimezoneOffset() < Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset());
    }
  end

  alias dst? isdst

  def dup
    copy = `new Date(self.getTime())`

    copy.copy_instance_variables(self)
    copy.initialize_dup(self)

    copy
  end

  def eql?(other)
    other.is_a?(Time) && (self <=> other).zero?
  end

  def friday?
    `#{wday} == 5`
  end

  def hash
    `'Time:' + self.getTime()`
  end

  def hour
    `self.is_utc ? self.getUTCHours() : self.getHours()`
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
    `self.is_utc ? self.getUTCMinutes() : self.getMinutes()`
  end

  def mon
    `(self.is_utc ? self.getUTCMonth() : self.getMonth()) + 1`
  end

  def monday?
    `#{wday} == 1`
  end

  alias month mon

  def saturday?
    `#{wday} == 6`
  end

  def sec
    `self.is_utc ? self.getUTCSeconds() : self.getSeconds()`
  end

  def succ
    %x{
      var result = new Date(self.getTime() + 1000);
      result.is_utc = self.is_utc;
      return result;
    }
  end

  def usec
    `self.getMilliseconds() * 1000`
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
      result.is_utc = true;
      return result;
    }
  end

  alias getutc getgm

  def gmtime
    %x{
      self.is_utc = true;
      return self;
    }
  end

  alias utc gmtime

  def gmt?
    `self.is_utc === true`
  end

  def gmt_offset
    `-self.getTimezoneOffset() * 60`
  end

  def strftime(format)
    %x{
      return format.replace(/%([\-_#^0]*:{0,2})(\d+)?([EO]*)(.)/g, function(full, flags, width, _, conv) {
        var result = "",
            zero   = flags.indexOf('0') !== -1,
            pad    = flags.indexOf('-') === -1,
            blank  = flags.indexOf('_') !== -1,
            upcase = flags.indexOf('^') !== -1,
            invert = flags.indexOf('#') !== -1,
            colons = (flags.match(':') || []).length;

        width = parseInt(width, 10);

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
            result += #{year};
            break;

          case 'C':
            zero    = !blank;
            result += Math.round(#{year} / 100);
            break;

          case 'y':
            zero    = !blank;
            result += (#{year} % 100);
            break;

          case 'm':
            zero    = !blank;
            result += #{mon};
            break;

          case 'B':
            result += long_months[#{mon} - 1];
            break;

          case 'b':
          case 'h':
            blank   = !zero;
            result += short_months[#{mon} - 1];
            break;

          case 'd':
            zero    = !blank
            result += #{day};
            break;

          case 'e':
            blank   = !zero
            result += #{day};
            break;

          case 'j':
            result += #{yday};
            break;

          case 'H':
            zero    = !blank;
            result += #{hour};
            break;

          case 'k':
            blank   = !zero;
            result += #{hour};
            break;

          case 'I':
            zero    = !blank;
            result += (#{hour} % 12 || 12);
            break;

          case 'l':
            blank   = !zero;
            result += (#{hour} % 12 || 12);
            break;

          case 'P':
            result += (#{hour} >= 12 ? "pm" : "am");
            break;

          case 'p':
            result += (#{hour} >= 12 ? "PM" : "AM");
            break;

          case 'M':
            zero    = !blank;
            result += #{min};
            break;

          case 'S':
            zero    = !blank;
            result += #{sec}
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
            result += days_of_week[#{wday}];
            break;

          case 'a':
            result += short_days[#{wday}];
            break;

          case 'u':
            result += (#{wday} + 1);
            break;

          case 'w':
            result += #{wday};
            break;

          case 'V':
            result += #{cweek_cyear[0].to_s.rjust(2, "0")};
            break;

          case 'G':
            result += #{cweek_cyear[1]};
            break;

          case 'g':
            result += #{cweek_cyear[1][-2..-1]};
            break;

          case 's':
            result += #{to_i};
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
    `#{wday} == 0`
  end

  def thursday?
    `#{wday} == 4`
  end

  def to_a
    [sec, min, hour, day, month, year, wday, yday, isdst, zone]
  end

  def to_f
    `self.getTime() / 1000`
  end

  def to_i
    `parseInt(self.getTime() / 1000, 10)`
  end

  alias to_s inspect

  def tuesday?
    `#{wday} == 2`
  end

  alias tv_sec sec

  alias tv_usec usec

  alias utc? gmt?

  alias gmtoff gmt_offset
  alias utc_offset gmt_offset

  def wday
    `self.is_utc ? self.getUTCDay() : self.getDay()`
  end

  def wednesday?
    `#{wday} == 3`
  end

  def year
    `self.is_utc ? self.getUTCFullYear() : self.getFullYear()`
  end

  def cweek_cyear
    jan01 = Time.new(self.year, 1, 1)
    jan01_wday = jan01.wday
    first_monday = 0
    year = self.year
    if jan01_wday <= 4 && jan01_wday != 0
      #Jan 01 is in the first week of the year
      offset = jan01_wday-1
    else
      #Jan 01 is in the last week of the previous year
      offset = jan01_wday-7-1
      offset = -1 if offset == -8 #Adjust if Jan 01 is a Sunday
    end

    week = ((self.yday+offset)/7.00).ceil

    if week <= 0
      #Get the last week of the previous year
      return Time.new(self.year-1, 12, 31).cweek_cyear
    elsif week == 53
      #Find out whether this is actually week 53 or already week 01 of the following year
      dec31 = Time.new(self.year, 12, 31)
      dec31_wday = dec31.wday
      if dec31_wday <= 3 && dec31_wday != 0
        week = 1
        year += 1
      end
    end

    [week, year]

  end
end
