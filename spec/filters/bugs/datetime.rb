# NOTE: run bin/format-filters after changing this file
opal_filter "DateTime" do
  fails "DateTime#+ is able to add sub-millisecond precision values" # Expected 0 == 864864 to be truthy but was false
  fails "DateTime#- correctly calculates sub-millisecond time differences" # Expected 5097600 == 59.000001 to be truthy but was false
  fails "DateTime#- is able to subtract sub-millisecond precision values" # Expected 0 == (13717421/9600000000) to be truthy but was false
  fails "DateTime#hour adds 24 to negative hours" # ArgumentError: hour out of range: -10
  fails "DateTime#hour raises an error for Float" # Expected ArgumentError but no exception was raised (1 was returned)
  fails "DateTime#hour raises an error for Rational" # Expected ArgumentError but no exception was raised (#<DateTime:0xa6cca @date=-4712-01-01 00:00:00 UTC, @start=2299161> was returned)
  fails "DateTime#second adds 60 to negative values" # ArgumentError: sec out of range: -20
  fails "DateTime#second raises an error when minute is given as a rational" # Expected ArgumentError but no exception was raised (#<DateTime:0x4da4 @date=-4712-01-01 00:05:00 UTC, @start=2299161> was returned)
  fails "DateTime#second raises an error, when the second is greater or equal than 60" # Expected ArgumentError but no exception was raised (#<DateTime:0x4c16 @date=-4712-01-01 00:01:00 UTC, @start=2299161> was returned)
  fails "DateTime#strftime returns the timezone with %Z" # Expected "UTC" == "-00:00" to be truthy but was false
  fails "DateTime#strftime should be able to print the commercial year with leading zeroes" # Expected "200" == "0200" to be truthy but was false
  fails "DateTime#strftime should be able to print the commercial year with only two digits" # TypeError: no implicit conversion of Range into Integer
  fails "DateTime#strftime should be able to print the datetime with no argument" # Expected "2001-02-03T04:05:06-00:00" == "2001-02-03T04:05:06+00:00" to be truthy but was false
  fails "DateTime#strftime should be able to show a full notation" # Expected "%+" == "Sat Feb  3 04:05:06 +00:00 2001" to be truthy but was false
  fails "DateTime#strftime should be able to show default Logger format" # Expected "2001-12-03T04:05:06.000000 " == "2001-12-03T04:05:06.100000 " to be truthy but was false
  fails "DateTime#strftime should be able to show the commercial week day" # Expected "1" == "7" to be truthy but was false
  fails "DateTime#strftime should be able to show the commercial week" # Expected " 3-FEB-2001" == " 3-Feb-2001" to be truthy but was false
  fails "DateTime#strftime should be able to show the number of seconds since the unix epoch" # ArgumentError: Opal doesn't support other types for a timezone argument than Integer and String
  fails "DateTime#strftime should be able to show the timezone of the date with a : separator" # Expected "-0000" == "+0000" to be truthy but was false
  fails "DateTime#strftime should be able to show the timezone with a : separator" # Expected "UTC" == "+00:00" to be truthy but was false
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
  fails "DateTime#to_time preserves the same time regardless of local time or zone" # Expected 180 == 10800 to be truthy but was false
  fails "DateTime.min adds 60 to negative minutes" # ArgumentError: min out of range: -20
  fails "DateTime.min raises an error for Float" # Expected ArgumentError but no exception was raised (#<DateTime:0x55fc @date=-4712-01-01 00:05:00 UTC, @start=2299161> was returned)
  fails "DateTime.min raises an error for Rational" # Expected ArgumentError but no exception was raised (#<DateTime:0x52ea @date=-4712-01-01 00:05:00 UTC, @start=2299161> was returned)
  fails "DateTime.minute adds 60 to negative minutes" # ArgumentError: min out of range: -20
  fails "DateTime.minute raises an error for Float" # Expected ArgumentError but no exception was raised (#<DateTime:0x6922 @date=-4712-01-01 00:05:00 UTC, @start=2299161> was returned)
  fails "DateTime.minute raises an error for Rational" # Expected ArgumentError but no exception was raised (#<DateTime:0x6618 @date=-4712-01-01 02:00:00 UTC, @start=2299161> was returned)
  fails "DateTime.new takes the seventh argument as an offset" # Expected 1.3503086419753086e-7 == 0.7 to be truthy but was false
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid day values" # Expected ArgumentError but no exception was raised (#<DateTime:0x8d76 @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN, @start=2299161> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid hour values" # Expected ArgumentError but no exception was raised (#<DateTime:0x88ea @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN, @start=2299161> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid minute values" # Expected ArgumentError but no exception was raised (#<DateTime:0x9076 @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN, @start=2299161> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid month values" # Expected ArgumentError but no exception was raised (#<DateTime:0x8ef6 @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN, @start=2299161> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid second values" # Expected ArgumentError but no exception was raised (#<DateTime:0x876a @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN, @start=2299161> was returned)
  fails "DateTime.parse parses DD as month day number" # Expected #<DateTime:0x8146 @date=2001-10-01 00:00:00 +0200, @start=2299161> == #<DateTime:0x814e @date=2022-12-10 00:00:00 UTC, @start=2299161> to be truthy but was false
  fails "DateTime.parse parses DDD as year day number" # Expected #<DateTime:0x799e @date=100-01-01 00:00:00 +0124, @start=2299161> == #<DateTime:0x79a6 @date=2022-04-10 00:00:00 UTC, @start=2299161> to be truthy but was false
  fails "DateTime.parse parses MMDD as month and day" # Expected #<DateTime:0x7cb8 @date=1108-01-01 01:24:00 +0124, @start=2299161> == #<DateTime:0x7cbe @date=2022-11-08 00:00:00 UTC, @start=2299161> to be truthy but was false
  fails "DateTime.parse parses YYDDD as year and day number in 1969--2068" # Expected #<DateTime:0x7684 @date=10100-01-01 00:00:00 +0100, @start=2299161> == #<DateTime:0x7688 @date=2010-04-10 00:00:00 UTC, @start=2299161> to be truthy but was false
  fails "DateTime.parse parses YYMMDD as year, month and day in 1969--2068" # Expected #<DateTime:0x8456 @date=201023-01-01 00:00:00 +0100, @start=2299161> == #<DateTime:0x845a @date=2020-10-23 00:00:00 UTC, @start=2299161> to be truthy but was false
  fails "DateTime.parse parses a day name into a DateTime object" # NoMethodError: undefined method `cwyear' for #<DateTime:0x767c @start=2299161 @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN>
  fails "DateTime.parse throws an argument error for a single digit" # Expected ArgumentError but no exception was raised (#<DateTime:0x7fc8 @date=2001-01-01 00:00:00 +0100, @start=2299161> was returned)
  fails "DateTime.parse(.) parses DD.MM.YYYY into a DateTime object" # Expected 10 == 1 to be truthy but was false
  fails "DateTime.parse(.) parses YY.MM.DD into a DateTime object using the year 20YY" # Expected 2007 == 2010 to be truthy but was false
  fails "DateTime.parse(.) parses YY.MM.DD using the year digits as 20YY when given true as additional argument" # ArgumentError: [DateTime.parse] wrong number of arguments (given 2, expected 1)
  fails "DateTime.sec adds 60 to negative values" # ArgumentError: sec out of range: -20
  fails "DateTime.sec raises an error when minute is given as a rational" # Expected ArgumentError but no exception was raised (#<DateTime:0x3e5a @date=-4712-01-01 00:05:00 UTC, @start=2299161> was returned)
  fails "DateTime.sec raises an error, when the second is greater or equal than 60" # Expected ArgumentError but no exception was raised (#<DateTime:0x3cbe @date=-4712-01-01 00:01:00 UTC, @start=2299161> was returned)
end
