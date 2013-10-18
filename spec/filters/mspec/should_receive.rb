opal_filter "should_receive" do
  fails "Array#at tries to convert the passed argument to an Integer using #to_int"
end
