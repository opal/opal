class Time
  include Native
  include Comparable

  def self.at(seconds, frac = 0)
    from_native(`new Date(seconds * 1000 + frac)`)
  end

  def self.now
    from_native(`new Date()`)
  end

  def initialize(year = nil, month = nil, day = nil, hour = nil, min = nil, sec = nil, utc_offset = nil)
    if year
      super(`new Date(#{year.to_native}, #{month.to_native}, #{day.to_native}, #{hour.to_native}, #{min.to_native}, #{sec.to_native})`)
    else
      super(`new Date()`)
    end
  end

  def +(other)
    from_native(`new Date(#{to_f + other.to_f})`)
  end

  def -(other)
    from_native(`new Date(#{to_f - other.to_f})`)
  end

  def <=>(other)
    to_f <=> other.to_f
  end

  def asctime
    raise NotImplementedError
  end

  alias ctime asctime

  def day
    `#@native.getDate()`
  end

  def dst?
    raise NotImplementedError
  end

  def eql?(other)
    other.is_a?(Time) && (self <=> other).zero?
  end

  def friday?
    wday == 5
  end

  def getgm
    raise NotImplementedError
  end

  def getlocal (*)
    raise NotImplementedError
  end

  alias getutc getgm

  def gmt?
    raise NotImplementedError
  end

  def gmt_offset
    raise NotImplementedError
  end

  def gmtime
    raise NotImplementedError
  end

  alias gmtoff gmt_offset

  def hour
    `#@native.getHours()`
  end

  alias isdst dst?

  def localtime (*)
    raise NotImplementedError
  end

  alias mday day

  def min
    `#@native.getMinutes()`
  end

  def mon
    `#@native.getMonth() + 1`
  end

  def monday?
    wday == 1
  end

  alias month mon

  def nsec
    raise NotImplementedError
  end

  def round (*)
    raise NotImplementedError
  end

  def saturday?
    wday == 6
  end

  def sec
    `#@native.getSeconds()`
  end

  def strftime (string)
    raise NotImplementedError
  end

  def subsec
    raise NotImplementedError
  end

  def sunday?
    wday == 0
  end

  def thursday?
    wday == 4
  end

  def to_a
    raise NotImplementedError
  end

  def to_f
    `#@native.getTime() / 1000`
  end

  def to_i
    `parseInt(#@native.getTime() / 1000)`
  end

  def to_r
    raise NotImplementedError
  end

  def to_s
    raise NotImplementedError
  end

  def tuesday?
    wday == 2
  end

  alias tv_nsec nsec

  alias tv_sec to_i

  def tv_usec
    raise NotImplementedError
  end

  alias usec tv_usec

  alias utc gmtime

  alias utc? gmt?

  alias utc_offset gmt_offset

  def wday
    `#@native.getDay()`
  end

  def wednesday?
    wday == 3
  end

  def yday
    raise NotImplementedError
  end

  def year
    `#@native.getFullYear()`
  end

  def zone
    raise NotImplementedError
  end
end
