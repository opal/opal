opal_filter "Date" do
  fails "Date#<< raises an error on non numeric parameters"

  fails "Date#strftime should be able to print the commercial year with leading zeroes"
  fails "Date#strftime should be able to print the commercial year with only two digits"
  fails "Date#strftime should be able to print the year day with leading zeroes"
  fails "Date#strftime should be able to show a full notation"
  fails "Date#strftime should be able to show the commercial week"
  fails "Date#strftime should be able to show the timezone of the date with a : separator"
  fails "Date#strftime should be able to show the timezone of the date with a : separator"
  fails "Date#strftime should be able to show the commercial week"
  fails "Date#strftime should be able to show the commercial week day"
  fails "Date#strftime should be able to show the week number with the week starting on sunday and monday"
  fails "Date#strftime should be able to show the number of seconds since the unix epoch"
end
