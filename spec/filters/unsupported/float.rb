opal_filter "Float" do
  fails "Array#inspect represents a recursive element with '[...]'"
  fails "Array#to_s represents a recursive element with '[...]'"
  fails "Array#eql? returns false if any corresponding elements are not #eql?"
end
