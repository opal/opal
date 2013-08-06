opal_filter "metaclass" do
  fails "calling methods on the metaclass calls a method defined on the metaclass of the metaclass"
  fails "calling methods on the metaclass calls a method in deeper chains of metaclasses"
  fails "A constant on a metaclass is preserved when the object is cloned"
  fails "A constant on a metaclass is not preserved when the object is duped"
  fails "A constant on a metaclass does not appear in the object's class constant list"
  fails "A constant on a metaclass appears in the metaclass constant list"
  fails "A constant on a metaclass raises a NameError for anonymous_module::CONST"
  fails "A constant on a metaclass cannot be accessed via object::CONST"
  fails "A constant on a metaclass is not defined in the metaclass opener's scope"
  fails "A constant on a metaclass is not defined on the object's class"
  fails "self in a metaclass body (class << obj) raises a TypeError for symbols"
  fails "self in a metaclass body (class << obj) raises a TypeError for numbers"
end
