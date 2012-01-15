# Opal

Opal is a ruby to javascript (source-to-source) compiler. Opal takes
ruby files and compiles them into efficient javascript which, when run
with the opal runtime, can run in any javascript environment, primarily
the browser. Opal chooses runtime speed over ruby features when
applicable.

For docs, visit the website: [http://opalrb.org](http://opalrb.org).

There is also a Google group at [https://groups.google.com/forum/#!forum/opalrb](https://groups.google.com/forum/#!forum/opalrb), or
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

Once installed, the `opal` command is available.

    Usage: opal [options] files...

    Options:
      -c, --compile     Compile ruby
      -o, --out FILE    Output file
      -v, --version     Opal version
      -h, --help        Show help

### REPL

To run a simple REPL, run opal without any arguments:

    opal

This REPL will take in a line of ruby, compile it into javascript and
run it against the opal runtime. To exit the REPL type `exit`.

### Compiling sources

To build a simple file, `foo.rb`, run opal with:

    opal -c foo.rb

This will generate `foo.js` in the same directory. To specify an output
destination, just use the `-o` flag:

    opal -c foo.rb -o build/foo.js

In both scenarios, two files are actually created: `foo.js` and
`foo.debug.js`. The compiler always build a debug version which adds
various debug utilites into the output. See below for more details on
debug mode.

To build an entire directory, just pass the directory name to opal:

    opal -c my_ruby_sources

There is a special case when building directories. When building a `lib`
directory, the output name, if not specified, will be that of the
current directory. For example, if inside `~/dev/opal-spec`, running:

    opal -c lib

Will generate `opal-spec.js` and `opal-spec.debug.js`, which gives a
nice default when building libraries/gems.

### Building dependencies

To run these generated files, the opal runtime is required. These can be
built to the current directory with:

    opal dependencies

Which generates `opal.js` and `opal.debug.js`.

### Running in the browser

The files built by opal will not automatically run in the browser. The
code is wrapped by a register function which identifies the files with
the opal runtime. This allows `require` to work in the browser. So, to
run the `foo.rb` file created as above, use the following html:

``` html
<!DOCTYPE HTML>
<html>
  <head>
    <script src="opal.debug.js"></script>
    <script src="foo.debug.js"></script>
    <script>
      // Run foo.rb file which is stored in foo.debug.js
      opal.main('/foo.rb');
    </script>
  </head>
</html>
```

**Note**: this example runs all debug files, which should be used in
development, but **never** in production - they are a lot slower to gain
all the features outlined in the debug section below.


## Contributing

Once this repo is cloned, some dependencies are required, so install
with `bundle install`.

To actually build the opal runtime, there is a rake helper:

    rake opal

This will build `opal.js` and `opal.debug.js`.

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
