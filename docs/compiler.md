The Opal compiler
-----------------

The compiler included in opal is a source-to-source compiler: it takes
ruby code and output javascript code. All code generated depends on the
bundled runtime - not just for the core library, but also some runtime
functions included in the core runtime files. This is not a VM, but just
assistant methods to define classes etc.

Opal also generates code which maintains line numbers for all statements
and expressions. This makes it really easy to debug through the
generated javascript. Also, advanced debuggers will use these line
numbers in stack traces etc to make things extra eash.

The generated code
==================

The opal compiler generates a function which takes three args - the
opal runtime, the `self` value for the generated code (which will almost
always be "top self"), and the filename the generated code should use.
These three arguments are filled in by the runtime when the code is
about to be run (in the browser or using therubyracer on the command
line).

### Example of a compiled file

The given ruby code:

```ruby
puts 1, 2, 3
```

Will compile into (something like) the following javascript:

```javascript
// $rb = opal runtime
// self = self value
// __FILE__ = current filename
function($rb, self, __FILE__) {
  // actual file implementation
  function $$() {
    return self.m$puts(1, 2, 3);
  }

  var nil = $rb.Qnil, $class = $rb.dc, $defn = $rb.dm;
  return $$();
}
```

The outermost function is the one previously mentioned - opal simple,
when required, will pass the relevant args to this function to execute.
The inner function `$$` is the body of the file. This is where all the
code actually goes. It is wrapped so that is can be called after all the
variables below it can be initialized. The variables are not defined
first as it will add a lot of line noise which makes it hard to debug.

Below the function we define the variables needed for the file - these
are all taken from the runtime and include `nil`, `$class` for defining
classes and `$defn` for defining methods. There are a few more but they
are ommitted to keep the example simple.

The final line `return $$()` simply runs the body and returns the value.
This value is mostly ignored, but it is useful for REPLs (for instance).

Compiling object literals
=========================

### self

In the generated code, the `self` variable is always generated as just
that - self. This is defined by the given value in the outer-most
function above. When entering into a class definition, method body or
block body, the value of self is redefined. See the relevant section
below for more. Note: self always compiles to the "self" variable.

### nil

`nil` in opal is a true ruby object and does not simply fall back to
`null` or `undefined`. This allows it to respond to messages just like
in ruby. Nil always compiles to the nil variable which is also defined
within the top level function.

### true and false

In Opal the `Boolean` class is used instead of seperate `TrueClass` and
`FalseClass` allowing native javascript `true` and `false` values to be
used.

### Numbers

In Opal the only numerical class is `Numeric` which represents both
integers and floats. This is a result of only a single numeric type in
javascript, so keeping to a single class for numbers improves
efficiency. Numbers in opal compile directly into number literals in
javascript.

### Strings

Strings in opal compile directly into javascript string literals.
Because of this all strings in opal are immutable, so some mutating
string methods are ommitted from opal.

### Symbols

The symbol syntax in opal is maintained, but there is no symbol class.
Symbols compile directly into string literals as their speed benefit is
lost in javascript and they would actually make the runtime slower.

### Arrays

Opal arrays also compile directly into javascript array literals. This
feature is very useful when dealing with splat method calls and splat
arguments in blocks and method definitions.

### Hash

Hash literals compile into a function call that returns a new hash
instance. Hashes in opal are true ruby objects so the allocator method
adds each key/value pair into its internals. This compiles as follows:

```javascript
$hash("key1", "value1", "key2", "value2")
```

where `$hash` is defined in the outer function as a property retrieved
from the runtime.

Compiling method calls
======================

Compiling class and module definitions
======================================
