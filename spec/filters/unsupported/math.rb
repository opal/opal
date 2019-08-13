# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Math" do
  fails "Math#atanh is a private instance method"
end
