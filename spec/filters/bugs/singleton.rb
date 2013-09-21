opal_filter "Singleton" do
  fails "Singleton.allocate is a private method"
  fails "Singleton#_dump returns an empty string"
  fails "Singleton#_dump returns an empty string from a singleton subclass"
  fails "Singleton.instance returns an instance of the singleton's clone"
  fails "Singleton.instance returns the same instance for multiple class to instance on clones"
  fails "Singleton.new is a private method"
end
