# NOTE: run bin/format-filters after changing this file
opal_filter "Date" do
  fails "DateTime.now grabs the local timezone" # Expected "-06:00" == "-08:00" to be truthy but was false
end
