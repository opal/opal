opal_filter "method_added" do
  fails "BasicObject#singleton_method_undefined is called when a method is removed on self"
  fails "BasicObject#singleton_method_undefined is a private method"
  fails "BasicObject#singleton_method_removed is called when a method is removed on self"
  fails "BasicObject#singleton_method_removed is a private method"
  fails "BasicObject#singleton_method_added is called when define_method is used in the singleton class"
  fails "BasicObject#singleton_method_added is called when a method is defined in the singleton class"
  fails "BasicObject#singleton_method_added is called when a method is defined on self"
  fails "BasicObject#singleton_method_added is a private method"
end
