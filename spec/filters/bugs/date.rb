# NOTE: run bin/format-filters after changing this file
opal_filter "Date" do
  fails "Date constants defines MONTHNAMES" # Expected [nil,  "January",  "February",  "March",  "April",  "May",  "June",  "July",  "August",  "September",  "October",  "November",  "December",  "Unknown"] == [nil,  "January",  "February",  "March",  "April",  "May",  "June",  "July",  "August",  "September",  "October",  "November",  "December"] to be truthy but was false
  fails "Date constants freezes MONTHNAMES, DAYNAMES, ABBR_MONTHNAMES, ABBR_DAYSNAMES" # Expected FrozenError (/frozen/) but no exception was raised ([nil,  "January",  "February",  "March",  "April",  "May",  "June",  "July",  "August",  "September",  "October",  "November",  "December",  "Unknown"] was returned)
  fails "Date#>> returns the day of the reform if date falls within calendar reform" # Expected #<Date:0x28ea @date=1582-10-09 00:00:00 +0124, @start=2299161> == #<Date:0x28e6 @date=1582-10-04 00:00:00 +0124, @start=2299161> to be truthy but was false
  fails "Date#ajd determines the Astronomical Julian day" # NoMethodError: undefined method `ajd' for #<Date:0x9f5b0 @date=2007-01-17 00:00:00 +0100 @start=2299161>
  fails "Date#amjd determines the Astronomical Modified Julian day" # NoMethodError: undefined method `amjd' for #<Date:0x9f5ba @date=2007-01-17 00:00:00 +0100 @start=2299161>
  fails "Date#commercial creates a Date for Julian Day Number day 0 by default" # NoMethodError: undefined method `commercial' for Date
  fails "Date#commercial creates a Date for the correct day given the year, week and day number" # NoMethodError: undefined method `commercial' for Date
  fails "Date#commercial creates a Date for the monday in the year and week given" # NoMethodError: undefined method `commercial' for Date
  fails "Date#commercial creates only Date objects for valid weeks" # Expected ArgumentError but got: NoMethodError (undefined method `commercial' for Date)
  fails "Date#cwyear determines the commercial year" # NoMethodError: undefined method `cwyear' for #<Date:0x9f61a @date=2007-01-17 00:00:00 +0100 @start=2299161>
  fails "Date#day_fraction determines the day fraction" # NoMethodError: undefined method `day_fraction' for #<Date:0x9f5c4 @date=2007-01-17 00:00:00 +0100 @start=2299161>
  fails "Date#england converts a date object into another with the English calendar reform" # NoMethodError: undefined method `england' for #<Date:0x74ac6 @date=1582-10-15 00:00:00 +0124 @start=2299161>
  fails "Date#gregorian converts a date object into another with the Gregorian calendar" # NoMethodError: undefined method `gregorian' for #<Date:0x74ada @date=1582-10-04 00:00:00 +0124 @start=2299161>
  fails "Date#gregorian? marks a day after the calendar reform as Julian" # NoMethodError: undefined method `gregorian?' for #<Date:0x54cc @date=2007-02-27 00:00:00 +0100 @start=2299161>
  fails "Date#gregorian? marks a day before the calendar reform as Julian" # NoMethodError: undefined method `gregorian?' for #<Date:0x54d4 @date=1007-02-27 00:00:00 +0124 @start=2299161>
  fails "Date#hash returns the same value for equal dates" # Expected 624408 == 624412 to be truthy but was false
  fails "Date#italy converts a date object into another with the Italian calendar reform" # NoMethodError: undefined method `italy' for #<Date:0x74abc @date=1582-10-04 00:00:00 +0124 @start=2361222>
  fails "Date#julian converts a date object into another with the Julian calendar" # NoMethodError: undefined method `julian' for #<Date:0x74ad0 @date=1582-10-15 00:00:00 +0124 @start=2299161>
  fails "Date#julian? marks a day before the calendar reform as Julian" # Expected false to be true
  fails "Date#ld determines the Modified Julian day" # NoMethodError: undefined method `ld' for #<Date:0x9f5d8 @date=2007-01-17 00:00:00 +0100 @start=2299161>
  fails "Date#mjd determines the Modified Julian day" # NoMethodError: undefined method `mjd' for #<Date:0x9f5ce @date=2007-01-17 00:00:00 +0100 @start=2299161>
  fails "Date#new_start converts a date object into another with a new calendar reform" # ArgumentError: [Date#new_start] wrong number of arguments (given 0, expected 1)
  fails "Date#parse coerces using to_str" # ArgumentError: invalid date
  fails "Date#parse parses a day name into a Date object" # NoMethodError: undefined method `cwyear' for #<Date:0x9fddc @start=2299161 @date=2022-12-09 00:00:00 +0100>
  fails "Date#parse parses a month day into a Date object" # ArgumentError: invalid date
  fails "Date#parse parses a month name into a Date object" # ArgumentError: invalid date
  fails "Date#parse raises a TypeError trying to parse non-String-like object" # Expected TypeError but got: ArgumentError (invalid date)
  fails "Date#strftime should be able to print the commercial year with leading zeroes" # Expected "200" == "0200" to be truthy but was false
  fails "Date#strftime should be able to print the commercial year with only two digits" # TypeError: no implicit conversion of Range into Integer
  fails "Date#strftime should be able to show a full notation" # Expected "%+" == "Sun Apr  9 00:00:00 +00:00 2000" to be truthy but was false
  fails "Date#strftime should be able to show the commercial week day" # Expected "1" == "7" to be truthy but was false
  fails "Date#strftime should be able to show the commercial week" # Expected " 9-APR-2000" == " 9-Apr-2000" to be truthy but was false
  fails "Date#strftime should be able to show the timezone of the date with a : separator" # Expected "+0200" == "+0000" to be truthy but was false
  fails "Date#strftime should be able to show the timezone with a : separator" # Expected "Central European Summer Time" == "+00:00" to be truthy but was false
  fails "Date#strftime should be able to show the week number with the week starting on Sunday (%U) and Monday (%W)" # Expected "%U" == "14" to be truthy but was false
  fails "Date#strftime shows the number of milliseconds since epoch" # Expected "%Q" == "0" to be truthy but was false
  fails "Date#strptime parses a century" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a commercial week day" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a commercial week" # NoMethodError: undefined method `cwyear' for #<Date:0x6b2 @start=2299161 @date=2022-12-07 05:15:38 +0100>
  fails "Date#strptime parses a commercial year with leading zeroes" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a commercial year with only two digits" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a date given MM/DD/YY" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a date given as YYYY-MM-DD" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a date given in full notation" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a date with slashes" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a full date" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a full day name" # NoMethodError: undefined method `cwyear' for #<Date:0x6e6 @start=2299161 @date=2022-12-07 05:15:38 +0100>
  fails "Date#strptime parses a full month name" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a month day with leading spaces" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a month day with leading zeroes" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a month with leading zeroes" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a short day name" # NoMethodError: undefined method `cwyear' for #<Date:0x6b8 @start=2299161 @date=2022-12-07 05:15:38 +0100>
  fails "Date#strptime parses a short month name" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a week day" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a week number for a week starting on Monday" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a week number for a week starting on Sunday" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a year day with leading zeroes" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a year in YY format" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime parses a year in YYYY format" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime returns January 1, 4713 BCE when given no arguments" # NoMethodError: undefined method `strptime' for Date
  fails "Date#strptime uses the default format when not given a date format" # NoMethodError: undefined method `strptime' for Date
  fails "Date#valid_civil? handles negative months and days" # NoMethodError: undefined method `valid_civil?' for Date
  fails "Date#valid_civil? returns false if it is not a valid civil date" # NoMethodError: undefined method `valid_civil?' for Date
  fails "Date#valid_civil? returns true if it is a valid civil date" # NoMethodError: undefined method `valid_civil?' for Date
  fails "Date#valid_commercial? handles negative week and day numbers" # NoMethodError: undefined method `valid_commercial?' for Date
  fails "Date#valid_commercial? returns false it is not a valid commercial date" # NoMethodError: undefined method `valid_commercial?' for Date
  fails "Date#valid_commercial? returns true if it is a valid commercial date" # NoMethodError: undefined method `valid_commercial?' for Date
  fails "Date#valid_date? handles negative months and days" # NoMethodError: undefined method `valid_date?' for Date
  fails "Date#valid_date? returns false if it is not a valid civil date" # NoMethodError: undefined method `valid_date?' for Date
  fails "Date#valid_date? returns true if it is a valid civil date" # NoMethodError: undefined method `valid_date?' for Date
  fails "Date._iso8601 returns an empty hash if the argument is a invalid Date" # NoMethodError: undefined method `_iso8601' for Date
  fails "Date._rfc3339 returns an empty hash if the argument is a invalid Date" # NoMethodError: undefined method `_rfc3339' for Date
  fails "Date.civil creates a Date for different calendar reform dates" # Expected 5 == 15 to be truthy but was false
  fails "Date.civil doesn't create dates for invalid arguments" # Expected ArgumentError but no exception was raised (#<Date:0x9c330 @date=2001-01-31 00:00:00 +0100, @start=2299161> was returned)
  fails "Date.iso8601 parses YYYY-MM-DD into a Date object" # NoMethodError: undefined method `iso8601' for Date
  fails "Date.iso8601 parses YYYYMMDD into a Date object" # NoMethodError: undefined method `iso8601' for Date
  fails "Date.iso8601 parses a StringSubclass into a Date object" # NoMethodError: undefined method `iso8601' for Date
  fails "Date.iso8601 parses a negative Date" # NoMethodError: undefined method `iso8601' for Date
  fails "Date.iso8601 raises a TypeError when passed an Object" # Expected TypeError but got: NoMethodError (undefined method `iso8601' for Date)
  fails "Date.jd constructs a Date object if passed a Julian day" # NoMethodError: undefined method `jd' for Date
  fails "Date.jd constructs a Date object if passed a negative number" # NoMethodError: undefined method `jd' for Date
  fails "Date.jd returns a Date object representing Julian day 0 (-4712-01-01) if no arguments passed" # NoMethodError: undefined method `jd' for Date
  fails "Date.julian_leap? determines whether a year is a leap year in the Julian calendar" # NoMethodError: undefined method `julian_leap?' for Date
  fails "Date.julian_leap? determines whether a year is not a leap year in the Julian calendar" # NoMethodError: undefined method `julian_leap?' for Date
  fails "Date.new creates a Date for different calendar reform dates" # Expected 5 == 15 to be truthy but was false
  fails "Date.new doesn't create dates for invalid arguments" # Expected ArgumentError but no exception was raised (#<Date:0x48b08 @date=2001-01-31 00:00:00 +0100, @start=2299161> was returned)
  fails "Date.ordinal constructs a Date object from an ordinal date" # NoMethodError: undefined method `ordinal' for Date
  fails "Date.valid_jd? returns false if passed false" # NoMethodError: undefined method `valid_jd?' for Date
  fails "Date.valid_jd? returns false if passed nil" # NoMethodError: undefined method `valid_jd?' for Date
  fails "Date.valid_jd? returns false if passed symbol" # NoMethodError: undefined method `valid_jd?' for Date
  fails "Date.valid_jd? returns true if passed a number value" # NoMethodError: undefined method `valid_jd?' for Date
  fails "Date.valid_ordinal? determines if the date is a valid ordinal date" # NoMethodError: undefined method `valid_ordinal?' for Date
  fails "Date.valid_ordinal? handles negative day numbers" # NoMethodError: undefined method `valid_ordinal?' for Date
end
