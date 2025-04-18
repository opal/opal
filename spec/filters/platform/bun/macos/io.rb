# NOTE: run bin/format-filters after changing this file
opal_filter "IO" do
  fails "IO.binwrite accepts a :mode option" # Expected "hello, world!34567890123456789" == "012345678901234567890123456789hello, world!" to be truthy but was false
  fails "IO.write accepts a :mode option" # Expected "hello, world!34567890123456789" == "012345678901234567890123456789hello, world!" to be truthy but was false
end
