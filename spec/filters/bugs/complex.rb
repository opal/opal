# NOTE: run bin/format-filters after changing this file
opal_filter "Complex" do
  fails "Complex#coerce returns an array containing other as Complex and self when other is a Numeric which responds to #real? with true"
end
