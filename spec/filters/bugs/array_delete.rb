opal_filter "Array#delete accepting blocks" do
  fails "Array#delete may be given a block that is executed if no element matches object"
  fails "Array#delete returns the last element in the array for which object is equal under #=="
end
