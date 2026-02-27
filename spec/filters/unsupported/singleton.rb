# NOTE: run bin/format-filters after changing this file
opal_unsupported_filter "Singleton" do
  fails "Singleton#_dump returns an empty string from a singleton subclass" # NoMethodError: undefined method `_dump' for #<SingletonSpecs::MyClassChild:0x9dc>
  fails "Singleton#_dump returns an empty string" # NoMethodError: undefined method `_dump' for #<SingletonSpecs::MyClass:0x794>
  fails "Singleton.allocate is a private method" # Expected NoMethodError but no exception was raised (#<SingletonSpecs::MyClass:0x9b4> was returned)
  fails "Singleton.new is a private method" # Expected NoMethodError but no exception was raised (#<SingletonSpecs::NewSpec:0xafbfc> was returned)
end
