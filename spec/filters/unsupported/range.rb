# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Range" do
  fails "Range#initialize is private" # Expected Range to have private instance method 'initialize' but it does not
end
