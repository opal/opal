opal_filter "Time" do
  fails "Time.mktime handles microseconds"
  fails "Time.mktime handles fractional microseconds as a Float"
  fails "Time.mktime handles fractional microseconds as a Rational"
  fails "Time.mktime ignores fractional seconds if a passed whole number of microseconds"
  fails "Time.mktime ignores fractional seconds if a passed fractional number of microseconds"
end
