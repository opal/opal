# Opal

Opal is a ruby to javascript (source-to-source) compiler. Opal takes
ruby files and compiles them into efficient javascript which, when run
with the opal runtime, can run in any javascript environment, primarily
the browser. Opal chooses runtime speed over ruby features when
applicable.

For docs, visit the website: [http://opalrb.org](http://opalrb.org).

There is also a [Google group for opal](https://groups.google.com/forum/#!forum/opalrb), or
join the IRC channel on Freenode: `#opal`.

## Installation

Opal is distributed as a gem, so install with:

```
gem install opal
```

Or with bunlder:

``` ruby
# Gemfile
gem "opal"
```

## Usage

The simplest way to use Opal is to install the gem and compile code using `Opal.parse`.

```ruby
require 'opal'

Opal.parse "[1, 2, 3, 4].each { |a| puts a }"
# => "(function() { .... }).call(Opal.top);"
```

The `parse` method takes a string of ruby code and outputs the compiled javascript.

## Opal Command Usage

Once installed, the `opal` command is available.

    Usage: opal [options] files...

    Options:
      -c, --compile     Compile ruby
      -o, --out FILE    Output file
      -v, --version     Opal version
      -h, --help        Show help

### REPL

To run a simple REPL, run opal without any arguments:

    $ opal

This REPL will take in a line of ruby, compile it into javascript and
run it against the opal runtime. To exit the REPL type `exit`.

### Compiling sources

To build a simple file, `foo.rb`, run opal with:

    $ opal -c foo.rb

This will generate `foo.js` in the same directory. To specify an output
destination, just use the `-o` flag:

    $ opal -c foo.rb -o build/foo.js

The generated code looks similar to the following:

``` js
(function() {
  // compiled code from foo.rb
}).call(Opal.top);
```

This code will ensure the generated code will run against the top level
ruby object (main/top self) once run.

### Running in the browser

Using the above example, run the `foo.js` code using the following html:

``` html
<!DOCTYPE HTML>
<html>
  <head>
    <script src="opal.js"></script>
    <script src="foo.js"></script>
  </head>
</html>
```

**Note**: `opal.js` is required, and is available on the opal website.

## Contributing

Once this repo is cloned, some dependencies are required, so install
with `bundle install`.

To actually build the opal runtime, there is a rake helper:

    rake opal

This will build `opal.js`.

### Running tests

If you have `therubyracer` installed, tests can be run straight through
the embedded v8 engine with:

    rake test

This will run all tests inside `core_spec` which is a partial
implementation of all RubySpec tests.

### Testing in the browser

Alternatively, tests can be run in the browser, but first, `opal-spec`
is required. Dependnecies can be built with:

    rake dependencies

This will build the `opal-spec.js` and `opal-spec.debug.js` files.

Finally, the actual tests need to be compiled as well, and that can be
done with:

    rake opal:test

Open `core_spec/runner.html` in a browser and observe any failures.

## License

Opal is released under the MIT license.

## Change Log

**Edge**

* Fixed super to support calls to module methods and from within blocks
* Make blocks become the first arg of every method call
* Customizable debug states - use opal, native or no backtracing
* Fixed various Hash specs

**0.3.16** (2012/01/15)

* Added HEREDOCS support in parser
* Parser now handles masgn (mass/multi assignments)
* More useful DependencyBuilder class to build gems dependencies
* Blocks no longer passed as an argument in method calls

**0.3.15** (2012/01/06)

Initial Release.