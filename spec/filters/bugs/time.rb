# NOTE: run bin/format-filters after changing this file
opal_filter "Time" do
  fails "Time#+ zone is a timezone object preserves time zone" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time#- tracks microseconds from a Rational" # Expected 0 to equal 123456
  fails "Time#- zone is a timezone object preserves time zone" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time#ceil ceils to 0 decimal places with an explicit argument" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil ceils to 2 decimal places with an explicit argument" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil ceils to 4 decimal places with an explicit argument" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil ceils to 7 decimal places with an explicit argument" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil copies own timezone to the returning value" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil defaults to ceiling to 0 places" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil returns an instance of Time, even if #ceil is called on a subclass" # Expected Time to be identical to #<Class:0x38c06>
  fails "Time#dup returns a clone of Time instance"
  fails "Time#floor copies own timezone to the returning value" # NoMethodError: undefined method `floor' for 2010-03-30 05:43:25 UTC
  fails "Time#floor defaults to flooring to 0 places" # NoMethodError: undefined method `floor' for 2010-03-30 05:43:25 UTC
  fails "Time#floor floors to 0 decimal places with an explicit argument" # NoMethodError: undefined method `floor' for 2010-03-30 05:43:25 UTC
  fails "Time#floor floors to 7 decimal places with an explicit argument" # NoMethodError: undefined method `floor' for 2010-03-30 05:43:25 UTC
  fails "Time#floor returns an instance of Time, even if #floor is called on a subclass" # Expected Time to be identical to #<Class:0x188fa>
  fails "Time#getlocal raises ArgumentError if the String argument is not in an ASCII-compatible encoding"
  fails "Time#getlocal with a timezone argument accepts timezone argument that must have #local_to_utc and #utc_to_local methods" # Expected to not get Exception but got: NoMethodError (undefined method `getlocal' for 2000-01-01 12:00:00 UTC)
  fails "Time#getlocal with a timezone argument does not raise exception if timezone does not implement #local_to_utc method" # Expected to not get Exception but got: NoMethodError (undefined method `getlocal' for 2000-01-01 12:00:00 UTC)
  fails "Time#getlocal with a timezone argument raises TypeError if timezone does not implement #utc_to_local method" # Expected TypeError (/can't convert \w+ into an exact number/) but got: NoMethodError (undefined method `getlocal' for 2000-01-01 12:00:00 UTC)
  fails "Time#getlocal with a timezone argument returns a Time in the timezone" # NoMethodError: undefined method `getlocal' for 2000-01-01 12:00:00 UTC
  fails "Time#getlocal with a timezone argument subject's class implements .find_timezone method calls .find_timezone to build a time object if passed zone name as a timezone argument" # NoMethodError: undefined method `getlocal' for 2000-01-01 12:00:00 UTC
  fails "Time#getlocal with a timezone argument subject's class implements .find_timezone method does not call .find_timezone if passed any not string/numeric/timezone timezone argument" # Expected TypeError (/can't convert \w+ into an exact number/) but got: NoMethodError (undefined method `getlocal' for 2000-01-01 12:00:00 UTC)
  fails "Time#gmtime converts self to UTC, modifying the receiver" # Expected 2007-01-09 03:00:00 UTC to equal 2007-01-09 12:00:00 UTC
  fails "Time#hash returns an Integer" # Expected "Time:100000" (String) to be an instance of Integer
  fails "Time#inspect formats nanoseconds as a Rational" # NoMethodError: undefined method `nsec' for 2007-11-01 15:25:00 UTC
  fails "Time#inspect formats the fixed offset time following the pattern 'yyyy-MM-dd HH:mm:ss +/-HHMM'"
  fails "Time#inspect preserves milliseconds" # Expected "2007-11-01 15:25:00 UTC" == "2007-11-01 15:25:00.123456 UTC" to be truthy but was false
  fails "Time#localtime raises ArgumentError if the String argument is not in an ASCII-compatible encoding"
  fails "Time#nsec returns a positive value for dates before the epoch" # NoMethodError: undefined method `nsec' for 1969-11-12 13:18:57 UTC
  fails "Time#round copies own timezone to the returning value"
  fails "Time#round defaults to rounding to 0 places"
  fails "Time#round returns an instance of Time, even if #round is called on a subclass"
  fails "Time#round rounds to 0 decimal places with an explicit argument"
  fails "Time#round rounds to 7 decimal places with an explicit argument"
  fails "Time#strftime rounds an offset to the nearest second when formatting with %z"
  fails "Time#strftime should be able to print the commercial year with leading zeroes"
  fails "Time#strftime should be able to print the commercial year with only two digits"
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
  fails "Time#subsec returns 0 as an Integer for a Time with a whole number of seconds" # NoMethodError: undefined method `subsec' for 1970-01-01 01:01:40 +0100
  fails "Time#succ is obsolete" # Expected warning to match: /Time#succ is obsolete/ but got: ""
  fails "Time#to_f returns the float number of seconds + usecs since the epoch"
  fails "Time#to_i rounds fractional seconds toward zero" # Expected -315619200 == -315619199 to be truthy but was false
  fails "Time#to_s formats the fixed offset time following the pattern 'yyyy-MM-dd HH:mm:ss +/-HHMM'"
  fails "Time#tv_sec rounds fractional seconds toward zero" # Expected -315619200 == -315619199 to be truthy but was false
  fails "Time#usec returns a positive value for dates before the epoch" # Expected 0 to equal 404240
  fails "Time#utc converts self to UTC, modifying the receiver" # Expected 2007-01-09 03:00:00 UTC to equal 2007-01-09 12:00:00 UTC
  fails "Time#zone Encoding.default_internal is set returns an ASCII string"
  fails "Time#zone defaults to UTC when bad zones given" # Expected 3600 to equal 0
  fails "Time.at :in keyword argument could be UTC offset as a String in '+HH:MM or '-HH:MM' format" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.at :in keyword argument could be UTC offset as a number of seconds" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.at :in keyword argument could be a timezone object" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.at passed Numeric passed BigDecimal doesn't round input value"
  fails "Time.at passed Numeric roundtrips a Rational produced by #to_r"
  fails "Time.at passed [Time, Numeric, format] :microsecond format traits second argument as microseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :microsecond format treats second argument as microseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :millisecond format traits second argument as milliseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :millisecond format treats second argument as milliseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :nanosecond format traits second argument as nanoseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :nanosecond format treats second argument as nanoseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :nsec format traits second argument as nanoseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :nsec format treats second argument as nanoseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :usec format traits second argument as microseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] :usec format treats second argument as microseconds" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed [Time, Numeric, format] supports Float second argument" # ArgumentError: [Time.at] wrong number of arguments(3 for -2)
  fails "Time.at passed non-Time, non-Numeric with an argument that responds to #to_r needs for the argument to respond to #to_int too" # Mock 'rational-but-no-to_int' expected to receive to_r("any_args") exactly 1 times but received it 0 times
  fails "Time.gm handles fractional usec close to rounding limit" # NoMethodError: undefined method `nsec' for 2000-01-01 12:30:00 UTC:Time
  fails "Time.gm raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 UTC was returned)
  fails "Time.local raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 +0200 was returned)
  fails "Time.mktime raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 +0200 was returned)
  fails "Time.new has at least microsecond precision" # NoMethodError: undefined method `nsec' for 2019-05-16 23:25:01 +0200
  fails "Time.new uses the local timezone" # Expected 10800 to equal -28800
  fails "Time.new with a timezone argument #name method cannot marshal Time if #name method isn't implemented" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time.new with a timezone argument #name method uses the optional #name method for marshaling" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time.new with a timezone argument Time-like argument of #utc_to_local and #local_to_utc methods has attribute values the same as a Time object in UTC" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time.new with a timezone argument Time-like argument of #utc_to_local and #local_to_utc methods implements subset of Time methods" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time.new with a timezone argument accepts timezone argument that must have #local_to_utc and #utc_to_local methods" # Expected to not get Exception but got: ArgumentError (Opal does not support explicitly specifying UTC offset for Time)
  fails "Time.new with a timezone argument does not raise exception if timezone does not implement #utc_to_local method" # Expected to not get Exception but got: ArgumentError (Opal does not support explicitly specifying UTC offset for Time)
  fails "Time.new with a timezone argument raises TypeError if timezone does not implement #local_to_utc method" # Expected TypeError (/can't convert \w+ into an exact number/) but got: ArgumentError (Opal does not support explicitly specifying UTC offset for Time)
  fails "Time.new with a timezone argument returned value by #utc_to_local and #local_to_utc methods could be Time instance" # Expected to not get Exception but got: ArgumentError (Opal does not support explicitly specifying UTC offset for Time)
  fails "Time.new with a timezone argument returned value by #utc_to_local and #local_to_utc methods could be Time subclass instance" # Expected to not get Exception but got: ArgumentError (Opal does not support explicitly specifying UTC offset for Time)
  fails "Time.new with a timezone argument returned value by #utc_to_local and #local_to_utc methods could be any object with #to_i method" # Expected to not get Exception but got: ArgumentError (Opal does not support explicitly specifying UTC offset for Time)
  fails "Time.new with a timezone argument returned value by #utc_to_local and #local_to_utc methods could have any #zone and #utc_offset because they are ignored" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time.new with a timezone argument returned value by #utc_to_local and #local_to_utc methods leads to raising Argument error if difference between argument and result is too large" # Expected ArgumentError (utc_offset out of range) but got: ArgumentError (Opal does not support explicitly specifying UTC offset for Time)
  fails "Time.new with a timezone argument returns a Time in the timezone" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time.new with a timezone argument subject's class implements .find_timezone method calls .find_timezone to build a time object at loading marshaled data" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time.new with a timezone argument subject's class implements .find_timezone method calls .find_timezone to build a time object if passed zone name as a timezone argument" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time.new with a timezone argument subject's class implements .find_timezone method does not call .find_timezone if passed any not string/numeric/timezone timezone argument" # Expected TypeError (/can't convert \w+ into an exact number/) but got: ArgumentError (Opal does not support explicitly specifying UTC offset for Time)
  fails "Time.new with a timezone argument the #abbr method is used by '%Z' in #strftime" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time.new with a utc_offset argument raises ArgumentError if the month is greater than 12" # Expected ArgumentError (/(mon|argument) out of range/) but got: ArgumentError (Opal does not support explicitly specifying UTC offset for Time)
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset specified as +HH:MM:SS" # ArgumentError: Opal does not support explicitly specifying UTC offset for Time
  fails "Time.now has at least microsecond precision" # NoMethodError: undefined method `nsec' for 2019-05-16 23:25:03 +0200
  fails "Time.now uses the local timezone" # Expected 10800 to equal -28800
  fails "Time.utc handles fractional usec close to rounding limit" # NoMethodError: undefined method `nsec' for 2000-01-01 12:30:00 UTC:Time
  fails "Time.utc raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 UTC was returned)
end
