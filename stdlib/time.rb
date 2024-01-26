# backtick_javascript: true

class Time
  def self.parse(str, now = Time.now)
    %x{
      var d = Date.parse(str);
      if (d !== d) {
        // parsing failed, d is a NaN
        // probably str is not in ISO 8601 format, which is the only format, required to be supported by Javascript
        // try to make the format more like ISO or more like Chrome and parse again
        str = str.replace(/^(\d+)([\./])(\d+)([\./])?(\d+)?/, function(matched_sub, c1, c2, c3, c4, c5, offset, orig_string) {
          if ((c2 === c4) && c5) {
            // 2007.10.1 or 2007/10/1 are ok, but 2007/10.1 is not, convert to 2007-10-1
            return c1 + '-' + c3 + '-' + c5;
          } else if (c3 && !c4) {
            // 2007.10 or 2007/10
            // Chrome and Ruby can parse "2007/10", assuming its "2007-10-01", do the same
            return c1 + '-' + c3 + '-01';
          };
          return matched_sub;
        });
        d = Date.parse(str);
      }
      if (d !== d) {
        // still failed, d is a NaN
        if (str.length == 8 && str.match(/^[0-9]{4}[0-1][0-9][0-3][0-9]/)) {
          // try yyyymmdd
          d = Date.parse(str.slice(0, 4) + '-' + str.slice(-4, -2) + '-' + str.slice(-2));
          if (d !== d)
            #{::Kernel.raise(::ArgumentError, 'argument out of range')}
        } else if (str.length == 7 && str.match(/^[0-9]{4}[0-3][0-9][0-9]/)) {
          // try yyyyddd
          return new Date(Date.UTC(parseInt(str.slice(0, 4)), 0, parseInt(str.slice(-3))));
        }
      }
      if (d !== d) {
        // still failed, d is a NaN
        // try hh:mm format
        var m = str.match(/^([0-2]?[0-9]):([0-5][0-9])/);
        if (m) {
          now.setHours(parseInt(m[1]), parseInt(m[2]));
          return d;
        }
      }
      if (d !== d && str.match(/[a-zA-Z]+/)) {
        // try monthname
        var idx = #{`Opal.Time.$$monthnames`.compact.map(&:downcase)}.indexOf(str.toLowerCase());
        if (idx > 0) {
          now.setMonth(idx - 1);
          return d;
        }
      }
      if (d !== d) {
        // still failed, d is a NaN
        #{::Kernel.raise(::ArgumentError, "no time information in #{str}")}
      }
      return new Date(d);
    }
  end

  def self.def_formatter(name, format, on_utc: false, utc_tz: nil, tz_format: nil, fractions: false, on: self)
    on.define_method name do |fdigits = 0|
      case self
      when defined?(::DateTime) && ::DateTime
        date = on_utc ? new_offset(0) : self
      when defined?(::Date) && ::Date
        date = ::Time.utc(year, month, day)
      when ::Time
        date = on_utc ? getutc : self
      end
      str = date.strftime(format)
      str += date.strftime(".%#{fdigits}N") if fractions && fdigits > 0
      if utc_tz
        str += utc ? utc_tz : date.strftime(tz_format)
      elsif tz_format
        str += date.strftime(tz_format)
      end
      str
    end
  end

  def_formatter :rfc2822, '%a, %d %b %Y %T ', utc_tz: '-00:00', tz_format: '%z'
  alias rfc822 rfc2822
  def_formatter :httpdate, '%a, %d %b %Y %T GMT', on_utc: true
  def_formatter :xmlschema, '%FT%T', utc_tz: 'Z', tz_format: '%:z', fractions: true
  alias iso8601 xmlschema

  def to_date
    Date.wrap(self)
  end

  def to_datetime
    DateTime.wrap(self)
  end

  def to_time
    self
  end
end

require 'date'
