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

Using opal
----------

Opal can currently be used in three ways: through a distributed ruby gem,
directly in the web browser or with rbp - a new package manager designed
for opal but usable for any ruby project.

### Using the gem

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

### Using rbp

rbp installs dependencies locally to your project, so edit your
package.yml file to add the following dependency:

```yaml
dev_dependencies:
  opal: "0.3.9"
  therubyracer: "0.9.4"
```

Install them with:

```
$ rbp install
```

This will install them into vendor/ ready to use. therubyracer is only
needed if you want to run your ruby code, compiled into javascript,
directly on the commandline. If you are just compiling ruby then just
the opal package is sufficient.

Running tests
-------------

To run tests, you need opaltest which is the testing framework for opal
based on minitest. To get opaltest, run the following in the opal
directory:

```
$ rbp install
```

This will put opaltest into `packages/opaltest` so it will be available
for running. To test `array.rb` for example, run:

```
$ rbp exec opal test/array.rb
```

The results should be printed to the console.

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

