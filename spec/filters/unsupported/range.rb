opal_unsupported_filter "Range" do
  fails "Range#initialize is private"
  fails "Range#inspect returns a tainted string if either end is tainted"
  fails "Range#inspect returns a untrusted string if either end is untrusted"
  fails "Range#to_s returns a tainted string if either end is tainted"
  fails "Range#to_s returns a untrusted string if either end is untrusted"
end
