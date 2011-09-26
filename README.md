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

Installing opal
----------

Opal can currently be used in three ways: through a distributed ruby gem,
directly in the web browser.

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

Using opal in the browser
-------------------------

Opal runs directly in the browser, and is distributed as two files,
`opal.js` and `opal-parser.js`. To just run precompiled code, just the
`opal.js` runtime is required which includes the runtime and opals
implementation of the ruby core library (pre compiled).

To evaluate ruby code directly in the browser, `opal-parser.js` is also
required which will also load any ruby code found in script tags.

### Bundle

The quickest way to compile a ruby library is to use `BundleTask` in a
rakefile which will compile ruby code found in `lib/` into a single file
which is ready to load. For example, this task will output the compiled
code into `testlib-0.0.1.js`:

```ruby
require 'opal/rake/bundle_task'

Opal::Rake::BundleTask.new do |t|
  t.name    = "testlib"
  t.version = "0.0.1"
end
```

If you add this to your html document, it will not (yet) actually load.
libs are not autoloaded, and it is recomended that you load your main
entry point after defining all your required libs. For example, the html
page may look like the following:

```html
<!doctype html>
<html>
<head>
  <script src="opal.js"></script>
  <script src="testlib-0.0.1.js"></script>

  <script type="text/javascript">
    // actually load testlib
    opal.require('testlib');
  </script>
</head>
<body></body>
</html>
```

Project structure
-----------------

This repo contains the code for the opal gem as well as the opal core
library and runtime. Files inside `bin/` and `lib/` are the files that
are used as part of the gem and run directly on your ruby environment.

`corelib/` contains opal's core library implementation and is not used
directly by the gem. These files are precompiled during development
ready to be used in the gem or in a browser.

`runtime/` contains opal's runtime written in javascript. It is not used
directly by the gem, but is built ready to use in the js contexts that
opal runs.

`stdlib/` contains the stdlib files that opal comes packaged with. The
gem does use these, but only as required. Opal does not include the full
opal stdlib, and some parts are actually written in javascript for
optimal performance. These can be `require()` at runtime.

`opal.js` and `opal-parser.js` are included in the gem, but not the
source repo. They are the latest built versions of opal and its parser
which are built before the gem is published.

Differences from ruby
---------------------

### Optional method\_missing

To optimize method dispatch, `method_missing` is, by default, turned off
in opal. It can easily be enabled by passing `:method_missing => true`
in the parser options.

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

