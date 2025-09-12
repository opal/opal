# helpers: slice, deny_frozen_access
# backtick_javascript: true
# use_strict: true

require 'corelib/comparable'

class ::Time < `Date`
  include ::Comparable

  %x{
    var days_of_week = #{%w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday Sunday]},
        short_days   = #{%w[Sun Mon Tue Wed Thu Fri Sat]},
        short_months = #{%w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]},
        long_months  = #{%w[January February March April May June July August September October November December]};
  }

  def self.at(seconds, frac = undefined, unit = :microsecond)
    %x{
      var result;

      if (#{::Time === seconds}) {
        if (frac !== undefined) {
          #{::Kernel.raise ::TypeError, "can't convert Time into an exact number"}
        }
        result = new Date(seconds.getTime());
        result.timezone = seconds.timezone;
        return result;
      }

      if (!seconds.$$is_number) {
        seconds = #{::Opal.coerce_to!(seconds, ::Integer, :to_int)};
      }

      if (frac === undefined) {
        return new Date(seconds * 1000);
      }

      if (!frac.$$is_number) {
        frac = #{::Opal.coerce_to!(frac, ::Integer, :to_int)};
      }

      let value;
      switch (unit) {
        case "millisecond": value = seconds * 1000 + frac; break;
        case "microsecond": value = seconds * 1000 + frac / 1_000; break;
        case "nanosecond":  value = seconds * 1000 + frac / 1_000_000; break;
        default:
          #{::Kernel.raise ::ArgumentError, "unexpected unit: #{unit}"}
      }
      return new Date(value);
    }
  end

  %x{
    function time_params(year, month, day, hour, min, sec) {
      if (year.$$is_string) {
        year = parseInt(year, 10);
      } else {
        year = #{::Opal.coerce_to!(`year`, ::Integer, :to_int)};
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
          month = #{::Opal.coerce_to!(`month`, ::Integer, :to_int)};
        }
      }

      if (month < 1 || month > 12) {
        #{::Kernel.raise ::ArgumentError, "month out of range: #{`month`}"}
      }
      month = month - 1;

      if (day === nil) {
        day = 1;
      } else if (day.$$is_string) {
        day = parseInt(day, 10);
      } else {
        day = #{::Opal.coerce_to!(`day`, ::Integer, :to_int)};
      }

      if (day < 1 || day > 31) {
        #{::Kernel.raise ::ArgumentError, "day out of range: #{`day`}"}
      }

      if (hour === nil) {
        hour = 0;
      } else if (hour.$$is_string) {
        hour = parseInt(hour, 10);
      } else {
        hour = #{::Opal.coerce_to!(`hour`, ::Integer, :to_int)};
      }

      if (hour < 0 || hour > 24) {
        #{::Kernel.raise ::ArgumentError, "hour out of range: #{`hour`}"}
      }

      if (min === nil) {
        min = 0;
      } else if (min.$$is_string) {
        min = parseInt(min, 10);
      } else {
        min = #{::Opal.coerce_to!(`min`, ::Integer, :to_int)};
      }

      if (min < 0 || min > 59) {
        #{::Kernel.raise ::ArgumentError, "min out of range: #{`min`}"}
      }

      if (sec === nil) {
        sec = 0;
      } else if (!sec.$$is_number) {
        if (sec.$$is_string) {
          sec = parseInt(sec, 10);
        } else {
          sec = #{::Opal.coerce_to!(`sec`, ::Integer, :to_int)};
        }
      }

      if (sec < 0 || sec > 60) {
        #{::Kernel.raise ::ArgumentError, "sec out of range: #{`sec`}"}
      }

      return [year, month, day, hour, min, sec];
    }
  }

  def self.new(year = undefined, month = nil, day = nil, hour = nil, min = nil, sec = nil, utc_offset = nil)
    %x{
      var args, result, timezone, utc_date;

      if (year === undefined) {
        return new Date();
      }

      args  = time_params(year, month, day, hour, min, sec);
      year  = args[0];
      month = args[1];
      day   = args[2];
      hour  = args[3];
      min   = args[4];
      sec   = args[5];

      if (utc_offset === nil) {
        result = new Date(year, month, day, hour, min, 0, sec * 1000);
        if (year < 100) {
          result.setFullYear(year);
        }
        return result;
      }

      timezone = #{_parse_offset(utc_offset)};
      utc_date = new Date(Date.UTC(year, month, day, hour, min, 0, sec * 1000));
      if (year < 100) {
        utc_date.setUTCFullYear(year);
      }

      result = new Date(utc_date.getTime() - timezone * 3600000);
      result.timezone = timezone;

      return result;
    }
  end

  # @private
  def self._parse_offset(utc_offset)
    %x{
      var timezone;
      if (utc_offset.$$is_string) {
        if (utc_offset == 'UTC') {
          timezone = 0;
        }
        else if(/^[+-]\d\d:[0-5]\d$/.test(utc_offset)) {
          var sign, hours, minutes;
          sign = utc_offset[0];
          hours = +(utc_offset[1] + utc_offset[2]);
          minutes = +(utc_offset[4] + utc_offset[5]);

          timezone = (sign == '-' ? -1 : 1) * (hours + minutes / 60);
        }
        else {
          // Unsupported: "A".."I","K".."Z"
          #{::Kernel.raise ::ArgumentError, %'"+HH:MM", "-HH:MM", "UTC" expected for utc_offset: #{utc_offset}'}
        }
      }
      else if (utc_offset.$$is_number) {
        timezone = utc_offset / 3600;
      }
      else {
        #{::Kernel.raise ::ArgumentError, "Opal doesn't support other types for a timezone argument than Integer and String"}
      }
      return timezone;
    }
  end

  def self.local(year, month = nil, day = nil, hour = nil, min = nil, sec = nil, millisecond = nil, _dummy1 = nil, _dummy2 = nil, _dummy3 = nil)
    # The _dummy args are there only because the MRI version accepts up to 10 arguments
    %x{
      var args, result;

      if (arguments.length === 10) {
        args  = $slice(arguments);
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

  def self.gm(year, month = nil, day = nil, hour = nil, min = nil, sec = nil, millisecond = nil, _dummy1 = nil, _dummy2 = nil, _dummy3 = nil)
    # The _dummy args are there only because the MRI version accepts up to 10 arguments
    %x{
      var args, result;

      if (arguments.length === 10) {
        args  = $slice(arguments);
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
      result.timezone = 0;
      return result;
    }
  end

  def self.now
    new
  end

  def +(other)
    if ::Time === other
      ::Kernel.raise ::TypeError, 'time + time?'
    end

    %x{
      if (!other.$$is_number) {
        other = #{::Opal.coerce_to!(other, ::Integer, :to_int)};
      }
      var result = new Date(self.getTime() + (other * 1000));
      result.timezone = self.timezone;
      return result;
    }
  end

  def -(other)
    if ::Time === other
      return `(self.getTime() - other.getTime()) / 1000`
    end

    %x{
      if (!other.$$is_number) {
        other = #{::Opal.coerce_to!(other, ::Integer, :to_int)};
      }
      var result = new Date(self.getTime() - (other * 1000));
      result.timezone = self.timezone;
      return result;
    }
  end

  def <=>(other)
    if ::Time === other
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
    ::Time === other && `#{to_f} === #{other.to_f}`
  end

  def asctime
    strftime '%a %b %e %H:%M:%S %Y'
  end

  [
    [:year, 'getFullYear', 'getUTCFullYear'],
    [:mon, 'getMonth', 'getUTCMonth', 1],
    [:wday, 'getDay', 'getUTCDay'],
    [:day, 'getDate', 'getUTCDate'],
    [:hour, 'getHours', 'getUTCHours'],
    [:min, 'getMinutes', 'getUTCMinutes'],
    [:sec, 'getSeconds', 'getUTCSeconds'],
  ].each do |method, getter, utcgetter, difference = 0|
    define_method method do
      %x{
        return difference + ((self.timezone != null) ?
          (new Date(self.getTime() + self.timezone * 3600000))[utcgetter]() :
          self[getter]())
      }
    end
  end

  def yday
    # http://javascript.about.com/library/bldayyear.htm
    # also see moment.js implementation: http://git.io/vCKNE

    start_of_year = Time.new(year).to_i
    start_of_day  = Time.new(year, month, day).to_i
    one_day       = 86_400

    ((start_of_day - start_of_year) / one_day).round + 1
  end

  def isdst
    %x{
      var jan = new Date(self.getFullYear(), 0, 1),
          jul = new Date(self.getFullYear(), 6, 1);
      return self.getTimezoneOffset() < Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset());
    }
  end

  def dup
    copy = `new Date(self.getTime())`

    copy.copy_instance_variables(self)
    copy.initialize_dup(self)

    copy
  end

  def eql?(other)
    other.is_a?(::Time) && (self <=> other).zero?
  end

  [
    [:sunday?, 0],
    [:monday?, 1],
    [:tuesday?, 2],
    [:wednesday?, 3],
    [:thursday?, 4],
    [:friday?, 5],
    [:saturday?, 6]
  ].each do |method, weekday|
    define_method method do
      `#{wday} === weekday`
    end
  end

  def hash
    [::Time, `self.getTime()`].hash
  end

  def inspect
    str = if utc?
            strftime '%Y-%m-%d %H:%M:%S UTC'
          else
            strftime '%Y-%m-%d %H:%M:%S %z'
          end
    `Opal.str(str, Opal.Encoding.US_ASCII)`
  end

  def succ
    %x{
      var result = new Date(self.getTime() + 1000);
      result.timezone = self.timezone;
      return result;
    }
  end

  def nsec
    `self.getMilliseconds() * 1000000`
  end

  def usec
    `self.getMilliseconds() * 1000`
  end

  def zone
    %x{
      if (self.timezone === 0) return "UTC";
      else if (self.timezone != null) return nil;

      var string = self.toString(),
          result;

      if (string.indexOf('(') == -1) {
        result = string.match(/[A-Z]{3,4}/)[0];
      }
      else {
        result = string.match(/\((.+)\)(?:\s|$)/)[1]
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
      result.timezone = 0;
      return result;
    }
  end

  def gmtime
    %x{
      if (self.timezone !== 0) {
        $deny_frozen_access(self);
        self.timezone = 0;
      }
      return self;
    }
  end

  def gmt?
    `self.timezone === 0`
  end

  def gmt_offset
    `(self.timezone != null) ? self.timezone * 60 : -self.getTimezoneOffset() * 60`
  end

  def strftime(format)
    %x{
      return format.replace(/%([\-_#^0]*:{0,2})(\d+)?([EO]*)(.)/g, function(full, flags, width, _, conv) {
        var result = "", jd, c, s,
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
            zero    = !blank;
            width   = isNaN(width) ? 3 : width;
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
            var offset  = (self.timezone == null) ? self.getTimezoneOffset() : (-self.timezone * 60),
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
            result += #{cweek_cyear[0].to_s.rjust(2, '0')};
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

          // Non-standard: JIS X 0301 date format
          case 'J':
            jd = #{to_date.jd};
            if (jd < 2405160) {
              result += #{strftime('%Y-%m-%d')};
              break;
            }
            else if (jd < 2419614)
              c = 'M', s = 1867;
            else if (jd < 2424875)
              c = 'T', s = 1911;
            else if (jd < 2447535)
              c = 'S', s = 1925;
            else if (jd < 2458605)
              c = 'H', s = 1988;
            else
              c = 'R', s = 2018;

            result += #{format '%c%02d', `c`, year - `s`};
            result += #{strftime('-%m-%d')};
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

  def to_a
    [sec, min, hour, day, month, year, wday, yday, isdst, zone]
  end

  def to_f
    `self.getTime() / 1000`
  end

  def to_i
    `parseInt(self.getTime() / 1000, 10)`
  end

  def cweek_cyear
    jan01 = ::Time.new(year, 1, 1)
    jan01_wday = jan01.wday
    first_monday = 0
    year = self.year
    if jan01_wday <= 4 && jan01_wday != 0
      # Jan 01 is in the first week of the year
      offset = jan01_wday - 1
    else
      # Jan 01 is in the last week of the previous year
      offset = jan01_wday - 7 - 1
      offset = -1 if offset == -8 # Adjust if Jan 01 is a Sunday
    end

    week = ((yday + offset) / 7.00).ceil

    if week <= 0
      # Get the last week of the previous year
      return ::Time.new(self.year - 1, 12, 31).cweek_cyear
    elsif week == 53
      # Find out whether this is actually week 53 or already week 01 of the following year
      dec31 = ::Time.new(self.year, 12, 31)
      dec31_wday = dec31.wday
      if dec31_wday <= 3 && dec31_wday != 0
        week = 1
        year += 1
      end
    end

    [week, year]
  end

  class << self
    alias mktime local
    alias utc gm
  end

  alias ctime asctime
  alias dst? isdst
  alias getutc getgm
  alias gmtoff gmt_offset
  alias mday day
  alias month mon
  alias to_s inspect
  alias tv_sec to_i
  alias tv_nsec nsec
  alias tv_usec usec
  alias utc gmtime
  alias utc? gmt?
  alias utc_offset gmt_offset
end
