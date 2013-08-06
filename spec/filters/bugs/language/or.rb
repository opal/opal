opal_filter "or" do
  fails "The or operator has a lower precedence than 'next' in 'next true or false'"
end
