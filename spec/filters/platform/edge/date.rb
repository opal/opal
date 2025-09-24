# NOTE: run bin/format-filters after changing this file
opal_filter "Date" do
  fails "Date#strftime should be able to show the number of seconds since the unix epoch for a date" # Expected "954972000"  == "954979200"  to be truthy but was false
end
