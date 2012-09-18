# Opal

[![Build Status](https://secure.travis-ci.org/opal/opal.png?branch=master)](http://travis-ci.org/opal/opal)

Opal is a ruby to javascript source-to-source compiler. It also has an 
implementation of the ruby corelib.

Opal is [hosted on github](http://github.com/opal/opal), and there
is a Freenode IRC channel at `#opal`. There is also a [google group for opal](http://groups.google.com/forum/#!forum/opalrb).

## Usage

See the website, [http://opal.github.com](http://opal.github.com).

## Running tests

Build the runtime, tests and dependencies:

```
rake opal
```

Run tests using phantom.js runner:

```
rake
```

Alternatively, after building, you can open `spec/index.html` in any
web browser.

## Code Overview

### core

The `core` directory holds the opal runtime and corelib implemented in
ruby and javascript. These are built using `rake opal`, as above.

### lib

The `lib` directory holds the opal parser/compiler used to compile ruby
into javascript. It is also built ready for the browser into `opal-parser.js`
to allow compilation in any javascript environment.

### spec

* **core** contains rubyspecs that apply to opal.
* **language** applicable specs from rubyspec for testing language semantics
* **opal** tests for extra methods/features in opal not found in standard ruby
* **lib** specs for opal lib (parser, erb\_parser, grammar etc)

## License

Copyright (C) 2012 by Adam Beynon

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.