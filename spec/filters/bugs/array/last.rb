opal_filter "Array#last" do
  fails "Array#last tries to convert the passed argument to an Integer usinig #to_int"
end
