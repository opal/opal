Opal
====

Opal is an implementation of the ruby runtime and corelib to be run
directly on top of Javascript. It is primarily designed to run in the
browser to form the basis of a richer client-side environment.

**Homepage**:      [http://opalscript.org](http://opalscript.org)
**Github**:
[http://github.com/adambeynon/opal](http://github.com/adambeynon/opal)

Overview
--------

Opal consists of two parts; the runtime and corelib which are written in
javascript and ruby respectively, and the build tools (containing the
compiler/code generator) which compiles ruby source into javascript.
These compiled files then rely on the opal runtime to operate.

Features/what works:

* method\_missing works on all objects/classes
* Full operator overloading (`[]`, `[]=`, `+`, `-`, `==` etc)
* Inline javascript within ruby code using backticks
* Generated code is clean and maintains line-numbers and indentation
* Toll-free bridging of ruby objects to natives (array, string, numeric
  etc)
* `super()`, metaclasses, blocks, `yield`, `block_given?`, lambdas,
  singletons, modules, etc..

Installation
------------

Opal is under work towards version 0.4.0. To use the latest code, on
this master branch, clone the repo:

    $ git clone git://github.com/opal/opal.git

The code is nearly ready to run. Firstly, however, you need to compile
the corelib (written in ruby) into javascript, so run:

    $ rake opal

This builds opal into `opal.js`. Opal is now ready to use.

Usage
-----

Opal has a built in REPL that uses `therubyracer` to hold a built in
context. Try the REPL with:

    $ ruby -I ./lib bin/opal irb

This will use the local directory to run the virtual machine.

Running tests
-------------

To quickly run all tests:

    $ rake test

This does rely on opal being built first, so run `rake opal` if not
already done.

### Running tests in the browser.

To run tests in the browser, first build them with:

    $ rake opal2:test

Which will build `opal.test.js`. Then, to run the tests, open
`spec/spec_runner.html` in any browser - all tests should pass.

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

