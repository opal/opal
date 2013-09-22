opal_filter "Float" do
  fails "Array#inspect represents a recursive element with '[...]'"
  fails "Array#to_s represents a recursive element with '[...]'"
end
