# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Proc" do
  fails "Proc#hash returns an Integer"
end
