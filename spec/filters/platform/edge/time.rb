# NOTE: run bin/format-filters after changing this file
opal_filter "Time" do
  fails "Time#getgm returns a new time which is the utc representation of time" # Expected 2007-01-09 05:00:00 UTC == 2007-01-09 12:00:00 UTC to be truthy but was false
  fails "Time#getutc returns a new time which is the utc representation of time" # Expected 2007-01-09 05:00:00 UTC == 2007-01-09 12:00:00 UTC to be truthy but was false
  fails "Time#gmt_offset returns the correct offset for Hawaii around daylight savings time change" # Expected 3600 == -36000 to be truthy but was false
  fails "Time#gmt_offset returns the correct offset for New Zealand around daylight savings time change" # Expected 7200 == 46800 to be truthy but was false
  fails "Time#gmt_offset returns the correct offset for US Eastern time zone around daylight savings time change" # Expected 3600 == -18000 to be truthy but was false
  fails "Time#gmtime converts self to UTC, modifying the receiver" # Expected 2007-01-09 05:00:00 UTC == 2007-01-09 12:00:00 UTC to be truthy but was false
  fails "Time#gmtoff returns the correct offset for Hawaii around daylight savings time change" # Expected 3600 == -36000 to be truthy but was false
  fails "Time#gmtoff returns the correct offset for New Zealand around daylight savings time change" # Expected 7200 == 46800 to be truthy but was false
  fails "Time#gmtoff returns the correct offset for US Eastern time zone around daylight savings time change" # Expected 3600 == -18000 to be truthy but was false
  fails "Time#strftime should be able to show the number of seconds since the unix epoch" # Expected "1104534000"  == "1104537600"  to be truthy but was false
  fails "Time#utc converts self to UTC, modifying the receiver" # Expected 2007-01-09 05:00:00 UTC == 2007-01-09 12:00:00 UTC to be truthy but was false
  fails "Time#utc_offset returns the correct offset for Hawaii around daylight savings time change" # Expected 3600 == -36000 to be truthy but was false
  fails "Time#utc_offset returns the correct offset for New Zealand around daylight savings time change" # Expected 7200 == 46800 to be truthy but was false
  fails "Time#utc_offset returns the correct offset for US Eastern time zone around daylight savings time change" # Expected 3600 == -18000 to be truthy but was false
  fails "Time#zone defaults to UTC when bad zones given" # Expected 7200 == 0 to be truthy but was false
  fails "Time.local creates the correct time just before dst change" # Expected 7200 == -14400 to be truthy but was false
  fails "Time.mktime creates the correct time just before dst change" # Expected 7200 == -14400 to be truthy but was false
  fails "Time.new uses the local timezone" # Expected 7200 == -28800 to be truthy but was false
  fails "Time.now uses the local timezone" # Expected 7200 == -28800 to be truthy but was false
end
