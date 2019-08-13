# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "File" do
  fails "File.join doesn't mutate the object when calling #to_str"
end
