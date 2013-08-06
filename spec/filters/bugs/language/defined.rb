opal_filter "defined?" do
  fails "The defined? keyword when called with a method name having a module as a receiver returns nil if the method is private"
end
