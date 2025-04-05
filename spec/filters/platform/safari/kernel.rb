# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Kernel" do
  fails "Kernel#caller includes core library methods defined in Ruby"
end
