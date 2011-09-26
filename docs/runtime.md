Opal Runtime
------------

The opal runtime is written in javascript and uses native javascript
features to make its implementation as fast as possible.

Object model
============

Opals object model is directly based of c-ruby with the exception that
`Object` is the root object in the hierarchy instead of `BasicObject`.
`BasicObject` does not exist in Opal. As per ruby, metaclasses etc are
all supported in Opal, so the object hierarchy is that of ruby 1.8
instead of ruby 1.9. The benefits of BasicObject would not be present in
Opal, so it is ommitted.

### Core classes

To be optimal, Opal uses native objects whenever possible. For this
reason, a ruby array is just a javascript array. The same goes for
Regular Expressions, Strings and Numbers. This helps opal be efficient.
Procs are also just Functions.

### Core properties

Every object/class in Opal has a couple of javascript properties that
are runtime properties - the runtime and core classes use them to
operate.

#### .$k

This is the "klass" pointer and every object has one. An object instance
uses this to point to its class. This may be a singleton class if
applicable (to support singleton object classes).

#### .$f

This is the flags property that identifies the type of object. Flags
include `T_OBJECT`, `T_CLASS`, `T_STRING` etc .. every object has one
(or more) of these bitwise-or together.

#### .$id

This is the id property, and every object in Opal has a unique one.
These are added on creation and are used by Hash, for example, to
uniquel identify objects.

#### .$h

Hash function - this is used to calculate the unique hash of an object.
For all ruby objects this just returns its id, but for native bridged
objects this does some internal mangling - see below.

### Additional class properties.

These properties are only for classes, and normal objects do not have
them.

#### .$included\_in

An array of classes that this module is included in. This ensures that
modules can only be included into a class once. Both classes and modules
have this property, but only modules us it.

#### .$m

Method table - this is a javascript object containing a list of mehtod
names to method implementations. This is used by Module#include and
`super` etc to get a list of methods defined on an actual class.

#### .$methods

Methods array - this is an array of method names that are the same as
all the keys in `$m`. This is a useful way for quickly getting all
methods defined on a class.

#### .$a

Instance allocator - this is used by `Class#allocate` to create a new
instance of itself. Classes in opal piggyback on prototypes, so this
just allocates a new object ready to use.

#### .\_\_classid\_\_

The class name of the receiver class. This is fully qualified to include
parent class names as well, e.g. `A::B::C`.

#### .$s

Super - a simple pointer to the superclass for the receiver. Obviously
used in super method lookups.

#### .$c

Constants storage - used to lookup contants for the given class. This
also uses javascript prototype inheritance to speed up name lookups.

