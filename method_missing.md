`method_missing` is supported in opal to run when an undefined method is called upon a receiver. To be efficient, opal uses javascript native strings, numbers and arrays to represent their respective ruby counterparts. Due to the way `method_missing` is implemented, it will not work with these three core classes, but is fully supported on every other class or object. Overriding `method_missing` in String, Array or Numeric probably isn't a good idea anyway.

## Implementation

To make method calls as fast as possible, no dispatch method is used inside opal. Adding a `rb_funcall` method would greatly disrupt performance which is not acceptable. For this reason, the following ruby code:

    self.some_method 1, 2, 3

is compiled into the following javascript:

    self.m$some_method(1, 2, 3);

which adds no overhead to calling a method compared to writing standard javascript. Like ruby, all objects and classes in opal inherit all the way back to the BasicObject class. When calling a method that does not exist, javascript engines will work up the prototype chain until it reaches the core object and then just raise an error stating that the function does not exist. To add method missing support, opal injects fake methods into the core BasicObject prototype to simulate `method_missing`.

These fake methods simply just recall `method_missing` on the receiver passing the respective method id and the passed arguments back to the `method_missing` function that, by default, raises a `NoMethodError`. 