# NOTE: run bin/format-filters after changing this file
opal_filter "Float" do
  fails "Float#fdiv performs floating-point division between self and an Integer" # Expected 8.900000000008007e-117 == 8.900000000008011e-117 to be truthy but was false
  fails "Float#quo performs floating-point division between self and an Integer" # Expected 8.900000000008007e-117 == 8.900000000008011e-117 to be truthy but was false
end
