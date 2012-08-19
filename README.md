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
rake opal parser
```

Run tests using phantom.js runner:

```
rake test
```

## License

Opal is released under the MIT license.