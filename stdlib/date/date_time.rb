# backtick_javascript: true

class DateTime < Date
  class << self
    def now
      t = Time.now
      new(t.year, t.month, t.day, t.hour, t.min, t.sec, t.utc_offset)
    end

    def parse(string, comp = true, start = ::Date::ITALY, limit: 128)
      dth = _parse(string, comp, limit: limit, mode: :datetime)
      raise ArgumentError, 'invalid date, time' unless dth
      new(dth[:year], dth[:month], dth[:day], dth[:hour], dth[:min], dth[:sec], dth[:utc_offset] || 0, start)
    end
  end

  def initialize(year = -4712, month = 1, day = 1, hours = 0, minutes = 0, seconds = 0, offset = 0, start = ITALY)
    %x{
      // Because of Gregorian reform calendar goes from 1582-10-04 to 1582-10-15.
      // All days in between end up as 4 october.
      if (year === 1582 && month === 10 && day > 4 && day < 15) {
        day = 4;
      }
    }

    ::Kernel.raise ArgumentError, 'hours must be a Integer' if !hours.nil? && !hours.is_a?(Integer)
    ::Kernel.raise ArgumentError, 'minutes must be a Integer' if !minutes.nil? && !minutes.is_a?(Integer)
    ::Kernel.raise ArgumentError, 'seconds must be larger than -60 and smaller than 60' if !seconds.nil? && (seconds <= -60 || seconds >= 60) 

    hours += 24 if hours && hours < 0
    minutes += 60 if minutes && minutes < 0
    seconds += 60 if seconds && seconds < 0

    @date = Time.new(year, month, day, hours, minutes, seconds, offset)
    @start = start
  end

  def_delegators :@date, :min, :hour, :sec
  alias minute min
  alias second sec

  def sec_fraction
    @date.usec/1_000_000r
  end

  alias second_fraction sec_fraction

  def offset
    @date.gmt_offset / (24 * 3600r)
  end

  def +(other)
    ::DateTime.wrap @date + other
  end

  def -(other)
    `if (Opal.is_a(other, #{::Date})) other = other.date`
    result = @date - other
    if result.is_a? ::Time
      ::DateTime.wrap result
    else
      result
    end
  end

  def new_offset(offset)
    new_date = clone
    offset = Time._parse_offset(offset)
    `new_date.date.timezone = offset`
    new_date
  end

  def to_datetime
    self
  end

  def to_time
    @date.dup
  end

  def to_date
    Date.new(year, month, day)
  end
end
