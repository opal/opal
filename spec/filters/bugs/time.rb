opal_filter "Time" do
  fails "Time#- tracks microseconds from a Rational" # Expected 0 to equal 123456
  fails "Time#dup returns a clone of Time instance"
  fails "Time#getlocal raises ArgumentError if the String argument is not in an ASCII-compatible encoding"
  fails "Time#gmtime converts self to UTC, modifying the receiver" # Expected 2007-01-09 03:00:00 UTC to equal 2007-01-09 12:00:00 UTC
  fails "Time#inspect formats the fixed offset time following the pattern 'yyyy-MM-dd HH:mm:ss +/-HHMM'"
  fails "Time#inspect formats the local time following the pattern 'yyyy-MM-dd HH:mm:ss Z'" # Expected "2000-01-01 20:15:01 +1200" to equal "2000-01-01 20:15:01 +0100"
  fails "Time#localtime raises ArgumentError if the String argument is not in an ASCII-compatible encoding"
  fails "Time#nsec returns a positive value for dates before the epoch" # NoMethodError: undefined method `nsec' for 1969-11-12 13:18:57 UTC
  fails "Time#round copies own timezone to the returning value"
  fails "Time#round defaults to rounding to 0 places"
  fails "Time#round returns an instance of Time, even if #round is called on a subclass"
  fails "Time#round rounds to 0 decimal places with an explicit argument"
  fails "Time#round rounds to 7 decimal places with an explicit argument"
  fails "Time#strftime returns the timezone with %Z" # Exception: Cannot read property 'join' of null
  fails "Time#strftime rounds an offset to the nearest second when formatting with %z"
  fails "Time#strftime should be able to print the commercial year with leading zeroes"
  fails "Time#strftime should be able to print the commercial year with only two digits"
  fails "Time#strftime should be able to print the julian day with leading zeroes"
  fails "Time#strftime should be able to show the commercial week day"
  fails "Time#strftime should be able to show the number of seconds since the unix epoch" # fails under FIJI et al TZs
  fails "Time#strftime should be able to show the timezone if available"
  fails "Time#strftime should be able to show the timezone of the date with a : separator"
  fails "Time#strftime should be able to show the week number with the week starting on Sunday (%U) and Monday (%W)"
  fails "Time#strftime with %N formats the microseconds of the second with %6N"
  fails "Time#strftime with %N formats the milliseconds of the second with %3N"
  fails "Time#strftime with %N formats the nanoseconds of the second with %9N"
  fails "Time#strftime with %N formats the nanoseconds of the second with %N"
  fails "Time#strftime with %N formats the picoseconds of the second with %12N"
  fails "Time#to_f returns the float number of seconds + usecs since the epoch"
  fails "Time#to_s formats the fixed offset time following the pattern 'yyyy-MM-dd HH:mm:ss +/-HHMM'"
  fails "Time#to_s formats the local time following the pattern 'yyyy-MM-dd HH:mm:ss Z'" # Expected "2000-01-01 20:15:01 +1200" to equal "2000-01-01 20:15:01 +0100"
  fails "Time#usec returns a positive value for dates before the epoch" # Expected 0 to equal 404240
  fails "Time#utc converts self to UTC, modifying the receiver" # Expected 2007-01-09 03:00:00 UTC to equal 2007-01-09 12:00:00 UTC
  fails "Time#yday returns an integer representing the day of the year, 1..366" # Expected 117 to equal 116
  fails "Time#zone Encoding.default_internal is set returns an ASCII string"
  fails "Time#zone defaults to UTC when bad zones given" # Expected 3600 to equal 0
  fails "Time.at passed Numeric passed BigDecimal doesn't round input value"
  fails "Time.at passed Numeric roundtrips a Rational produced by #to_r"
  fails "Time.at passed [Time, Numeric, format] :microsecond format traits second argument as microseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :millisecond format traits second argument as milliseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :nanosecond format traits second argument as nanoseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :nsec format traits second argument as nanoseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :usec format traits second argument as microseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] supports Float second argument" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.gm handles fractional usec close to rounding limit" # NoMethodError: undefined method `nsec' for 2000-01-01 12:30:00 UTC:Time
  fails "Time.gm raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 UTC was returned)
  fails "Time.local raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 +0200 was returned)
  fails "Time.mktime raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 +0200 was returned)
  fails "Time.new uses the local timezone" # Expected 10800 to equal -28800
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset specified as +HH:MM:SS" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time.now uses the local timezone" # Expected 10800 to equal -28800
  fails "Time.utc handles fractional usec close to rounding limit" # NoMethodError: undefined method `nsec' for 2000-01-01 12:30:00 UTC:Time
  fails "Time.utc raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 UTC was returned)
end
