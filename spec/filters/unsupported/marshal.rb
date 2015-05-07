opal_filter "Singleton" do
  fails "Singleton#_dump returns an empty string"
  fails "Singleton#_dump returns an empty string from a singleton subclass"
end