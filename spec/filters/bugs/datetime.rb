# NOTE: run bin/format-filters after changing this file
opal_filter "DateTime" do
  fails "DateTime#+ is able to add sub-millisecond precision values" # Expected 0 == 864864 to be truthy but was false
  fails "DateTime#- correctly calculates sub-millisecond time differences" # Expected 5097600 == 59.000001 to be truthy but was false
  fails "DateTime#- is able to subtract sub-millisecond precision values" # Expected 0 == (13717421/9600000000) to be truthy but was false
  fails "DateTime#hour raises an error for Rational" # Expected ArgumentError but no exception was raised (#<DateTime:0xa6cca @date=-4712-01-01 00:00:00 UTC, @start=2299161> was returned)
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
  fails "DateTime.new takes the seventh argument as an offset" # Expected 1.3503086419753086e-7 == 0.7 to be truthy but was false
  fails "DateTime.now grabs the local timezone" # Expected "+01:00" == "-08:00" to be truthy but was false
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format parses YYYY-MM-DDTHH:MM:SS into a DateTime object" # Expected #<DateTime:0x8a68 @date=2012-11-08 15:43:59 +0100, @start=2299161> == #<DateTime:0x8a6c @date=2012-11-08 15:43:59 UTC, @start=2299161> to be truthy but was false
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid day values" # Expected ArgumentError but no exception was raised (#<DateTime:0x8d76 @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN, @start=2299161> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid hour values" # Expected ArgumentError but no exception was raised (#<DateTime:0x88ea @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN, @start=2299161> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid minute values" # Expected ArgumentError but no exception was raised (#<DateTime:0x9076 @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN, @start=2299161> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid month values" # Expected ArgumentError but no exception was raised (#<DateTime:0x8ef6 @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN, @start=2299161> was returned)
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format throws an argument error for invalid second values" # Expected ArgumentError but no exception was raised (#<DateTime:0x876a @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN, @start=2299161> was returned)
  fails "DateTime.parse parses a day name into a DateTime object" # NoMethodError: undefined method `cwyear' for #<DateTime:0x767c @start=2299161 @date=NaN-NaN-NaN NaN:NaN:NaN -NaNNaN>
end
