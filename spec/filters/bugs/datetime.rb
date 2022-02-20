# NOTE: run bin/format-filters after changing this file
opal_filter "DateTime" do
  fails "DateTime#+ is able to add sub-millisecond precision values" # Expected 0 == 864864 to be truthy but was false
  fails "DateTime#- correctly calculates sub-millisecond time differences" # Expected 0 == 59.000001 to be truthy but was false
  fails "DateTime#- is able to subtract sub-millisecond precision values" # TypeError: TypeError
  fails "DateTime#hour adds 24 to negative hours" # ArgumentError: hour out of range: -10
  fails "DateTime#hour raises an error for Float" # Expected ArgumentError but no exception was raised (1 was returned)
  fails "DateTime#hour raises an error for Rational" # Expected ArgumentError but no exception was raised (#<DateTime:0x74530 @date=-4712-01-01 00:00:00 UTC> was returned)
  fails "DateTime#second adds 60 to negative values" # ArgumentError: sec out of range: -20
  fails "DateTime#second raises an error when minute is given as a rational" # Expected ArgumentError but no exception was raised (#<DateTime:0xa6acc @date=-4712-01-01 00:05:00 UTC> was returned)
  fails "DateTime#second raises an error, when the second is greater or equal than 60" # Expected ArgumentError but no exception was raised (#<DateTime:0xa69da @date=-4712-01-01 00:01:00 UTC> was returned)
  fails "DateTime#strftime returns the timezone with %Z" # Expected "Central European Summer Time" == "+02:00" to be truthy but was false
  fails "DateTime#strftime should be able to print the commercial year with leading zeroes" # Expected "200" == "0200" to be truthy but was false
  fails "DateTime#strftime should be able to print the commercial year with only two digits" # TypeError: no implicit conversion of Range into Integer
  fails "DateTime#strftime should be able to print the datetime with no argument" # ArgumentError: [Time#strftime] wrong number of arguments (given 0, expected 1)
  fails "DateTime#strftime should be able to show a full notation" # Expected "%+" == "Sat Feb  3 04:05:06 +00:00 2001" to be truthy but was false
  fails "DateTime#strftime should be able to show default Logger format" # Expected "2001-12-03T04:05:06.000000 " == "2001-12-03T04:05:06.100000 " to be truthy but was false
  fails "DateTime#strftime should be able to show the commercial week day" # Expected "1" == "7" to be truthy but was false
  fails "DateTime#strftime should be able to show the number of seconds since the unix epoch for a date" # Expected "954972000" == "954979200" to be truthy but was false
  fails "DateTime#strftime should be able to show the number of seconds since the unix epoch" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "DateTime#strftime should be able to show the timezone of the date with a : separator" # Expected "+0200" == "+0000" to be truthy but was false
  fails "DateTime#strftime should be able to show the timezone with a : separator" # Expected "Central European Standard Time" == "+00:00" to be truthy but was false
  fails "DateTime#strftime should be able to show the week number with the week starting on Sunday (%U) and Monday (%W)" # Expected "%U" == "14" to be truthy but was false
  fails "DateTime#strftime shows the number of milliseconds since epoch" # Expected "%Q" == "0" to be truthy but was false
  fails "DateTime#strftime with %L formats the milliseconds of the second" # Expected "000" == "100" to be truthy but was false
  fails "DateTime#strftime with %N formats the microseconds of the second with %6N" # Expected "000000" == "042000" to be truthy but was false
  fails "DateTime#strftime with %N formats the milliseconds of the second with %3N" # Expected "000" == "050" to be truthy but was false
  fails "DateTime#strftime with %N formats the nanoseconds of the second with %9N" # Expected "000000000" == "001234000" to be truthy but was false
  fails "DateTime#strftime with %N formats the nanoseconds of the second with %N" # Expected "000000000" == "001234560" to be truthy but was false
  fails "DateTime#strftime with %N formats the picoseconds of the second with %12N" # Expected "000000000000" == "999999999999" to be truthy but was false
  fails "DateTime#strftime with %z formats a UTC time offset as '+0000'" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "DateTime#strftime with %z formats a local time with negative UTC offset as '-HHMM'" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "DateTime#strftime with %z formats a local time with positive UTC offset as '+HHMM'" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "DateTime#strftime with %z formats a time with fixed negative offset as '-HHMM'" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "DateTime#strftime with %z formats a time with fixed offset as '+/-HH:MM' with ':' specifier" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "DateTime#strftime with %z formats a time with fixed offset as '+/-HH:MM:SS' with '::' specifier" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "DateTime#strftime with %z formats a time with fixed positive offset as '+HHMM'" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "DateTime#to_date maintains the same mday" # NoMethodError: undefined method `mday' for #<Date:0x19c4c @date=2012-12-24 00:00:00 +0100>
  fails "DateTime#to_date maintains the same month" # NoMethodError: undefined method `mon' for #<Date:0x19c3e @date=2012-12-24 00:00:00 +0100>
  fails "DateTime#to_s maintains timezone regardless of local time" # Expected "2012-12-23" == "2012-12-24T01:02:03+03:00" to be truthy but was false
  fails "DateTime#to_time preserves the same time regardless of local time or zone" # Expected 180 == 10800 to be truthy but was false
  fails "DateTime#to_time returns a Time representing the same instant" # Expected 22 == 23 to be truthy but was false
  fails "DateTime.min adds 60 to negative minutes" # ArgumentError: min out of range: -20
  fails "DateTime.min raises an error for Float" # Expected ArgumentError but no exception was raised (#<DateTime:0x1c098 @date=-4712-01-01 00:05:00 UTC> was returned)
  fails "DateTime.min raises an error for Rational" # Expected ArgumentError but no exception was raised (#<DateTime:0x1bee2 @date=-4712-01-01 02:00:00 UTC> was returned)
  fails "DateTime.minute adds 60 to negative minutes" # ArgumentError: min out of range: -20
  fails "DateTime.minute raises an error for Float" # Expected ArgumentError but no exception was raised (#<DateTime:0x365c2 @date=-4712-01-01 00:05:00 UTC> was returned)
  fails "DateTime.minute raises an error for Rational" # Expected ArgumentError but no exception was raised (#<DateTime:0x3669a @date=-4712-01-01 02:00:00 UTC> was returned)
  fails "DateTime.new sets all values to default if passed no arguments" # Exception: Cannot read properties of undefined (reading '$/')
  fails "DateTime.new takes the eighth argument as the date of calendar reform" # NoMethodError: undefined method `start' for #<DateTime:0x191a0 @date=1-02-03 04:05:06 +0000.011666666666666665>
  fails "DateTime.new takes the seventh argument as an offset" # Expected 0.000008101851851851852 == 0.7 to be truthy but was false
  fails "DateTime.now grabs the local timezone" # Expected "+01:00" == "-08:00" to be truthy but was false
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid day values" # Expected ArgumentError but no exception was raised (#<DateTime:0x18d2e @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid hour values" # Expected ArgumentError but no exception was raised (#<DateTime:0x18e00 @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid minute values" # Expected ArgumentError but no exception was raised (#<DateTime:0x18ed8 @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid month values" # Expected ArgumentError but no exception was raised (#<DateTime:0x18c5c @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid second values" # Expected ArgumentError but no exception was raised (#<DateTime:0x18b8a @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN> was returned)
  fails "DateTime.parse parses DD as month day number" # Expected #<DateTime:0x18582 @date=2001-10-01 00:00:00 +0200> == #<DateTime:0x1858a @date=2022-02-10 00:00:00 +0100> to be truthy but was false
  fails "DateTime.parse parses DDD as year day number" # Expected #<DateTime:0x18818 @date=100-01-01 00:00:00 +0124> == #<DateTime:0x18820 @date=2022-04-10 00:00:00 +0200> to be truthy but was false
  fails "DateTime.parse parses MMDD as month and day" # Expected #<DateTime:0x183d0 @date=1108-01-01 00:00:00 +0124> == #<DateTime:0x183d6 @date=2022-11-08 00:00:00 +0100> to be truthy but was false
  fails "DateTime.parse parses YYDDD as year and day number in 1969--2068" # Expected #<DateTime:0x189cc @date=10100-01-01 00:00:00 +0100> == #<DateTime:0x189d0 @date=2010-04-10 00:00:00 +0200> to be truthy but was false
  fails "DateTime.parse parses YYMMDD as year, month and day in 1969--2068" # Expected #<DateTime:0x18216 @date=201023-01-01 00:00:00 +0100> == #<DateTime:0x1821a @date=2020-10-23 00:00:00 +0200> to be truthy but was false
  fails "DateTime.parse parses a day name into a DateTime object" # NoMethodError: undefined method `cwyear' for #<DateTime:0x18808 @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN>
  fails "DateTime.parse throws an argument error for a single digit" # Expected ArgumentError but no exception was raised (#<DateTime:0x18738 @date=2001-01-01 00:00:00 +0100> was returned)
  fails "DateTime.parse(.) parses DD.MM.YYYY into a DateTime object" # Expected 10 == 1 to be truthy but was false
  fails "DateTime.parse(.) parses YY.MM.DD into a DateTime object using the year 20YY" # Expected 2007 == 2010 to be truthy but was false
  fails "DateTime.parse(.) parses YY.MM.DD using the year digits as 20YY when given true as additional argument" # ArgumentError: [DateTime.parse] wrong number of arguments (given 2, expected 1)
  fails "DateTime.sec adds 60 to negative values" # ArgumentError: sec out of range: -20
  fails "DateTime.sec raises an error when minute is given as a rational" # Expected ArgumentError but no exception was raised (#<DateTime:0x1bccc @date=-4712-01-01 00:05:00 UTC> was returned)
  fails "DateTime.sec raises an error, when the second is greater or equal than 60" # Expected ArgumentError but no exception was raised (#<DateTime:0x1bdb8 @date=-4712-01-01 00:01:00 UTC> was returned)
end
