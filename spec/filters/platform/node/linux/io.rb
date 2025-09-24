# NOTE: run bin/format-filters after changing this file
opal_filter "IO" do
  fails "IO#ioctl raises IOError on closed stream" # Expected IOError but got: NotImplementedError (NotImplementedError)
end
