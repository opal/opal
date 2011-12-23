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

    $ git clone git://github.com/adambeynon/opal.git

And use the given Gemfile to get any dependencies:

    $ bundle install

The code is nearly ready to run. Firstly, however, you need to compile
the corelib (written in ruby) into javascript, so run:

    $ rake opal

This builds opal into `runtime/opal.js`. Opal is now ready to use.

Usage
-----

Opal has a built in REPL that uses `therubyracer` to hold a built in
context. Try the REPL with:

    $ bundle exec bin/opal irb

This will use the local directory to run Opal.

Running tests
-------------

To quickly run all tests:

    $ rake test

This will build opal if not already done so.

### Running tests in the browser.

To run tests in the browser, first build them with:

    $ rake opal:test

Which will build `runtime/opal.test.js`. Then, to run the tests, open
`runtime/spec/spec_runner.html` in any browser - all tests should pass.
