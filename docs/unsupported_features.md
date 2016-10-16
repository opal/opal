# Unsupported Features

Opal does not support some language/runtime features of ruby. These are documented here when possible, as well as the reasons why they are not supported.

#### Mutable Strings ####

For performance and ease of runtime features, all strings in Opal are immutable, i.e. `#<<`, `#gsub!`, etc. do not exist. Also, symbols are just strings. There is no class, runtime or feature difference between Symbols and Strings. Their syntaxes can be used interchangeably.

#### Numbers ####

Opal uses JavaScript native (floating-point) numbers, so `1 / 4` is `0.25` (not `0`) and `4.0 / 2` is `2` (not `2.0`).

#### Encodings ####

Encodings only have a very small implementation inside Opal.

#### Threads ####

JavaScript does not have a native `Thread` implementation, so they are not present inside Opal. There is a placeholder `Thread` class just to provide some small level of compatibility with libraries that expect it. It does not have any function.

#### Frozen Objects ####

Opal does not currently support frozen objects, but has placeholder methods to prevent other libraries breaking when expecting these methods. Opal could support frozen objects in the future once a similar implementation becomes available across JavaScript runtimes.

#### `method_added` and `method_removed` hooks ####

These are not *currently* supported by Opal, but this is considered a bug and will be implemented soon.

#### Private, Public and Protected methods ####

All methods in Opal are defined as `public` to avoid additional runtime overhead. `Module#private` and `Module#protected` exist as just placeholder methods and are no-op methods.
