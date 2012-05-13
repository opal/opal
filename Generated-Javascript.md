The Opal compiler is a source-to-source compiler; it reads in ruby code and outputs javascript code. The generated code makes use of native javascript features when possible, and all code is output to the same line number as the source. This, along with correctly indented output, makes debugging very easy.

## Ruby Literals

### Literals

**self** is always compiled to `this` in javascript which makes the generated code a lot cleaner to use. All methods, blocks, classes, modules and top level code correctly have their `this` value set.

**true** and **false** are also compiled into their native javascript equivalents. This makes interacting with external libraries a lot easier as there is no need to convert to special ruby values.

**nil** is compiled into a special ruby object (an instance of NilClass). A real object is used (instead of null and undefined) as this allows nil to receive method calls which is a crucial ruby feature which Opal maintains.

### Strings

Ruby strings are compiled directly into javascript strings, for performance as well as readability. This has the side affect that Opal does not support mutable strings - all strings are immutable.

### Symbols

For performance reasons, Symbols compile into the string equivalents. Opal supports the symbol syntax(es), but does not have a real Symbol class. The Symbol constant is just an alias of String. Strings and Symbols can be used in Opal interchangeably.

### Numbers

In Opal there is a single class for all numbers; `Numeric`. To keep Opal as performant as possible, native javascript strings are used. This has the side effect that all numbers must be an instance of a single class. Most relevant methods from `Integer`, `Float` and `Numeric` are implemented on this class.

### Arrays

Ruby arrays compile straight into javascript array literals.

### Hash

There is a special constructor available inside generated sources, `$hash` which is used to create hash instances.

### Range

Similarly to hashes, the `$range` constructor can be used to create new range instances.

## Ruby Methods

A ruby method is just a function in the generated code. These functions are added to the constructor's prototypes so they are called just like any other javascript function. All ruby methods are defined with an `$` prefix which isolates them from any javascript function/property on the receiver.

### Method Calls

All method arguments are passed to the function just like regular
javascript function calls

The following ruby code:

```ruby
do_something 1, 2, 3
self.length
[1, 2, 3].push 5
```

Will therefore compile into the following easy to read javascript:

    this.m$do_something(1, 2, 3);
    this.m$length();
    [1, 2, 3].m$push(5);

There are of course some special characters valid as ruby names that are not valid as javascript identifiers. These are specially encoded to keep the generated javascript sane:

    this.loaded?        # => this.m$loaded$p()
    this.load!          # => this.m$load$b()
    this.loaded = true  # => this.m$loaded$e(true)

Call arguments with splats are also supported:

    self.push *[1, 2, 3]
    # => this.m$push.apply(this, [1, 2, 3])

### Method Definitions

Methods are implemented as regular javascript functions. Assuming the following method definition defined inside a class body:

    def to_s
      inspect
    end

This would generate the following javascript (`def.` will be explained in the Class documentation):

    def.m$to_s = function() {
      return this.m$inspect();
    };

The defined name retains the `$` prefix outlined above, and the `self` value for the method is `this`, which will be the receiver.

Normal arguments, splat args and optional args are all supported:

    def norm(a, b, c)

    end

    def opt(a, b = 100)

    end

    def rest(a, *b)

    end

The generated code reads as expected:

    def.m$norm = function(a, b, c) {
      return nil;
    };

    def.m$opt = function(a, b) {
      if (b === undefined) b = 10;
      return nil;
    };

    def.m$rest = function(a, b) {
      b = Array.prototype.slice.call(arguments, 1);
      return nil;
    };
