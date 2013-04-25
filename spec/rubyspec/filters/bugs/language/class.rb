opal_filter "class" do
  fails "A class definition raises TypeError if constant given as class name exists and is not a Module"
  fails "A class definition raises TypeError if the constant qualifying the class is nil"
  fails "A class definition raises TypeError if any constant qualifying the class is not a Module"
  fails "A class definition allows using self as the superclass if self is a class"
  fails "A class definition raises a TypeError if inheriting from a metaclass"
  fails "A class definition extending an object (sclass) raises a TypeError when trying to extend numbers"
  fails "A class definition extending an object (sclass) allows accessing the block of the original scope"
  fails "A class definition extending an object (sclass) can use return to cause the enclosing method to return"
  fails "Reopening a class raises a TypeError when superclasses mismatch"
end
