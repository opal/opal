opal_filter "Singleton" do
  fails "Singleton#_dump returns an empty string"
  fails "Singleton#_dump returns an empty string from a singleton subclass"
  fails "BigDecimal.new doesn't segfault when using a very large string to build the number"
end
