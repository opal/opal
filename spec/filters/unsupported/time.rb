# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Time" do
  fails "Time#+ accepts arguments that can be coerced into Rational" # Mock '10' expected to receive to_r("any_args") exactly 1 times but received it 0 times
  fails "Time#+ adds a negative Float" # Expected 700000 == 699999 to be truthy but was false
  fails "Time#+ increments the time by the specified amount as rational numbers" # Expected 1970-01-01 01:00:01 +0100 == 1970-01-01 01:00:02 +0100 to be truthy but was false
  fails "Time#+ maintains microseconds precision" # Expected 0 == 999999 to be truthy but was false
  fails "Time#+ maintains nanoseconds precision" # NoMethodError: undefined method `nsec' for 1970-01-01 01:00:08 +0100
  fails "Time#+ maintains subseconds precision" # NoMethodError: undefined method `subsec' for 1970-01-01 01:00:08 +0100
  fails "Time#+ returns a time with the same fixed offset as self" # Expected 60 == 3600 to be truthy but was false
  fails "Time#+ tracks microseconds" # Expected 0 == 123456 to be truthy but was false
  fails "Time#+ tracks nanoseconds" # NoMethodError: undefined method `nsec' for 1970-01-01 01:00:00 +0100
  fails "Time#- accepts arguments that can be coerced into Rational" # Mock '10' expected to receive to_r("any_args") exactly 1 times but received it 0 times
  fails "Time#- maintains microseconds precision" # Expected 0 == 999999 to be truthy but was false
  fails "Time#- maintains nanoseconds precision" # NoMethodError: undefined method `nsec' for 1970-01-01 01:00:10 +0100
  fails "Time#- maintains precision" # Expected 1970-01-01 01:00:09 +0100 == 1970-01-01 01:00:09 +0100 to be falsy but was true
  fails "Time#- maintains subseconds precision" # NoMethodError: undefined method `subsec' for 1970-01-01 00:59:59 +0100
  fails "Time#- returns a time with nanoseconds precision between two time objects" # Expected 86399 == 86399.999999998 to be truthy but was false
  fails "Time#- returns a time with the same fixed offset as self" # Expected 60 == 3600 to be truthy but was false
  fails "Time#- tracks microseconds" # Expected 122000 == 123456 to be truthy but was false
  fails "Time#- tracks nanoseconds" # NoMethodError: undefined method `nsec' for 1970-01-01 01:00:00 +0100
  fails "Time#<=> returns -1 if the first argument is a fraction of a microsecond before the second argument" # Expected 0 == -1 to be truthy but was false
  fails "Time#<=> returns -1 if the first argument is a point in time before the second argument (down to a microsecond)" # Expected 0 == -1 to be truthy but was false
  fails "Time#<=> returns 1 if the first argument is a fraction of a microsecond after the second argument" # Expected 0 == 1 to be truthy but was false
  fails "Time#<=> returns 1 if the first argument is a point in time after the second argument (down to a microsecond)" # Expected 0 == 1 to be truthy but was false
  fails "Time#dup returns a subclass instance" # Expected 2022-12-07 04:50:25 +0100 (Time) to be an instance of #<Class:0x3828>
  fails "Time#eql? returns false if self and other have differing fractional microseconds" # Expected 1970-01-01 01:01:40 +0100 not to have same value or type as 1970-01-01 01:01:40 +0100
  fails "Time#eql? returns false if self and other have differing numbers of microseconds" # Expected 1970-01-01 01:01:40 +0100 not to have same value or type as 1970-01-01 01:01:40 +0100
  fails "Time#getlocal raises ArgumentError if the String argument is not of the form (+|-)HH:MM" # Expected ArgumentError but got: NoMethodError (undefined method `getlocal' for 2022-12-07 04:50:51 +0100)
  fails "Time#getlocal raises ArgumentError if the argument represents a value greater than or equal to 86400 seconds" # NoMethodError: undefined method `getlocal' for 2022-12-07 04:50:51 +0100
  fails "Time#getlocal raises ArgumentError if the argument represents a value less than or equal to -86400 seconds" # NoMethodError: undefined method `getlocal' for 2022-12-07 04:50:51 +0100
  fails "Time#getlocal returns a Time with UTC offset specified as an Integer number of seconds" # NoMethodError: undefined method `getlocal' for 2007-01-09 12:00:00 UTC
  fails "Time#getlocal returns a Time with a UTC offset of the specified number of Rational seconds" # NoMethodError: undefined method `getlocal' for 2007-01-09 12:00:00 UTC
  fails "Time#getlocal returns a Time with a UTC offset specified as +HH:MM" # NoMethodError: undefined method `getlocal' for 2007-01-09 12:00:00 UTC
  fails "Time#getlocal returns a Time with a UTC offset specified as -HH:MM" # NoMethodError: undefined method `getlocal' for 2007-01-09 12:00:00 UTC
  fails "Time#getlocal returns a new time which is the local representation of time" # NoMethodError: undefined method `localtime' for 2007-01-09 12:00:00 UTC
  fails "Time#getlocal returns a new time with the correct utc_offset according to the set timezone" # Expected -60 == -3600 to be truthy but was false
  fails "Time#getlocal with an argument that responds to #to_int coerces using #to_int" # Mock 'integer' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Time#getlocal with an argument that responds to #to_r coerces using #to_r" # Mock 'rational' expected to receive to_r("any_args") exactly 1 times but received it 0 times
  fails "Time#getlocal with an argument that responds to #to_str coerces using #to_str" # Mock 'string' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "Time#gmt_offset given negative offset returns a negative offset" # Expected -180 == -10800 to be truthy but was false
  fails "Time#gmt_offset given positive offset returns a positive offset" # Expected 180 == 10800 to be truthy but was false
  fails "Time#gmt_offset returns offset as Rational" # Expected 120.75000000000001 == 7245 to be truthy but was false
  fails "Time#gmt_offset returns the offset in seconds between the timezone of time and UTC" # Expected 3600 == 10800 to be truthy but was false
  fails "Time#gmtoff given negative offset returns a negative offset" # Expected -180 == -10800 to be truthy but was false
  fails "Time#gmtoff given positive offset returns a positive offset" # Expected 180 == 10800 to be truthy but was false
  fails "Time#gmtoff returns offset as Rational" # Expected 120.75000000000001 == 7245 to be truthy but was false
  fails "Time#gmtoff returns the offset in seconds between the timezone of time and UTC" # Expected 3600 == 10800 to be truthy but was false
  fails "Time#localtime changes the timezone according to the set one" # Expected -60 == -3600 to be truthy but was false
  fails "Time#localtime converts self to local time, modifying the receiver" # NoMethodError: undefined method `localtime' for 2007-01-09 12:00:00 UTC
  fails "Time#localtime converts time to the UTC offset specified as an Integer number of seconds" # NoMethodError: undefined method `localtime' for 2007-01-09 12:00:00 UTC
  fails "Time#localtime does nothing if already in a local time zone" # NoMethodError: undefined method `localtime' for 2005-02-27 22:50:00 +0100
  fails "Time#localtime raises ArgumentError if the String argument is not of the form (+|-)HH:MM" # Expected ArgumentError but got: NoMethodError (undefined method `localtime' for 2022-12-07 04:50:47 +0100)
  fails "Time#localtime raises ArgumentError if the argument represents a value greater than or equal to 86400 seconds" # NoMethodError: undefined method `localtime' for 2022-12-07 04:50:47 +0100
  fails "Time#localtime raises ArgumentError if the argument represents a value less than or equal to -86400 seconds" # NoMethodError: undefined method `localtime' for 2022-12-07 04:50:47 +0100
  fails "Time#localtime returns a Time with a UTC offset of the specified number of Rational seconds" # NoMethodError: undefined method `localtime' for 2007-01-09 12:00:00 UTC
  fails "Time#localtime returns a Time with a UTC offset specified as +HH:MM" # NoMethodError: undefined method `localtime' for 2007-01-09 12:00:00 UTC
  fails "Time#localtime returns a Time with a UTC offset specified as -HH:MM" # NoMethodError: undefined method `localtime' for 2007-01-09 12:00:00 UTC
  fails "Time#localtime returns self" # NoMethodError: undefined method `localtime' for 2007-01-09 12:00:00 UTC
  fails "Time#localtime with an argument that responds to #to_int coerces using #to_int" # Mock 'integer' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Time#localtime with an argument that responds to #to_r coerces using #to_r" # Mock 'rational' expected to receive to_r("any_args") exactly 1 times but received it 0 times
  fails "Time#localtime with an argument that responds to #to_str coerces using #to_str" # Mock 'string' expected to receive to_str("any_args") exactly 1 times but received it 0 times
  fails "Time#nsec returns 0 for a Time constructed with a whole number of seconds" # NoMethodError: undefined method `nsec' for 1970-01-01 01:01:40 +0100
  fails "Time#nsec returns the nanoseconds part of a Time constructed with a Float number of seconds" # NoMethodError: undefined method `nsec' for 1970-01-01 01:00:10 +0100
  fails "Time#nsec returns the nanoseconds part of a Time constructed with a Rational number of seconds" # NoMethodError: undefined method `nsec' for 1970-01-01 01:00:01 +0100
  fails "Time#nsec returns the nanoseconds part of a Time constructed with an Float number of microseconds" # NoMethodError: undefined method `nsec' for 1970-01-01 01:00:00 +0100
  fails "Time#nsec returns the nanoseconds part of a Time constructed with an Integer number of microseconds" # NoMethodError: undefined method `nsec' for 1970-01-01 01:00:00 +0100
  fails "Time#nsec returns the nanoseconds part of a Time constructed with an Rational number of microseconds" # NoMethodError: undefined method `nsec' for 1970-01-01 01:00:00 +0100
  fails "Time#strftime with %L formats the milliseconds of the second" # Expected "000" == "100" to be truthy but was false
  fails "Time#strftime with %z formats a UTC time offset as '+0000'" # Expected "+0100" == "+0000" to be truthy but was false
  fails "Time#strftime with %z formats a local time with negative UTC offset as '-HHMM'" # Expected "+0100" == "-0800" to be truthy but was false
  fails "Time#strftime with %z formats a time with fixed offset as '+/-HH:MM:SS' with '::' specifier" # Expected "+01:01.0833333333333286" == "+01:01:05" to be truthy but was false
  fails "Time#subsec returns the fractional seconds as a Rational for a Time constructed with a Float number of seconds" # NoMethodError: undefined method `subsec' for 1970-01-01 01:00:10 +0100
  fails "Time#subsec returns the fractional seconds as a Rational for a Time constructed with a Rational number of seconds" # NoMethodError: undefined method `subsec' for 1970-01-01 01:00:01 +0100
  fails "Time#subsec returns the fractional seconds as a Rational for a Time constructed with an Float number of microseconds" # NoMethodError: undefined method `subsec' for 1970-01-01 01:00:00 +0100
  fails "Time#subsec returns the fractional seconds as a Rational for a Time constructed with an Integer number of microseconds" # NoMethodError: undefined method `subsec' for 1970-01-01 01:00:00 +0100
  fails "Time#subsec returns the fractional seconds as a Rational for a Time constructed with an Rational number of microseconds" # NoMethodError: undefined method `subsec' for 1970-01-01 01:00:00 +0100
  fails "Time#to_a returns a 10 element array representing the deconstructed time" # Expected [0, 0, 1, 1, 1, 1970, 4, 1, false, "Central European Standard Time"] == [0, 0, 18, 31, 12, 1969, 3, 365, false, "CST"] to be truthy but was false
  fails "Time#to_r returns a Rational even for a whole number of seconds" # NoMethodError: undefined method `to_r' for 1970-01-01 01:00:02 +0100
  fails "Time#to_r returns the a Rational representing seconds and subseconds since the epoch" # NoMethodError: undefined method `to_r' for 1970-01-01 01:00:01 +0100
  fails "Time#usec returns the microseconds for time created by Time#local" # Expected 0 == 780000 to be truthy but was false
  fails "Time#usec returns the microseconds part of a Time constructed with a Rational number of seconds" # Expected 0 == 500000 to be truthy but was false
  fails "Time#usec returns the microseconds part of a Time constructed with an Float number of microseconds > 1" # Expected 0 == 3 to be truthy but was false
  fails "Time#usec returns the microseconds part of a Time constructed with an Integer number of microseconds" # Expected 999000 == 999999 to be truthy but was false
  fails "Time#usec returns the microseconds part of a Time constructed with an Rational number of microseconds > 1" # Expected 0 == 9 to be truthy but was false
  fails "Time#utc_offset given negative offset returns a negative offset" # Expected -180 == -10800 to be truthy but was false
  fails "Time#utc_offset given positive offset returns a positive offset" # Expected 180 == 10800 to be truthy but was false
  fails "Time#utc_offset returns offset as Rational" # Expected 120.75000000000001 == 7245 to be truthy but was false
  fails "Time#utc_offset returns the offset in seconds between the timezone of time and UTC" # Expected 3600 == 10800 to be truthy but was false
  fails "Time#zone Encoding.default_internal is set doesn't raise errors for a Time with a fixed offset" # NoMethodError: undefined method `default_internal' for Encoding
  fails "Time#zone returns nil when getting the local time with a fixed offset" # NoMethodError: undefined method `getlocal' for 2005-02-27 22:50:00 -0100
  fails "Time#zone returns the correct timezone for a local time" # NoMethodError: undefined method `getlocal' for 2005-02-27 22:50:00 -0100
  fails "Time#zone returns the time zone used for time" # Expected "Central European Standard Time" == "EST" to be truthy but was false
  fails "Time.at passed Numeric returns a subclass instance on a Time subclass" # Expected 1970-01-01 01:00:00 +0100 (Time) to be an instance of #<Class:0x29828>
  fails "Time.at passed Time returns a subclass instance" # Expected 2022-12-07 04:50:36 +0100 (Time) to be an instance of #<Class:0x29836>
  fails "Time.at passed [Integer, Numeric] returns a Time object representing the given number of seconds and Float microseconds since 1970-01-01 00:00:00 UTC" # NoMethodError: undefined method `tv_nsec' for 1970-01-01 01:00:10 +0100
  fails "Time.at passed non-Time, non-Numeric with an argument that responds to #to_r coerces using #to_r" # Mock 'rational' expected to receive to_r("any_args") exactly 1 times but received it 0 times
  fails "Time.at with a second argument that responds to #to_r coerces using #to_r" # Mock 'rational' expected to receive to_r("any_args") exactly 1 times but received it 0 times
  fails "Time.gm handles fractional microseconds as a Float" # Expected 0 == 1 to be truthy but was false
  fails "Time.gm handles fractional microseconds as a Rational" # Expected 0 == 9 to be truthy but was false
  fails "Time.gm handles fractional seconds as a Rational" # Expected 0 == 900000 to be truthy but was false
  fails "Time.gm handles microseconds" # Expected 0 == 123 to be truthy but was false
  fails "Time.gm ignores fractional seconds if a passed fractional number of microseconds" # Expected 750000 == 9 to be truthy but was false
  fails "Time.gm ignores fractional seconds if a passed whole number of microseconds" # Expected 750000 == 2 to be truthy but was false
  fails "Time.gm returns subclass instances" # Expected 2008-12-01 00:00:00 UTC (Time) to be an instance of #<Class:0x864ca>
  fails "Time.local creates a time based on given C-style gmtime arguments, interpreted in the local time zone" # Expected [1, 15, 20, 1, 1, 2000, 6, 1, false, "Central European Standard Time"] == [1, 15, 20, 1, 1, 2000, 6, 1, false, "PST"] to be truthy but was false
  fails "Time.local creates a time based on given values, interpreted in the local time zone" # Expected [1, 15, 20, 1, 1, 2000, 6, 1, false, "Central European Standard Time"] == [1, 15, 20, 1, 1, 2000, 6, 1, false, "PST"] to be truthy but was false
  fails "Time.local creates the correct time just after dst change" # Expected 7200 == -18000 to be truthy but was false
  fails "Time.local handles fractional microseconds as a Float" # Expected 0 == 1 to be truthy but was false
  fails "Time.local handles fractional microseconds as a Rational" # Expected 0 == 9 to be truthy but was false
  fails "Time.local handles fractional seconds as a Rational" # Expected 0 == 900000 to be truthy but was false
  fails "Time.local handles microseconds" # Expected 0 == 123 to be truthy but was false
  fails "Time.local ignores fractional seconds if a passed fractional number of microseconds" # Expected 750000 == 9 to be truthy but was false
  fails "Time.local ignores fractional seconds if a passed whole number of microseconds" # Expected 750000 == 2 to be truthy but was false
  fails "Time.local returns subclass instances" # Expected 2008-12-01 00:00:00 +0100 (Time) to be an instance of #<Class:0x1c7d0>
  fails "Time.mktime creates a time based on given C-style gmtime arguments, interpreted in the local time zone" # Expected [1, 15, 20, 1, 1, 2000, 6, 1, false, "Central European Standard Time"] == [1, 15, 20, 1, 1, 2000, 6, 1, false, "PST"] to be truthy but was false
  fails "Time.mktime creates a time based on given values, interpreted in the local time zone" # Expected [1, 15, 20, 1, 1, 2000, 6, 1, false, "Central European Standard Time"] == [1, 15, 20, 1, 1, 2000, 6, 1, false, "PST"] to be truthy but was false
  fails "Time.mktime creates the correct time just after dst change" # Expected 7200 == -18000 to be truthy but was false
  fails "Time.mktime handles fractional microseconds as a Float" # Expected 0 == 1 to be truthy but was false
  fails "Time.mktime handles fractional microseconds as a Rational" # Expected 0 == 9 to be truthy but was false
  fails "Time.mktime handles fractional seconds as a Rational" # Expected 0 == 900000 to be truthy but was false
  fails "Time.mktime handles microseconds" # Expected 0 == 123 to be truthy but was false
  fails "Time.mktime ignores fractional seconds if a passed fractional number of microseconds" # Expected 750000 == 9 to be truthy but was false
  fails "Time.mktime ignores fractional seconds if a passed whole number of microseconds" # Expected 750000 == 2 to be truthy but was false
  fails "Time.mktime returns subclass instances" # Expected 2008-12-01 00:00:00 +0100 (Time) to be an instance of #<Class:0x5e2b2>
  fails "Time.new creates a subclass instance if called on a subclass" # Expected 2022-12-07 04:51:02 +0100 (Time) to be an instance of TimeSpecs::SubTime
  fails "Time.new creates a time based on given values, interpreted in the local time zone" # Expected [1, 15, 20, 1, 1, 2000, 6, 1, false, "Central European Standard Time"] == [1, 15, 20, 1, 1, 2000, 6, 1, false, "PST"] to be truthy but was false
  fails "Time.new handles fractional seconds as a Rational" # Expected 0 == 900000 to be truthy but was false
  fails "Time.new returns subclass instances" # Expected 2008-12-01 00:00:00 +0100 (Time) to be an instance of #<Class:0x8e0da>
  fails "Time.new with a utc_offset argument raises ArgumentError if the argument represents a value greater than or equal to 86400 seconds" # Expected 1439.9833333333333 == 86399 to be truthy but was false
  fails "Time.new with a utc_offset argument raises ArgumentError if the argument represents a value less than or equal to -86400 seconds" # Expected -1439.9833333333333 == -86399 to be truthy but was false
  fails "Time.new with a utc_offset argument raises ArgumentError if the hour value is greater than 23" # Expected ArgumentError but no exception was raised (2000-01-01 00:00:00 +2400 was returned)
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset of the specified number of Integer seconds" # Expected 2.05 == 123 to be truthy but was false
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset of the specified number of Rational seconds" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset specified as +HH:MM" # Expected 330 == 19800 to be truthy but was false
  fails "Time.new with a utc_offset argument returns a Time with a UTC offset specified as -HH:MM" # ArgumentError: "+HH:MM", "-HH:MM", "UTC" expected for utc_offset: -04:10:43
  fails "Time.new with a utc_offset argument returns a local Time if the argument is nil" # Expected 3600 == -28800 to be truthy but was false
  fails "Time.new with a utc_offset argument returns a non-UTC time" # Expected 2000-01-01 00:00:00 UTC.utc? to be falsy but was true
  fails "Time.new with a utc_offset argument with an argument that responds to #to_int coerces using #to_int" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a utc_offset argument with an argument that responds to #to_r coerces using #to_r" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.new with a utc_offset argument with an argument that responds to #to_str coerces using #to_str" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "Time.now creates a subclass instance if called on a subclass" # Expected 2022-12-07 04:50:35 +0100 (Time) to be an instance of TimeSpecs::SubTime
  fails "Time.utc handles fractional microseconds as a Float" # Expected 0 == 1 to be truthy but was false
  fails "Time.utc handles fractional microseconds as a Rational" # Expected 0 == 9 to be truthy but was false
  fails "Time.utc handles fractional seconds as a Rational" # Expected 0 == 900000 to be truthy but was false
  fails "Time.utc handles microseconds" # Expected 0 == 123 to be truthy but was false
  fails "Time.utc ignores fractional seconds if a passed fractional number of microseconds" # Expected 750000 == 9 to be truthy but was false
  fails "Time.utc ignores fractional seconds if a passed whole number of microseconds" # Expected 750000 == 2 to be truthy but was false
  fails "Time.utc returns subclass instances" # Expected 2008-12-01 00:00:00 UTC (Time) to be an instance of #<Class:0x88f30>
  fails_badly "Marshal.load for a Time loads the zone" # Seasonal failure
  fails_badly "Time#inspect formats the local time following the pattern 'yyyy-MM-dd HH:mm:ss Z'" # Seasonal failure
  fails_badly "Time#to_s formats the local time following the pattern 'yyyy-MM-dd HH:mm:ss Z'" # Seasonal failure
end
