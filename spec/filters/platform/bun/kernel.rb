# NOTE: run bin/format-filters after changing this file
opal_filter "Kernel" do
  fails "Kernel#caller includes core library methods defined in Ruby"
  fails "Kernel#object_id returns the same value for two Symbol literals"
end
