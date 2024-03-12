# NOTE: run bin/format-filters after changing this file
opal_filter "Time" do
  fails "Time#+ zone is a timezone object preserves time zone" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time#- tracks microseconds from a Rational" # Expected 0 == 123456 to be truthy but was false
  fails "Time#- zone is a timezone object preserves time zone" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time#ceil ceils to 0 decimal places with an explicit argument" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil ceils to 2 decimal places with an explicit argument" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil ceils to 4 decimal places with an explicit argument" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil ceils to 7 decimal places with an explicit argument" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil copies own timezone to the returning value" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil defaults to ceiling to 0 places" # NoMethodError: undefined method `ceil' for 2010-03-30 05:43:25 UTC
  fails "Time#ceil returns an instance of Time, even if #ceil is called on a subclass" # Expected Time to be identical to #<Class:0xa40e6>
  fails "Time#deconstruct_keys ignores non-Symbol keys" # NoMethodError: undefined method `deconstruct_keys' for 2022-10-05 13:30:00 +0200
  fails "Time#deconstruct_keys ignores not existing Symbol keys" # NoMethodError: undefined method `deconstruct_keys' for 2022-10-05 13:30:00 +0200
  fails "Time#deconstruct_keys it raises error when argument is neither nil nor array" # Expected TypeError (wrong argument type Integer (expected Array or nil)) but got: NoMethodError (undefined method `deconstruct_keys' for 2022-10-05 13:30:00 +0200)
  fails "Time#deconstruct_keys requires one argument" # Expected ArgumentError but got: NoMethodError (undefined method `deconstruct_keys' for 2022-10-05 13:30:00 +0200)
  fails "Time#deconstruct_keys returns only specified keys" # NoMethodError: undefined method `deconstruct_keys' for 2022-10-05 13:39:00 UTC
  fails "Time#deconstruct_keys returns whole hash for nil as an argument" # NoMethodError: undefined method `deconstruct_keys' for 2022-10-05 13:30:00 UTC
  fails "Time#deconstruct_keys returns {} when passed []" # NoMethodError: undefined method `deconstruct_keys' for 2022-10-05 13:30:00 +0200
  fails "Time#dup returns a clone of Time instance" # NoMethodError: undefined method `now' for #<Module:0x133b8>
  fails "Time#floor copies own timezone to the returning value" # NoMethodError: undefined method `floor' for 2010-03-30 05:43:25 UTC
  fails "Time#floor defaults to flooring to 0 places" # NoMethodError: undefined method `floor' for 2010-03-30 05:43:25 UTC
  fails "Time#floor floors to 0 decimal places with an explicit argument" # NoMethodError: undefined method `floor' for 2010-03-30 05:43:25 UTC
  fails "Time#floor floors to 7 decimal places with an explicit argument" # NoMethodError: undefined method `floor' for 2010-03-30 05:43:25 UTC
  fails "Time#floor returns an instance of Time, even if #floor is called on a subclass" # Expected Time to be identical to #<Class:0x10b74>
  fails "Time#getlocal raises ArgumentError if the String argument is not in an ASCII-compatible encoding" # Expected ArgumentError but got: NoMethodError (undefined method `getlocal' for 2022-12-07 05:21:15 +0100)
  fails "Time#getlocal with a timezone argument accepts timezone argument that must have #local_to_utc and #utc_to_local methods" # Expected to not get Exception but got: NoMethodError (undefined method `getlocal' for 2000-01-01 12:00:00 UTC)
  fails "Time#getlocal with a timezone argument does not raise exception if timezone does not implement #local_to_utc method" # Expected to not get Exception but got: NoMethodError (undefined method `getlocal' for 2000-01-01 12:00:00 UTC)
  fails "Time#getlocal with a timezone argument raises TypeError if timezone does not implement #utc_to_local method" # Expected TypeError (/can't convert \w+ into an exact number/) but got: NoMethodError (undefined method `getlocal' for 2000-01-01 12:00:00 UTC)
  fails "Time#getlocal with a timezone argument returns a Time in the timezone" # NoMethodError: undefined method `getlocal' for 2000-01-01 12:00:00 UTC
  fails "Time#getlocal with a timezone argument subject's class implements .find_timezone method calls .find_timezone to build a time object if passed zone name as a timezone argument" # NoMethodError: undefined method `getlocal' for 2000-01-01 12:00:00 UTC
  fails "Time#getlocal with a timezone argument subject's class implements .find_timezone method does not call .find_timezone if passed any not string/numeric/timezone timezone argument" # Expected TypeError (/can't convert \w+ into an exact number/) but got: NoMethodError (undefined method `getlocal' for 2000-01-01 12:00:00 UTC)
  fails "Time#gmtime converts self to UTC, modifying the receiver" # Expected 2007-01-09 05:00:00 UTC == 2007-01-09 12:00:00 UTC to be truthy but was false
  fails "Time#inspect omits trailing zeros from microseconds" # Expected "2007-11-01 15:25:00 UTC" == "2007-11-01 15:25:00.1 UTC" to be truthy but was false
  fails "Time#inspect preserves microseconds" # Expected "2007-11-01 15:25:00 UTC" == "2007-11-01 15:25:00.123456 UTC" to be truthy but was false
  fails "Time#inspect preserves nanoseconds" # Expected "2007-11-01 15:25:00 UTC" == "2007-11-01 15:25:00.123456789 UTC" to be truthy but was false
  fails "Time#inspect uses the correct time zone with microseconds" # NoMethodError: undefined method `localtime' for 2000-01-01 00:00:00 UTC
  fails "Time#inspect uses the correct time zone without microseconds" # NoMethodError: undefined method `localtime' for 2000-01-01 00:00:00 UTC
  fails "Time#localtime on a frozen time raises a FrozenError if the time has a different time zone" # Expected FrozenError but got: NoMethodError (undefined method `localtime' for 2007-01-09 12:00:00 UTC)
  fails "Time#localtime raises ArgumentError if the String argument is not in an ASCII-compatible encoding" # Expected ArgumentError but got: NoMethodError (undefined method `localtime' for 2022-12-07 05:21:43 +0100)
  fails "Time#localtime returns a Time with a UTC offset specified as A-Z military zone" # NoMethodError: undefined method `localtime' for 2007-01-09 12:00:00 +0100
  fails "Time#localtime returns a Time with a UTC offset specified as UTC" # NoMethodError: undefined method `localtime' for 2007-01-09 12:00:00 +0100
  fails "Time#nsec returns a positive value for dates before the epoch" # NoMethodError: undefined method `nsec' for 1969-11-12 13:18:57 UTC
  fails "Time#round copies own timezone to the returning value" # NoMethodError: undefined method `round' for 2010-03-30 05:43:25 UTC
  fails "Time#round defaults to rounding to 0 places" # NoMethodError: undefined method `round' for 2010-03-30 05:43:25 UTC
  fails "Time#round returns an instance of Time, even if #round is called on a subclass" # Expected Time to be identical to #<Class:0x5990a>
  fails "Time#round rounds to 0 decimal places with an explicit argument" # NoMethodError: undefined method `round' for 2010-03-30 05:43:25 UTC
  fails "Time#round rounds to 7 decimal places with an explicit argument" # NoMethodError: undefined method `round' for 2010-03-30 05:43:25 UTC
  fails "Time#strftime applies '-' flag to UTC time" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: Z
  fails "Time#strftime rounds an offset to the nearest second when formatting with %z" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time#strftime should be able to print the commercial year with leading zeroes" # Expected "200" == "0200" to be truthy but was false
  fails "Time#strftime should be able to print the commercial year with only two digits" # TypeError: no implicit conversion of Range into Integer
  fails "Time#strftime should be able to show default Logger format" # Expected "2001-12-03T04:05:06.000000 " == "2001-12-03T04:05:06.100000 " to be truthy but was false
  fails "Time#strftime should be able to show the commercial week day" # Expected "1" == "7" to be truthy but was false
  fails "Time#strftime should be able to show the number of seconds since the unix epoch" # Expected "1104534000" == "1104537600" to be truthy but was false
  fails "Time#strftime should be able to show the timezone of the date with a : separator" # Expected "-0000" == "+0000" to be truthy but was false
  fails "Time#strftime should be able to show the week number with the week starting on Sunday (%U) and Monday (%W)" # Expected "%U" == "14" to be truthy but was false
  fails "Time#strftime supports RFC 3339 UTC for unknown offset local time, -0000, as %-z" # Expected "-0000" == "+0000" to be truthy but was false
  fails "Time#strftime with %N formats the microseconds of the second with %6N" # Expected "000000" == "042000" to be truthy but was false
  fails "Time#strftime with %N formats the milliseconds of the second with %3N" # Expected "000" == "050" to be truthy but was false
  fails "Time#strftime with %N formats the nanoseconds of the second with %9N" # Expected "000000000" == "001234000" to be truthy but was false
  fails "Time#strftime with %N formats the nanoseconds of the second with %N" # Expected "000000000" == "001234560" to be truthy but was false
  fails "Time#strftime with %N formats the picoseconds of the second with %12N" # Expected "000000000000" == "999999999999" to be truthy but was false
  fails "Time#strftime works correctly with width, _ and 0 flags, and :" # Expected "-0000" == "      -000" to be truthy but was false
  fails "Time#subsec returns 0 as an Integer for a Time with a whole number of seconds" # NoMethodError: undefined method `subsec' for 1970-01-01 01:01:40 +0100
  fails "Time#to_date yields accurate julian date for Julian-Gregorian gap value" # Expected 2299170 == 2299160 to be truthy but was false
  fails "Time#to_date yields accurate julian date for ambiguous pre-Gregorian reform value" # Expected 2299160 == 2299150 to be truthy but was false
  fails "Time#to_date yields accurate julian date for post-Gregorian reform value" # Expected 2299171 == 2299161 to be truthy but was false
  fails "Time#to_date yields same julian day regardless of UTC time value" # Expected 2299171 == 2299161 to be truthy but was false
  fails "Time#to_date yields same julian day regardless of local time or zone" # Expected 2299171 == 2299161 to be truthy but was false
  fails "Time#to_f returns the float number of seconds + usecs since the epoch" # Expected 100 == 100.0001 to be truthy but was false
  fails "Time#to_i rounds fractional seconds toward zero" # Expected -315619200 == -315619199 to be truthy but was false
  fails "Time#tv_sec rounds fractional seconds toward zero" # Expected -315619200 == -315619199 to be truthy but was false
  fails "Time#usec returns a positive value for dates before the epoch" # Expected 0 == 404240 to be truthy but was false
  fails "Time#utc converts self to UTC, modifying the receiver" # Expected 2007-01-09 05:00:00 UTC == 2007-01-09 12:00:00 UTC to be truthy but was false
  fails "Time#utc? does not treat time with +00:00 offset as UTC" # Expected true == false to be truthy but was false
  fails "Time#utc? does not treat time with 0 offset as UTC" # Expected true == false to be truthy but was false
  fails "Time#utc? does treat time with 'UTC' offset as UTC" # NoMethodError: undefined method `localtime' for 2023-09-20 22:52:11 +0200
  fails "Time#utc? does treat time with -00:00 offset as UTC" # NoMethodError: undefined method `localtime' for 2023-09-20 22:52:11 +0200
  fails "Time#utc? does treat time with Z offset as UTC" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: Z
  fails "Time#zone Encoding.default_internal is set returns an ASCII string" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Time#zone defaults to UTC when bad zones given" # Expected 3600 == 0 to be truthy but was false
  fails "Time#zone returns UTC when called on a UTC time" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: Z
  fails "Time.at :in keyword argument could be UTC offset as a 'UTC' String" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.at :in keyword argument could be UTC offset as a String in '+HH:MM or '-HH:MM' format" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.at :in keyword argument could be UTC offset as a military zone A-Z" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.at :in keyword argument could be UTC offset as a number of seconds" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.at :in keyword argument could be a timezone object" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.at :in keyword argument raises ArgumentError if format is invalid" # Expected ArgumentError but got: TypeError (no implicit conversion of Hash into Integer)
  fails "Time.at passed Numeric passed BigDecimal doesn't round input value" # NoMethodError: undefined method `to_i' for 1.1
  fails "Time.at passed Numeric passed Rational returns Time with correct microseconds" # Expected 0 == 539759 to be truthy but was false
  fails "Time.at passed Numeric passed Rational returns Time with correct nanoseconds" # Expected 0 == 539759 to be truthy but was false
  fails "Time.at passed Numeric roundtrips a Rational produced by #to_r" # NoMethodError: undefined method `to_r' for 2022-12-07 05:21:14 +0100
  fails "Time.at passed [Time, Numeric, format] :microsecond format treats second argument as microseconds" # ArgumentError: [Time.at] wrong number of arguments (given 3, expected -2)
  fails "Time.at passed [Time, Numeric, format] :millisecond format treats second argument as milliseconds" # ArgumentError: [Time.at] wrong number of arguments (given 3, expected -2)
  fails "Time.at passed [Time, Numeric, format] :nanosecond format treats second argument as nanoseconds" # ArgumentError: [Time.at] wrong number of arguments (given 3, expected -2)
  fails "Time.at passed [Time, Numeric, format] :nsec format treats second argument as nanoseconds" # ArgumentError: [Time.at] wrong number of arguments (given 3, expected -2)
  fails "Time.at passed [Time, Numeric, format] :usec format treats second argument as microseconds" # ArgumentError: [Time.at] wrong number of arguments (given 3, expected -2)
  fails "Time.at passed [Time, Numeric, format] supports Float second argument" # ArgumentError: [Time.at] wrong number of arguments (given 3, expected -2)
  fails "Time.at passed non-Time, non-Numeric with an argument that responds to #to_r needs for the argument to respond to #to_int too" # Mock 'rational-but-no-to_int' expected to receive to_r("any_args") exactly 1 times but received it 0 times
  fails "Time.gm handles fractional usec close to rounding limit" # NoMethodError: undefined method `nsec' for 2000-01-01 12:30:00 UTC
  fails "Time.gm raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 UTC was returned)
  fails "Time.gm raises an ArgumentError for out of range month" # Expected ArgumentError (/(mon|argument) out of range/) but got: ArgumentError (month out of range: 16)
  fails "Time.gm raises an ArgumentError for out of range second" # Expected ArgumentError (argument out of range) but got: ArgumentError (sec out of range: -1)
  fails "Time.httpdate parses RFC-2616 strings" # NoMethodError: undefined method `httpdate' for Time
  fails "Time.local raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 +0100 was returned)
  fails "Time.local raises an ArgumentError for out of range month" # Expected ArgumentError (/(mon|argument) out of range/) but got: ArgumentError (month out of range: 16)
  fails "Time.local raises an ArgumentError for out of range second" # Expected ArgumentError (argument out of range) but got: ArgumentError (sec out of range: -1)
  fails "Time.local uses the 'CET' timezone with TZ=Europe/Amsterdam in 1970" # Expected [0, 0, 0, 16, 5, 1970, 6, 136, false, "Central European Standard Time"] == [0, 0, 0, 16, 5, 1970, 6, 136, false, "CET"] to be truthy but was false
  fails "Time.mktime raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 +0100 was returned)
  fails "Time.mktime raises an ArgumentError for out of range month" # Expected ArgumentError (/(mon|argument) out of range/) but got: ArgumentError (month out of range: 16)
  fails "Time.mktime raises an ArgumentError for out of range second" # Expected ArgumentError (argument out of range) but got: ArgumentError (sec out of range: -1)
  fails "Time.mktime uses the 'CET' timezone with TZ=Europe/Amsterdam in 1970" # Expected [0, 0, 0, 16, 5, 1970, 6, 136, false, "Central European Standard Time"] == [0, 0, 0, 16, 5, 1970, 6, 136, false, "CET"] to be truthy but was false
  fails "Time.new has at least microsecond precision" # NoMethodError: undefined method `nsec' for 2022-12-07 05:20:59 +0100
  fails "Time.new raises an ArgumentError for out of range month" # Expected ArgumentError (/(mon|argument) out of range/) but got: ArgumentError (month out of range: 16)
  fails "Time.new raises an ArgumentError for out of range second" # Expected ArgumentError (argument out of range) but got: ArgumentError (sec out of range: -1)
  fails "Time.new uses the 'CET' timezone with TZ=Europe/Amsterdam in 1970" # Expected [0, 0, 0, 16, 5, 1970, 6, 136, false, "Central European Standard Time"] == [0, 0, 0, 16, 5, 1970, 6, 136, false, "CET"] to be truthy but was false
  fails "Time.new uses the local timezone" # Expected 3600 == -28800 to be truthy but was false
  fails "Time.new with a timezone argument #name method cannot marshal Time if #name method isn't implemented" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument #name method uses the optional #name method for marshaling" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument :in keyword argument allows omitting minor arguments" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument :in keyword argument converts to a provided timezone if all the positional arguments are omitted" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.new with a timezone argument :in keyword argument could be UTC offset as a String in '+HH:MM or '-HH:MM' format" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument :in keyword argument could be UTC offset as a number of seconds" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument :in keyword argument could be a timezone object" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument :in keyword argument raises ArgumentError if two offset arguments are given" # Expected ArgumentError (timezone argument given as positional and keyword arguments) but got: ArgumentError ([Time.new] wrong number of arguments (given 8, expected -1))
  fails "Time.new with a timezone argument :in keyword argument returns a Time with UTC offset specified as a single letter military timezone" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument Time-like argument of #utc_to_local and #local_to_utc methods has attribute values the same as a Time object in UTC" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument Time-like argument of #utc_to_local and #local_to_utc methods implements subset of Time methods" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument Time.new with a String argument accepts precision keyword argument and truncates specified digits of sub-second part" # NoMethodError: undefined method `subsec' for 2021-01-01 00:00:00 +0100
  fails "Time.new with a timezone argument Time.new with a String argument converts precision keyword argument into Integer if is not nil" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.new with a timezone argument Time.new with a String argument parses an ISO-8601 like format" # Expected 2020-01-01 00:00:00 +0100 == 2020-12-24 15:56:17 UTC to be truthy but was false
  fails "Time.new with a timezone argument Time.new with a String argument raise TypeError is can't convert precision keyword argument into Integer" # Expected TypeError (no implicit conversion from string) but got: TypeError (no implicit conversion of Hash into Integer)
  fails "Time.new with a timezone argument Time.new with a String argument raises ArgumentError if String argument is not in the supported format" # Expected ArgumentError (year must be 4 or more digits: 021) but no exception was raised (21-01-01 00:00:00 +0124 was returned)
  fails "Time.new with a timezone argument Time.new with a String argument raises ArgumentError if date/time parts values are not valid" # Expected ArgumentError (mon out of range) but no exception was raised (2020-01-01 00:00:00 +0100 was returned)
  fails "Time.new with a timezone argument Time.new with a String argument raises ArgumentError if part of time string is missing" # Expected ArgumentError (missing sec part: 00:56 ) but no exception was raised (2020-01-01 00:00:00 +0100 was returned)
  fails "Time.new with a timezone argument Time.new with a String argument raises ArgumentError if string has not ascii-compatible encoding" # Expected ArgumentError (time string should have ASCII compatible encoding) but no exception was raised (2021-01-01 00:00:00 +0100 was returned)
  fails "Time.new with a timezone argument Time.new with a String argument raises ArgumentError if subsecond is missing after dot" # Expected ArgumentError (subsecond expected after dot: 00:56:17. ) but no exception was raised (2020-01-01 00:00:00 +0100 was returned)
  fails "Time.new with a timezone argument Time.new with a String argument returns Time in timezone specified in the String argument even if the in keyword argument provided" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.new with a timezone argument Time.new with a String argument returns Time in timezone specified in the String argument" # Expected "2021-01-01 00:00:00 +0100" == "2021-12-25 00:00:00 +0500" to be truthy but was false
  fails "Time.new with a timezone argument Time.new with a String argument returns Time in timezone specified with in keyword argument if timezone isn't provided in the String argument" # TypeError: no implicit conversion of Hash into Integer
  fails "Time.new with a timezone argument accepts timezone argument that must have #local_to_utc and #utc_to_local methods" # Expected to not get Exception but got: ArgumentError (Opal doesn't support other types for a timezone argument than Integer and String)
  fails "Time.new with a timezone argument does not raise exception if timezone does not implement #utc_to_local method" # Expected to not get Exception but got: ArgumentError (Opal doesn't support other types for a timezone argument than Integer and String)
  fails "Time.new with a timezone argument raises TypeError if timezone does not implement #local_to_utc method" # Expected TypeError (/can't convert \w+ into an exact number/) but got: ArgumentError (Opal doesn't support other types for a timezone argument than Integer and String)
  fails "Time.new with a timezone argument returned value by #utc_to_local and #local_to_utc methods could be Time instance" # Expected to not get Exception but got: ArgumentError (Opal doesn't support other types for a timezone argument than Integer and String)
  fails "Time.new with a timezone argument returned value by #utc_to_local and #local_to_utc methods could be Time subclass instance" # Expected to not get Exception but got: ArgumentError (Opal doesn't support other types for a timezone argument than Integer and String)
  fails "Time.new with a timezone argument returned value by #utc_to_local and #local_to_utc methods could be any object with #to_i method" # Expected to not get Exception but got: ArgumentError (Opal doesn't support other types for a timezone argument than Integer and String)
  fails "Time.new with a timezone argument returned value by #utc_to_local and #local_to_utc methods could have any #zone and #utc_offset because they are ignored" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument returned value by #utc_to_local and #local_to_utc methods leads to raising Argument error if difference between argument and result is too large" # Expected ArgumentError (utc_offset out of range) but got: ArgumentError (Opal doesn't support other types for a timezone argument than Integer and String)
  fails "Time.new with a timezone argument returns a Time in the timezone" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument subject's class implements .find_timezone method calls .find_timezone to build a time object at loading marshaled data" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a timezone argument subject's class implements .find_timezone method calls .find_timezone to build a time object if passed zone name as a timezone argument" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: Asia/Colombo
  fails "Time.new with a timezone argument subject's class implements .find_timezone method does not call .find_timezone if passed any not string/numeric/timezone timezone argument" # Expected TypeError (/can't convert \w+ into an exact number/) but got: ArgumentError (Opal doesn't support other types for a timezone argument than Integer and String)
  fails "Time.new with a timezone argument the #abbr method is used by '%Z' in #strftime" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a utc_offset argument raises ArgumentError if the String argument is not in an ASCII-compatible encoding" # Expected ArgumentError but no exception was raised (2000-01-01 00:00:00 -0410.000000000000028 was returned)
  fails "Time.new with a utc_offset argument raises ArgumentError if the string argument is J" # Expected ArgumentError ("+HH:MM", "-HH:MM", "UTC" or "A".."I","K".."Z" expected for utc_offset: J) but got: ArgumentError ("+HH:MM", "-HH:MM", "UTC" expected for utc_offset: J)
  fails "Time.new with a utc_offset argument raises ArgumentError if the utc_offset argument is greater than or equal to 10e9" # Expected ArgumentError but no exception was raised (2000-01-01 00:00:00 +27777746.66666666418314 was returned)
  fails "Time.new with a utc_offset argument returns a Time with UTC offset specified as a single letter military timezone" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: A
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset specified as +HH" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: +05
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset specified as +HH:MM:SS" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: +05:30:37
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset specified as +HHMM" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: +0530
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset specified as +HHMMSS" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: +053037
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset specified as -HH" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: -05
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset specified as -HHMM" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: -0530
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset specified as -HHMMSS" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: -053037
  fails "Time.now :in keyword argument could be UTC offset as a String in '+HH:MM or '-HH:MM' format" # ArgumentError: [Time.now] wrong number of arguments (given 1, expected 0)
  fails "Time.now :in keyword argument could be UTC offset as a number of seconds" # ArgumentError: [Time.now] wrong number of arguments (given 1, expected 0)
  fails "Time.now :in keyword argument could be a timezone object" # ArgumentError: [Time.now] wrong number of arguments (given 1, expected 0)
  fails "Time.now :in keyword argument returns a Time with UTC offset specified as a single letter military timezone" # ArgumentError: [Time.now] wrong number of arguments (given 1, expected 0)
  fails "Time.now has at least microsecond precision" # NoMethodError: undefined method `nsec' for 2022-12-07 05:21:38 +0100
  fails "Time.now uses the local timezone" # Expected 3600 == -28800 to be truthy but was false
  fails "Time.rfc2822 parses RFC-2822 strings" # NoMethodError: undefined method `rfc2822' for Time
  fails "Time.rfc2822 parses RFC-822 strings" # NoMethodError: undefined method `rfc2822' for Time
  fails "Time.rfc822 parses RFC-2822 strings" # NoMethodError: undefined method `rfc2822' for Time
  fails "Time.rfc822 parses RFC-822 strings" # NoMethodError: undefined method `rfc2822' for Time
  fails "Time.utc handles fractional usec close to rounding limit" # NoMethodError: undefined method `nsec' for 2000-01-01 12:30:00 UTC
  fails "Time.utc raises an ArgumentError for out of range microsecond" # Expected ArgumentError but no exception was raised (2000-01-01 20:15:01 UTC was returned)
  fails "Time.utc raises an ArgumentError for out of range month" # Expected ArgumentError (/(mon|argument) out of range/) but got: ArgumentError (month out of range: 16)
  fails "Time.utc raises an ArgumentError for out of range second" # Expected ArgumentError (argument out of range) but got: ArgumentError (sec out of range: -1)  
  fails "Time.xmlschema parses ISO-8601 strings" # NoMethodError: undefined method `xmlschema' for Time
  fails_badly "Marshal.load for a Time keeps the local zone" # Expected "Fiji Standard Time" == "Fiji Summer Time" to be truthy but was false
  fails_badly "Time#dst? dst? returns whether time is during daylight saving time" # Expected false == true to be truthy but was false
  fails_badly "Time#isdst dst? returns whether time is during daylight saving time" # Expected false == true to be truthy but was false
  fails_badly "Time#strftime with %z formats a local time with positive UTC offset as '+HHMM'" # Expected "+0900" == "+0100" to be truthy but was false
  fails_badly "Time#yday returns an integer representing the day of the year, 1..366" # Expected 117 == 116 to be truthy but was false
  fails_badly "Time.new with a timezone argument Time.new with a String argument returns Time in local timezone if not provided in the String argument" # Expected "Fiji Summer Time" == "Fiji Standard Time" to be truthy but was false
end
