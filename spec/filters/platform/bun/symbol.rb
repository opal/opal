# NOTE: run bin/format-filters after changing this file
opal_filter "Symbol" do
  fails "BasicObject#__id__ returns the same value for two Symbol literals" #
end
