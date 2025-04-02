# NOTE: run bin/format-filters after changing this file
opal_filter "Singleton" do
  fails "Singleton._load returns the singleton instance for anything passed in to subclass" # NoMethodError: undefined method `_load' for SingletonSpecs::MyClassChild
  fails "Singleton._load returns the singleton instance for anything passed in" # NoMethodError: undefined method `_load' for SingletonSpecs::MyClass
end
