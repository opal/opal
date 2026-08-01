# NOTE: run bin/format-filters after changing this file
opal_filter "IO" do
  fails "IO#ioctl raises IOError on closed stream" # Expected IOError but got: NotImplementedError (NotImplementedError)
  fails "IO#syswrite on a file does not modify the passed argument" # Expected [198, 32, 25] == [198, 146] to be truthy but was false
end
