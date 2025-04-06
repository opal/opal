# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#raise raises RuntimeError if no exception class is given" # Expected RuntimeError () but got: NotImplementedError (File.lstat is not available on this platform)
  fails "Kernel#warn does not append line-end if last character is line-end" # Expected:   $stderr:  "this is some simple text with line-end "       got:   $stderr:  "this is some simple text with line-end  "
end
