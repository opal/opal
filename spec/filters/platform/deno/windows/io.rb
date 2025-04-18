# NOTE: run bin/format-filters after changing this file
opal_filter "IO" do
  fails "IO#stat returns a File::Stat object for the stream" # Errno::EISDIR: Is a directory - Incorrect function. (os error 1)
end
