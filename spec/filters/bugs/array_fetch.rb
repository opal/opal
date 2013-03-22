opal_filter "Array#fetch" do
  fails "Array#fetch gives precedence to the default block over the default argument"
end
