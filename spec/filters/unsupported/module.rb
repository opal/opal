opal_filter "Module" do
  fails "Module#class_variable_set raises a RuntimeError when self is frozen"
  fails "Module#define_method is private"
  fails "Module#define_method raises a RuntimeError if frozen"
  fails "Module#define_method when name is :initialize given an UnboundMethod sets the visibility to private when method is named :initialize"
  fails "Module#define_method when name is :initialize passed a block sets visibility to private when method name is :initialize"
  fails "Module#instance_methods makes a private Object instance method public in Kernel"
end
