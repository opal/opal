# NOTE: run bin/format-filters after changing this file
opal_filter "Time" do
  fails "Time.at passed [Time, Numeric, format] not supported format does not try to convert format to Symbol with #to_sym" # Exception: Cannot create property '$$meta' on string 'usec'
end
