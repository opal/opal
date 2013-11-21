opal_filter "Time" do
  fails "Time.mktime respects rare old timezones"
  fails "Time.mktime creates a time based on given values, interpreted in the local time zone"
  fails "Time.mktime creates the correct time just before dst change"
  fails "Time.mktime creates the correct time just after dst change"
  fails "Time.mktime handles fractional seconds as a Rational"
  fails "Time.mktime handles fractional seconds as a Float"
  fails "Time.mktime creates a time based on given C-style gmtime arguments, interpreted in the local time zone"
  fails "Time.mktime coerces the month with #to_str"
  fails "Time.mktime handles a String day"
  fails "Time.mktime interprets all numerals as base 10"
  fails "Time.mktime handles a String month given as a short month name"
  fails "Time.mktime returns subclass instances"

  fails "Time#day returns the day of the month for a Time with a fixed offset"
  fails "Time#day returns the day of the month (1..n) for a local Time"

  fails "Time#hour returns the hour of the day (0..23) for a local Time"
  fails "Time#hour returns the hour of the day for a Time with a fixed offset"

  fails "Time#month returns the four digit year for a Time with a fixed offset"
  fails "Time#month returns the month of the year for a local Time"

  fails "Time#min returns the minute of the hour for a Time with a fixed offset"
  fails "Time#min returns the minute of the hour (0..59) for a local Time"

  fails "Time#strftime supports week of year format with %U and %W"
end
