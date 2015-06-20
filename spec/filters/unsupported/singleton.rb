opal_filter "Singleton" do
  fails "Singleton#_dump returns an empty string from a singleton subclass"
  fails "Singleton#_dump returns an empty string"
  fails "Singleton.allocate is a private method"
  fails "Singleton.new is a private method"
end
