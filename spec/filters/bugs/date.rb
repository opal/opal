# NOTE: run bin/format-filters after changing this file
opal_filter "Date" do
  fails "Date#>> returns the day of the reform if date falls within calendar reform"
  fails "Date#ajd determines the Astronomical Julian day"
  fails "Date#amjd determines the Astronomical Modified Julian day"
  fails "Date#civil creates a Date for different calendar reform dates"
  fails "Date#civil doesn't create dates for invalid arguments"
  fails "Date#commercial creates a Date for Julian Day Number day 0 by default"
  fails "Date#commercial creates a Date for the correct day given the year, week and day number" # NoMethodError: undefined method `commercial' for Date
  fails "Date#commercial creates a Date for the monday in the year and week given" # NoMethodError: undefined method `commercial' for Date
  fails "Date#commercial creates only Date objects for valid weeks"
  fails "Date#cwyear determines the commercial year"
  fails "Date#day_fraction determines the day fraction"
  fails "Date#england converts a date object into another with the English calendar reform"
  fails "Date#gregorian converts a date object into another with the Gregorian calendar"
  fails "Date#gregorian? marks a day after the calendar reform as Julian"
  fails "Date#gregorian? marks a day before the calendar reform as Julian"
  fails "Date#hash returns the same value for equal dates"
  fails "Date#italy converts a date object into another with the Italian calendar reform"
  fails "Date#julian converts a date object into another with the Julian calendar"
  fails "Date#julian? marks a day before the calendar reform as Julian"
  fails "Date#ld determines the Modified Julian day"
  fails "Date#mjd determines the Modified Julian day"
  fails "Date#new_start converts a date object into another with a new calendar reform"
  fails "Date#parse coerces using to_str" # ArgumentError: invalid date
  fails "Date#parse parses a day name into a Date object"
  fails "Date#parse parses a month day into a Date object"
  fails "Date#parse parses a month name into a Date object"
  fails "Date#parse raises a TypeError trying to parse non-String-like object" # ArgumentError: invalid date
  fails "Date#strftime should be able to print the commercial year with leading zeroes"
  fails "Date#strftime should be able to print the commercial year with only two digits"
  fails "Date#strftime should be able to show a full notation"
  fails "Date#strftime should be able to show the commercial week day"
  fails "Date#strftime should be able to show the number of seconds since the unix epoch for a date" # Expected "954964800" to equal "954979200"
  fails "Date#strftime should be able to show the timezone of the date with a : separator"
  fails "Date#strftime should be able to show the timezone with a : separator"
  fails "Date#strftime should be able to show the week number with the week starting on Sunday (%U) and Monday (%W)"
  fails "Date#strftime shows the number of milliseconds since epoch"
  fails "Date#strptime parses a century"
  fails "Date#strptime parses a commercial week day"
  fails "Date#strptime parses a commercial week"
  fails "Date#strptime parses a commercial year with leading zeroes"
  fails "Date#strptime parses a commercial year with only two digits"
  fails "Date#strptime parses a date given MM/DD/YY"
  fails "Date#strptime parses a date given as YYYY-MM-DD"
  fails "Date#strptime parses a date given in full notation"
  fails "Date#strptime parses a date with slashes"
  fails "Date#strptime parses a full date"
  fails "Date#strptime parses a full day name"
  fails "Date#strptime parses a full month name"
  fails "Date#strptime parses a month day with leading spaces"
  fails "Date#strptime parses a month day with leading zeroes"
  fails "Date#strptime parses a month with leading zeroes"
  fails "Date#strptime parses a short day name"
  fails "Date#strptime parses a short month name"
  fails "Date#strptime parses a week day"
  fails "Date#strptime parses a week number for a week starting on Monday"
  fails "Date#strptime parses a week number for a week starting on Sunday"
  fails "Date#strptime parses a year day with leading zeroes"
  fails "Date#strptime parses a year in YY format"
  fails "Date#strptime parses a year in YYYY format"
  fails "Date#strptime returns January 1, 4713 BCE when given no arguments"
  fails "Date#strptime uses the default format when not given a date format"
  fails "Date#valid_civil? handles negative months and days"
  fails "Date#valid_civil? returns false if it is not a valid civil date"
  fails "Date#valid_civil? returns true if it is a valid civil date"
  fails "Date#valid_commercial? handles negative week and day numbers"
  fails "Date#valid_commercial? returns false it is not a valid commercial date"
  fails "Date#valid_commercial? returns true if it is a valid commercial date"
  fails "Date#valid_date? handles negative months and days"
  fails "Date#valid_date? returns false if it is not a valid civil date"
  fails "Date#valid_date? returns true if it is a valid civil date"
  fails "Date._iso8601 returns an empty hash if the argument is a invalid Date" # NoMethodError: undefined method `_iso8601' for Date
  fails "Date._rfc3339 returns an empty hash if the argument is a invalid Date" # NoMethodError: undefined method `_rfc3339' for Date
  fails "Date.iso8601 parses YYYY-MM-DD into a Date object" # NoMethodError: undefined method `iso8601' for Date
  fails "Date.iso8601 parses YYYYMMDD into a Date object" # NoMethodError: undefined method `iso8601' for Date
  fails "Date.iso8601 parses a StringSubclass into a Date object" # NoMethodError: undefined method `iso8601' for Date
  fails "Date.iso8601 parses a Symbol into a Date object" # NoMethodError: undefined method `iso8601' for Date
  fails "Date.iso8601 parses a negative Date" # NoMethodError: undefined method `iso8601' for Date
  fails "Date.iso8601 raises a TypeError when passed an Object" # NoMethodError: undefined method `iso8601' for Date
  fails "Date.iso8601 raises an ArgumentError when passed a Symbol without a valid Date" # NoMethodError: undefined method `iso8601' for Date
  fails "Date.jd constructs a Date object if passed a Julian day"
  fails "Date.jd constructs a Date object if passed a negative number"
  fails "Date.jd returns a Date object representing Julian day 0 (-4712-01-01) if no arguments passed"
  fails "Date.julian_leap? determines whether a year is a leap year in the Julian calendar"
  fails "Date.julian_leap? determines whether a year is not a leap year in the Julian calendar"
  fails "Date.new creates a Date for different calendar reform dates"
  fails "Date.new doesn't create dates for invalid arguments"
  fails "Date.ordinal constructs a Date object from an ordinal date"
  fails "Date.valid_jd? returns false if passed false" # NoMethodError: undefined method `valid_jd?' for Date
  fails "Date.valid_jd? returns false if passed nil"
  fails "Date.valid_jd? returns false if passed symbol" # NoMethodError: undefined method `valid_jd?' for Date
  fails "Date.valid_jd? returns true if passed a number value" # NoMethodError: undefined method `valid_jd?' for Date
  fails "Date.valid_ordinal? determines if the date is a valid ordinal date"
  fails "Date.valid_ordinal? handles negative day numbers"
end
