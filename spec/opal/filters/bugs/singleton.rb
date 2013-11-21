opal_filter "Singleton" do
  fails "Singleton#_dump returns an empty string"
  fails "Singleton#_dump returns an empty string from a singleton subclass"
  fails "Singleton.instance returns an instance of the singleton's clone"
  fails "Singleton.instance returns the same instance for multiple class to instance on clones"
end
