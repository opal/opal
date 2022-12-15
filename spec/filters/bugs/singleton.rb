# NOTE: run bin/format-filters after changing this file
opal_filter "Singleton" do
  fails "Singleton._load returns the singleton instance for anything passed in to subclass" # NoMethodError: undefined method `_load' for SingletonSpecs::MyClassChild
  fails "Singleton._load returns the singleton instance for anything passed in" # NoMethodError: undefined method `_load' for SingletonSpecs::MyClass
  fails "Singleton.instance returns an instance of the singleton's clone" # Exception: self.$$constructor is not a constructor
  fails "Singleton.instance returns the same instance for multiple class to instance on clones" # Exception: self.$$constructor is not a constructor  
end
