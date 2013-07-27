Opal is a source-to-source compiler, so there is no VM as such and the
compiled code aims to be as fast and efficient as possible, mapping
directly to underlying javascript features and objects where possible.

## Literals

**self** is mostly compiled to `this`. Methods and blocks are implemented
as javascript functions, so their `this` value will be the right
`self` value. Class bodies and the top level scope use a `self` variable
to improve readability.

**true** and **false** are compiled directly into their native boolean
equivalents. This makes interaction a lot easier as there is no need
to convert values to opal specific values. It does mean that there is
only a `Boolean` ruby class available, not seperate `TrueClass` and
`FalseClass` classes.

*nil* is compiled to `null`, so it can easily be passed between ruby and
javascript code. `undefined` is also a valid value for `nil`, and both
can be passed seamlessly. You can still call methods on `nil` as it is
treated as an instance of `NilClass`.

```ruby
nil         # => null
true        # => true
false       # => false
self        # => self
```

##### Strings

Ruby strings are compiled directly into javascript strings for
performance as well as readability. This has the side effect that Opal
does not support mutable strings - i.e. all strings are immutable.

##### Symbols

For performance reasons, symbols compile directly into strings. Opal
supports all the symbol syntaxes, but does not have a real `Symbol`
class. Symbols and Strings can therefore be used interchangeably.

```ruby
"hello world!"    # => "hello world!"
:foo              # => "foo"
<<-EOS            # => "\nHello there.\n"
Hello there.
EOS
```

##### Numbers

In Opal there is a single class for numbers; `Numeric`. To keep opal
as performant as possible, ruby numbers are mapped to native numbers.
This has the side effect that all numbers must be of the same class.
Most relevant methods from `Integer`, `Float` and `Numeric` are
implemented on this class.

```ruby
42        # => 42
3.142     # => 3.142
```

##### Arrays

Ruby arrays are compiled directly into javascript arrays. Special
ruby syntaxes for word arrays etc are also supported.

```ruby
[1, 2, 3, 4]        # => [1, 2, 3, 4]
%w[foo bar baz]     # => ["foo", "bar", "baz"]
```

##### Hash

Inside a generated ruby script, a function `__hash` is available which
creates a new hash. This is also available in javascript as `Opal.hash`
and simply returns a new instance of the `Hash` class.

```ruby
{ :foo => 100, :baz => 700 }    # => __hash("foo", 100, "baz", 700)
{ foo: 42, bar: [1, 2, 3] }     # => __hash("foo", 42, "bar", [1, 2, 3])
```

##### Range

Similar to hash, there is a function `__range` available to create
range instances.

```ruby
1..4        # => __range(1, 4, true)
3...7       # => __range(3, 7, false)
```

## Method missing (method_missing)

Opal fully supports `method_missing` and it is turned on by default.
Opal can also send methods to `nil`, and the receiver is checked inline
to be able to dispatch calls to native `null` or `undefined`.

### Optimized Math Operators

In ruby, all math operators are method calls, but compiling this into
javascript would end up being too slow. For this reason, math
operators are optimized to test first if the receiver is a number, and
if so then to just carry out the math call.

```ruby
3 + 4
```

This ruby code will then be compiled into the following javascript:

```javascript
(a = 3, b = 4, typeof(a) === "number" ? a + b : /* method call */)
```

This ternary statement falls back on sending a method to the receiver
so all non-numeric receivers will still have the normal method call
being sent. This optimization makes math operators a **lot faster**.
Currently, the optimized method calls are `+`, `-`, `*` and `/`.

## Logic and conditionals

As per ruby, Opal treats only `false` and `nil` as falsy, everything
else is a truthy value including `""`, `0` and `[]`. This differs from
javascript as these values are also treated as false.

For this reason, most truthy tests must check if values are `false` or
`nil`. Note: as `nil` compiles to `null`, the truthyness tests will
check `null` and `undefined` as both values are valid `nil`.

Taking the following test:

```ruby
val = 42

if val
  return 3.142;
end
```

This would be compiled into:

```javascript
var val = 42;

if (val !== false && val != null) {
  return 3.142;
}
```

This makes the generated truthy tests (`if` statements, `and` checks and
`or` statements) a litle more verbose in the generated code.

## Instance variables

Instance variables in Opal work just as expected. When ivars are set or
retrieved on an object, they are set natively without the `@` prefix.
This allows real javascript identifiers to be used which is more
efficient then accessing variables by string name.

```ruby
@foo = 200
@foo  # => 200

@bar  # => nil
```

This gets compiled into:

```javascript
this.foo = 200;
this.foo;   // => 200

this.bar;   // => nil
```

## Interacting with javascript

Opal tries to interact as cleanly with javascript and its api as much
as possible. Ruby arrays, strings, numbers, regexps, blocks and booleans
are just javascript native equivalents. The only boxed core features are
hashes.

As most of the corelib deals with these low level details, opal provides
a special syntax for inlining javascript code. This is done with
x-strings or "backticks", as their ruby use has no useful translation
in the browser.

```ruby
`window.title`
# => "Opal: ruby to javascript compiler"

%x{
  console.log("ruby version is:");
  console.log(#{ OPAL_VERSION });
}

# => ruby version is:
# => 0.3.19
```

Even interpolations are supported, as seen here.

This feature of inlining code is used extensively, for example in
Array#length:

```ruby
class Array
  def length
    `this.length`
  end
end
```

X-Strings also have the ability to automatically return their value,
as used by this example.

## Javascript interacting with Opal

Accessing classes and methods defined in Opal from the javascript runtime is
possible via the Opal js object. The following class:

```ruby
class Foo
  def bar
    puts "called bar on class Foo defined in ruby code"
  end
end
```
Can be accessed from javascript like this:

```javascript
Opal.Foo.$new().$bar();
// => "called bar on class Foo defined in ruby code"
```

Remember that all ruby methods are prefixed with a '$'.

## Compiled Files

As described above, a compiled ruby source gets generated into a string
of javascript code that is wrapped inside an anonymous function. This
looks similar to the following:

```javascript
(function() {
  var _klass = Opal.klass, self = Opal.top;
  // generated code
})();
```

As a complete example, assuming the following code:

```ruby
puts "foo"
```

This would compile directly into:

```javascript
(function() {
  var _klass = Opal.klass, self = Opal.top;
  self.$puts("foo");
})();
```

Most of the helpers are no longer present as they are not used in this
example.

## Using compiled sources

If you write the generated code as above into a file `app.js` and add
that to your HTML page, then it is obvious that `"foo"` would be
written to the browser's console.

## Debugging and finding errors

Because Opal does not aim to be fully compatible with ruby, there are
some instances where things can break and it may not be entirely
obvious what went wrong.

### Using javascript debuggers

As opal just generates javascript, it is useful to use a native
debugger to work through javascript code. To use a debugger, simply
add an x-string similar to the following at the place you wish to
debug:

```ruby
# .. code
`debugger`
# .. more code
```
The x-strings just pass the debugger statement straight through to the
javascript output.

Inside methods and blocks, the current `self` value is always the
native `this` value. You will not see `self` inside debuggers as it is
never used to refer to the actual ruby self value.

All local variables and method/block arguments also keep their ruby
names except in the rare cases when the name is reserved in javascript.
In these cases, a `$` suffix is added to the name (e.g. `try` =>
`try$`).