# Unsupported Features

Opal does not support some language/runtime features of ruby. These are documented here when possible, as well as the reasons why they are not supported.

#### Mutable Strings ####

For performance and ease of runtime features, all strings in Opal are immutable, i.e. `#<<`, `#gsub!`, etc. do not exist. Also, symbols are just strings. There is no class, runtime or feature difference between Symbols and Strings. Their syntaxes can be used interchangeably.

#### Regexp differences ####

We are using JavaScript regular expressions. While we do translate a few of Ruby specific instructions like `\A` or `\z`, there are a lot of incompatibilities that you should be aware of - for example `$` and `^` don't match newlines like they do in Ruby. Support for features like named matches or lookahead/lookbehind is dependent on the JavaScript environment support for those. To support everything, we would need to [compile in the entire Ruby's regular expression engine](https://opalrb.com/blog/2021/06/26/webassembly-and-advanced-regexp-with-opal/) which is unfeasible at the current time.

#### Integer / Float difference ####

In Opal, both integers and floats belong to same class `Number` (using JavaScript native numbers). So `1 / 4` is `0.25` (not `0`) and `4.0 / 2` is `2` (not `2.0`).

`Number` is a subclass of `Numeric`, like `Complex` and `Rational`.

#### Encodings ####

Encodings only have a very small implementation inside Opal.

#### Threads ####

JavaScript does not have a native `Thread` implementation, so they are not present inside Opal. There is a placeholder `Thread` class just to provide some small level of compatibility with libraries that expect it. It does not have any function.

#### Frozen Objects ####

Opal does not currently support frozen objects, but has placeholder methods to prevent other libraries breaking when expecting these methods. Opal could support frozen objects in the future once a similar implementation becomes available across JavaScript runtimes.

#### Private, Public and Protected methods ####

All methods in Opal are defined as `public` to avoid additional runtime overhead. `Module#private` and `Module#protected` exist as just placeholder methods and are no-op methods.
