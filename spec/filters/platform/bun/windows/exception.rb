# NOTE: run bin/format-filters after changing this file
opal_filter "Exception" do
  fails "Exception#set_backtrace allows the user to set the backtrace from a rescued exception" # Errno::EACCES: Permission denied
end
