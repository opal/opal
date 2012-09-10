# Opal

[![Build Status](https://secure.travis-ci.org/adambeynon/opal.png?branch=master)](http://travis-ci.org/adambeynon/opal)

Opal is a ruby to javascript source-to-source compiler. It also has an 
implementation of the ruby corelib.

Opal is [hosted on github](http://github.com/adambeynon/opal), and there
is a Freenode IRC channel at `#opal`.

## Usage

See the website, [http://opalrb.org](http://opalrb.org).

## Running tests

Build the runtime, tests and dependencies:

```
rake opal
```

Run tests using phantom.js runner:

```
rake test
```

## Code Overview

### Specs

* **core** contains rubyspecs that apply to opal.
* **language** applicable specs from rubyspec for testing language semantics
* **opal** tests for extra methods/features in opal not found in standard ruby
* **lib** specs for opal lib (parser, erb\_parser, grammar etc)

## License

Opal is released under the MIT license.