# NOTE: run bin/format-filters after changing this file
opal_filter "IO" do
  fails "IO.popen raises IOError when writing a read-only pipe" # Expected  "foo\r " ==  "foo " to be truthy but was false
  fails "IO.popen reads a read-only pipe" # Expected  "foo\r " ==  "foo " to be truthy but was false
  fails "IO.popen with a leading ENV Hash accepts a single String command" # Expected  "bar\r " ==  "bar " to be truthy but was false
  fails "IO.popen with a leading ENV Hash accepts a single String command, and an IO mode" # Expected  "bar\r " ==  "bar " to be truthy but was false
end
