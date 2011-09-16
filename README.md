Opal
====

Opal is a partial implementation of ruby designed to run in any
javascript environment. The runtime is written in javascript, with all
core libraries written directly in ruby with inline javascript to make
them as fast as possible.

Wherever possible ruby objects are mapped directly onto their native
javascript counterparts to speed up the generated code and to improve
interopability with existing javascript libraries.

The opal compiler is a source-to-source compiler which outputs
javascript which can then run on the core runtime.

Opal does not aim to be 100% comaptible with other ruby implementations,
but does so where the generated code can be efficient on all modern web
browsers - including older versions of IE and mobile devices.

Differences from ruby
---------------------

### No method\_missing

To optimize method dispatch, `method_missing` is not supported in opal.
It is supported in debug mode to improve readability of error messages
from calling undefined methods, but should/will not be used in
production code.

### Immutable strings and removed symbols

All strings in opal are immutable to make them easier to map onto
javascript strings. In opal a ruby string compiles directly into a js
string without a wrapper so that they can be passed back between code
bases easily. Also, symbol syntax is maintained, but all symbols just
compile into javascript strings. The `Symbol` class is also therefore
removed.

### Unified Numeric class

All numbers in opal are members of the `Numeric` class. The `Integer`
and `Float` classes are removed.

### Unified Boolean class

Both `true` and `false` compile into their native javascript
counterparts which means that they both become instances of the
`Boolean` class and opal removes the `TrueClass` and `FalseClass`.

Using opal
----------

Opal can currently be used in two ways: through a distributed ruby gem,
or directly in the web browser.

### Using the gem

**Version warning**: The current gem release is 0.3.6, where as this
code repo is at 0.4.0. To run the latest version of opal it is best to
clone this repo and use it locally.

Install via ruby gems:

```
$ gem install opal
```

The `opal` command should then be available. To run the simple repl use:

```
opal irb
```

The `opal` command can also be used directly from this source repo, so
to download and run opal:

```
$ git clone https://github.com/adambeynon/opal.git
$ cd opal
$ bin/opal
```

