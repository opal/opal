# NOTE: run bin/format-filters after changing this file
opal_filter "Time" do
  fails "Time#gmtime converts self to UTC, modifying the receiver" # Expected 2007-01-09 05:00:00 UTC == 2007-01-09 12:00:00 UTC to be truthy but was false
  fails "Time#strftime should be able to show the number of seconds since the unix epoch" # Expected "1104534000"  == "1104537600"  to be truthy but was false
  fails "Time#utc converts self to UTC, modifying the receiver" # Expected 2007-01-09 05:00:00 UTC == 2007-01-09 12:00:00 UTC to be truthy but was false
  fails "Time#zone defaults to UTC when bad zones given" # Expected 7200 == 0 to be truthy but was false
  fails "Time.new uses the local timezone" # Expected 7200 == -28800 to be truthy but was false
  fails "Time.now uses the local timezone" # Expected 7200 == -28800 to be truthy but was false
end
