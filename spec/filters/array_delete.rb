opal_filter "Array#delete accepting blocks" do
  fails "Array#delete may be given a block that is executed if no element matches object"
end
