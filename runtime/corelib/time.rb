class Time
  include Native
  include Comparable

  def self.at (seconds, frac = 0)
    from_native(`new Date(seconds * 1000 + frac)`)
  end

  def initialize (year, month = nil, day = nil, hour = nil, min = nil, sec = nil, utc_offset = nil)
    super(`new Date()`)
  end
end
