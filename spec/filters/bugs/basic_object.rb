opal_filter "BasicObject" do
  fails "BasicObject#instance_eval evaluates strings"
  fails "BasicObject#singleton_method_added is called when a method is defined with alias_method in the singleton class"
  fails "BasicObject#singleton_method_added is called when a method is defined with syntax alias in the singleton class"
  fails "BasicObject instance metaclass contains methods defined for the BasicObject instance"
  fails "BasicObject instance metaclass has BasicObject as superclass"
  fails "BasicObject instance metaclass is an instance of Class"
  fails "BasicObject metaclass contains methods for the BasicObject class"
  fails "BasicObject metaclass has Class as superclass"
  fails "BasicObject does not define built-in constants (according to defined?)"
  fails "BasicObject does not define built-in constants (according to const_defined?)"
  fails "BasicObject raises NameError when referencing built-in constants"
  fails "BasicObject raises NoMethodError for nonexistent methods after #method_missing is removed"
end
