# NOTE: run bin/format-filters after changing this file
opal_filter "Time" do
  fails "Time#gmt_offset returns the correct offset for Hawaii around daylight savings time change" # Expected -21600 == -36000 to be truthy but was false
  fails "Time#gmt_offset returns the correct offset for New Zealand around daylight savings time change" # Expected -21600 == 46800 to be truthy but was false
  fails "Time#gmt_offset returns the correct offset for US Eastern time zone around daylight savings time change" # Expected -21600 == -18000 to be truthy but was false
  fails "Time#gmtoff returns the correct offset for Hawaii around daylight savings time change" # Expected -21600 == -36000 to be truthy but was false
  fails "Time#gmtoff returns the correct offset for New Zealand around daylight savings time change" # Expected -21600 == 46800 to be truthy but was false
  fails "Time#gmtoff returns the correct offset for US Eastern time zone around daylight savings time change" # Expected -21600 == -18000 to be truthy but was false
  fails "Time#strftime should be able to show the number of seconds since the unix epoch" # Expected "1104559200" == "1104537600" to be truthy but was false
  fails "Time#utc_offset returns the correct offset for Hawaii around daylight savings time change" # Expected -21600 == -36000 to be truthy but was false
  fails "Time#utc_offset returns the correct offset for New Zealand around daylight savings time change" # Expected -21600 == 46800 to be truthy but was false
  fails "Time#utc_offset returns the correct offset for US Eastern time zone around daylight savings time change" # Expected -21600 == -18000 to be truthy but was false
  fails "Time#wday returns an integer representing the day of the week, 0..6, with Sunday being 0" # Expected 3 == 4 to be truthy but was false
  fails "Time#zone defaults to UTC when bad zones given" # Expected -21600 == 0 to be truthy but was false
  fails "Time.local creates the correct time just before dst change" # Expected -21600 == -14400 to be truthy but was false
  fails "Time.mktime creates the correct time just before dst change" # Expected -21600 == -14400 to be truthy but was false
  fails "Time.new uses the local timezone" # Expected -21600 == -28800 to be truthy but was false
  fails "Time.now uses the local timezone" # Expected -21600 == -28800 to be truthy but was false
end
