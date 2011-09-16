Opalscript: New branch for opal (ruby runtime on javascript)
============================================================

Opalscript is a fork/branch of the opal runtime which aims for an
optimized ruby runtime on top of javascript. To achieve this, some ruby
features are completely removed and some are replaced to interact both
cleaner with the native javascript environment and to produce faster
code to really optimize the experience on mobile devices and legacy
browsers.

Differences from opal/ruby
--------------------------

### No method\_missing

To optimize method dispatch, `method_missing` is not supported. When an
undefined method is called on a receiver, the result is just a native
javascript `TypeError` as well as a backtrace on supported browsers.

### No method argument checking

Checks to ensure the correct number of args are sent to a method are
removed from opalscript as they slow down **every** method call. Sending
too many args to a method will have no affect, but sending too few may
result in some method parameters having an `undefined` value and will
therefore not respond to method calls (a `TypeError` will be raised when
trying to send a method to it).

### No public/private method support

Opalscript does not support private methods: all methods are public.
Opalscript will also not support protected methods, but they are not
currently supported by opal either (currently...).

### Unified Boolean class

There is a new `Boolean` class in Opalscript that replaces `TrueClass`
and `FalseClass` and becomes the class of both `true` and `false`
literals. This allows native javascript `true` and `false` to be used
directly as their ruby values. This optimizes logic operations.

### Unified Numeric class

All numbers are now instances of the `Numeric` class. There are no
classes for `Integer` or `Float`.

### Removed symbol class

The `Symbol` class has been removed, so all symbols now compile directly
into strings as there is no performance gain for symbols in opal (which
is their benefit in ruby... and the nice syntax).

