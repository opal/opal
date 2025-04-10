# NOTE: run bin/format-filters after changing this file
opal_filter "File" do
  fails "IO#syswrite on a file does not modify the passed argument" # Expected [198, 32, 25] == [198, 146] to be truthy but was false
  fails "IO#write on a file writes binary data if no encoding is given and multiple arguments passed" # Expected [32, 33, 196, 32, 38] == [135, 196, 133] to be truthy but was false
end
