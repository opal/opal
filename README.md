# Opal

[![Build Status](http://img.shields.io/travis/opal/opal/master.svg?style=flat)](http://travis-ci.org/opal/opal)
[![Gem Version](http://img.shields.io/gem/v/opal.svg?style=flat)](http://badge.fury.io/rb/opal)
[![Code Climate](http://img.shields.io/codeclimate/github/opal/opal.svg?style=flat)](https://codeclimate.com/github/opal/opal)

Opal is a Ruby to JavaScript source-to-source compiler. It also has an
implementation of the Ruby corelib.

Opal is [hosted on GitHub](http://github.com/opal/opal). Chat is available on *Gitter* at [opal/opal](https://gitter.im/opal/opal) (also available as IRC at `irc.gitter.im`) and the Freenode IRC channel at [#opal](http://webchat.freenode.net/?channels=opal).
Ask questions on [stackoverflow (tag #opalrb)](http://stackoverflow.com/questions/ask?tags=opalrb). Get the [Opalist newsletter](http://opalist.co) for updates and community news.

[![Inline docs](http://inch-ci.org/github/opal/opal.svg?branch=master&style=flat)](http://opalrb.org/docs/api)
[![Gitter chat](http://img.shields.io/badge/gitter-opal%2Fopal-009966.svg?style=flat)](https://gitter.im/opal/opal)
[![Stack Overflow](http://img.shields.io/badge/stackoverflow-%23opalrb-orange.svg?style=flat)](http://stackoverflow.com/questions/ask?tags=opalrb)

## Usage

See the website for more detailed instructions and guides for Rails, jQuery, Sinatra, rack, CDN, etc. [http://opalrb.org](http://opalrb.org).

### Compiling Ruby code with the CLI (Command Line Interface)

Contents of `app.rb`:

```ruby
puts 'Hello world!'
```

Then from the terminal

```bash
$ opal --compile app.rb > app.js # The Opal runtime is included by default but
                                 # but can be skipped with the --no-opal CLI flag.
```

The resulting JavaScript file can be used normally from an HTML page:

```html
<script src="app.js"></script>
```

Be sure to set the page encoding to `UTF-8` inside your `<head>` tag as follows:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <script src="app.js"></script>
    …
  </head>
  <body>
    …
  </body>
</html>
```

Just open this page in a browser and check the JavaScript console.


### Compiling Ruby code from Ruby

`Opal.compile` is a simple interface to just compile a string of Ruby into a
string of JavaScript code.

```ruby
Opal.compile("puts 'wow'")  # => "(function() { ... self.$puts("wow"); ... })()"
```

Running this by itself is not enough, you need the opal runtime/corelib.

#### Using Opal::Builder

`Opal::Builder` can be used to build the runtime/corelib into a string.

```ruby
Opal::Builder.build('opal') #=> "(function() { ... })()"
```

or to build an entire app including dependencies declared with `require`:

```ruby
builder = Opal::Builder.new
builder.build_str('require "opal"; puts "wow"', '(inline)')
File.write 'app.js', builder.to_s
```


### Compiling Ruby code from HTML (or Using it as you would with inline Javascript)

`opal-parser` allows you to *eval* Ruby code directly from your HTML (and from Opal) files without needing any other building process.

So you can create a file like the one below, and start writing ruby for
your web applications.


```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <script src="http://cdn.opalrb.org/opal/current/opal.js"></script>
    <script src="http://cdn.opalrb.org/opal/current/opal-parser.js"></script>
    <script type="text/javascript">Opal.load('opal-parser')</script>

    <script type="text/ruby">
      puts "hi"
    </script>

  </head>
  <body>
  </body>
</html>
```

Just open this page and check the JavaScript console.

**NOTE**: Although this is possible, this is not really recommended for
production and should only be used as a quick way to getting you hands
on opal


## Running tests

First, install dependencies:

    $ bundle install
    $ npm install -g jshint

RubySpec related repos must be cloned as git submodules:

    $ git submodule update --init

The test suite can be run using (requires [phantomjs][]):

    $ bundle exec rake

This will command will run all RSpec and MSpec examples in sequence.

#### Automated runs

A `Guardfile` with decent mappings between specs and lib/corelib/stdlib files is in place.
Run `bundle exec guard -i` to start `guard`.


### MSpec

[MSpec][] tests can be run with:

    $ env SUITE=rubyspec rake mspec
    $ env SUITE=opal     rake mspec

Alternatively, you can just load up a rack instance using `rackup`, and
visit `http://localhost:9292/` in any web browser.


### Rspec

[RSpec][] tests can be run with:

    $ rake rspec


## Code Overview

What code is supposed to run where?

* `lib/` code runs inside your Ruby env. It compiles Ruby to JavaScript.
* `opal/` is the runtime+corelib for our implementation (runs in browser).
* `stdlib/` is our implementation of Ruby's stdlib. It is optional (runs in browser).

### lib

The `lib` directory holds the Opal parser/compiler used to compile Ruby
into JavaScript. It is also built ready for the browser into `opal-parser.js`
to allow compilation in any JavaScript environment.

### corelib

This directory holds the Opal runtime and corelib implemented in Ruby and
JavaScript.

### stdlib

Holds the stdlib that Opal currently supports. This includes `Observable`,
`StringScanner`, `Date`, etc.

## Browser support

* Internet Explorer 6+
* Firefox (Current - 1) or Current
* Chrome (Current - 1) or Current
* Safari 5.1+
* Opera 12.1x or (Current - 1) or Current

Any problems encountered using the browsers listed above should be reported as bugs.

(Current - 1) or Current denotes that we support the current stable version of
the browser and the version that preceded it. For example, if the current
version of a browser is 24.x, we support the 24.x and 23.x versions.

12.1x or (Current - 1) or Current denotes that we support Opera 12.1x as well
as the last 2 versions of Opera. For example, if the current Opera version is 20.x,
then we support Opera 12.1x, 19.x and 20.x but not Opera 15.x through 18.x.

Cross-browser testing is sponsored by [BrowserStack](http://browserstack.com).

## License

(The MIT License)

Copyright (C) 2013-2015 by Adam Beynon

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


[phantomjs]: http://phantomjs.org
[MSpec]: https://github.com/rubyspec/mspec#readme
[RSpec]: https://github.com/rspec/rspec#readme
