opal_filter "Float" do
  fails "Float#to_s emits '-' for -0.0"
  fails "Float#to_s emits a trailing '.0' for a whole number"
  fails "Float#to_s emits a trailing '.0' for the mantissa in e format"
  fails "Float#to_s returns '0.0' for 0.0"
end
