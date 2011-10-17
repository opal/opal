---
layout: docs
title: "The Opal Compiler"
---

{{ page.title }}
================

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
------------------

The opal compiler generates a function which takes three args - the
opal runtime, the `self` value for the generated code (which will almost
always be "top self"), and the filename the generated code should use.
These three arguments are filled in by the runtime when the code is
about to be run (in the browser or using therubyracer on the command
line).

### Example of a compiled file

The given ruby code:

{% highlight ruby %}
puts 1, 2, 3
{% endhighlight %}

Will compile into (something like) the following javascript:

{% highlight javascript %}
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
{% endhighlight %}

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
-------------------------

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

{% highlight javascript %}
$hash("key1", "value1", "key2", "value2")
{% endhighlight %}

where `$hash` is defined in the outer function as a property retrieved
from the runtime.

Compiling Ruby methods
----------------------

Opal makes use of prototypes for inheriting and method storage. When a
method is defined on a receiver, it has a 'm$' prefix - this stops ruby
methods conflicting with native functions and properties on a receiver
(like arrays for instance which are just native js arrays). Opal
maintains method names, evern for methods which are invalid as
javascript identifiers, so some method names need to be wrapped inside a
property accessor.

### Method calls

The following three ruby calls:

{% highlight ruby %}
do_something 1, 2, 3
self.length
self.title = "adam"
self.loaded?
{% endhighlight %}

compile into the following javascript:

{% highlight javascript %}
self.m$do_something(1, 2, 3)
self.m$length()
self['m$title=']("adam")
self['m$loaded?']()
{% endhighlight %}

Splat method call are also fully supported, and compile the following
ruby:

{% highlight ruby %}
puts *[1, 2, 3]
{% endhighlight %}

into the somewhat ugly:

{% highlight javascript %}
self.m$puts.apply(self, [1, 2, 3])
{% endhighlight %}

#### Blocks

Blocks are not regular method arguments in ruby, so they are not treated
as so in opal. To send a method a block, there is a special '$B'
variable on the runtime that holds the current block function and proc.
The block function is the literal function (method) that the block is
sent to. Before calling a method, the function is noted. The proc is the
actual block implementation which is just a regular function.

For example, the ruby call:

{% highlight ruby %}
self.method do
  nil
end
{% endhighlight %}

is compiled into (something like) the following:

{% highlight javascript %}
($B.p = function() { return nil; }, // the proc
 $B.f = self.m$method               // the method/function receiver
).call()                            // call the method
{% endhighlight %}

The receiver method is responsible for looking up the block to see if
one was sent to it.

The process is similar for `&block` args in the method parameter list.

### Method definitions

Ruby methods are implemented as regular javascript functions. The
runtime offers two functions to define a method: `dm` for defining a
regular method and `ds` to define a singleton method which automatically
creates a singleton class as needed (if needed).

A very simple ruby method:

{% highlight ruby %}
def to_s
  "main"
end
{% endhighlight %}

is compiled into the following javascript:

{% highlight javascript %}
$defn(self, 'to_s', function() { var self = this;
  return "main";
});
{% endhighlight %}

`$defn` is a local variable, set in the outer function, that points to
`dm`. There is also `$defs` used for defining the singletons. The first
argument is the receiver, which is always self for normal methods, or
will be the receiver for singleton methods. The second arg is the method
name, and the third is the implementation. 

It is also obvious that `self` here is set to `this`, which is the
object receiver. The singleton version of this function would be
identical except for the receiver.

#### Handling blocks

A method is said to handle a block if it either calls `yield` in its body,
uses `block\_given?` or defines a block as its last argument, with `&`.
If a method handles a block it will always check the previously
mentioned runtime property to see if the block function is the callee.
If it is, the method gets the block and sets both properties to nil. It
must set both properties to nil to avoid the next call to the method
from receiving the block as a false posotive. The block is then just a
native function, so is called as appropriate.

Compiling class and module definitions
--------------------------------------

