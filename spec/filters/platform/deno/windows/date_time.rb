# NOTE: run bin/format-filters after changing this file
opal_filter "DateTime" do
  fails "DateTime#to_date maintains the same julian day regardless of local time or zone" # Expected 2456286 == 2456285 to be truthy but was false
  fails "DateTime.now grabs the local timezone" # Expected "-07:00" == "-08:00" to be truthy but was false
end
