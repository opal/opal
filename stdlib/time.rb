class Time
  def self.parse(str)
    `new Date(Date.parse(str))`
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
