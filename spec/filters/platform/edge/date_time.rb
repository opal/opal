# NOTE: run bin/format-filters after changing this file
opal_filter "DateTime" do
  fails "DateTime#to_date maintains the same julian day regardless of local time or zone" # Expected 2456286 == 2456285 to be truthy but was false
  fails "DateTime.now grabs the local timezone" # Expected "+02:00" == "-08:00" to be truthy but was false
  fails "DateTime.parse YYYY-MM-DDTHH:MM:SS format parses YYYY-MM-DDTHH:MM:SS into a DateTime object" # Expected #<DateTime:0xba2aa @date=2012-11-08 15:43:59 +0100, @start=2299161> == #<DateTime:0xba2ae @date=2012-11-08 15:43:59 UTC, @start=2299161> to be truthy but was false
end
