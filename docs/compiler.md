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
that - self.

Compiling method calls
======================

Compiling class and module definitions
======================================
