# Opal

Opal is a ruby to javascript compiler. Opal aims to take ruby files and generate
efficient javascript that maintains rubys features. Opal will, by default,
generate fast and efficient code in preference to keeping all ruby features.

Opal comes with an implementation of the ruby corelib, written in ruby, that
uses a bundled runtime (written in javascript) that tie all the features
together. Whenever possible Opal bridges to native javascript features under
the hood. The Opal gem includes the compiler used to convert ruby sources
into javascript.

For docs, visit the website:
[http://opalrb.org](http://opalrb.org)

Join the IRC channel on Freenode: `#opal`.

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

#### Testing in the browser

Alternatively, tests can be run in the browser, but first, `opal-spec`
is required. Dependnecies can be built with:

    rake dependencies

Finally, the actual tests need to be compiled as well, and that can be
done with:

    rake opal:test

Open `core_spec/runner.html` in a browser and observe any failures.

## License

Opal is released under the MIT license.
