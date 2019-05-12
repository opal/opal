<h1 align="center">
  <img src="https://secure.gravatar.com/avatar/88298620949a6534d403da2e356c9339?s=420" 
  align="center" title="Opal logo by Elia Schito" width="105" height="105" />
  <br/>
  Opal  <br/>
  <img src="https://img.shields.io/badge/Opal-Ruby%20💛%20JavaScript-yellow.svg?logo=ruby&style=social&logoColor=777"/>
</h1>

<p align="center">
  <em><strong>Opal</strong> is a Ruby to JavaScript source-to-source compiler.<br> 
    It also has an implementation of the Ruby <code>corelib</code> and <code>stdlib</code>.</em>
</p>

<p align="center">
  <strong>Community:</strong><br>
  <a href="https://stackoverflow.com/questions/ask?tags=opalrb"><img src="https://img.shields.io/badge/stackoverflow-%23opalrb-orange.svg?style=flat" alt="Stack Overflow" title="" /></a>
  <a href="#backers"><img src="https://opencollective.com/opal/backers/badge.svg" alt="Backers on Open Collective" title="" /></a> 
  <a href="#sponsors"><img src="https://opencollective.com/opal/sponsors/badge.svg" alt="Sponsors on Open Collective" title="" /></a> 
  <a href="https://gitter.im/opal/opal?utm_source=badge&amp;utm_medium=badge&amp;utm_campaign=pr-badge"><img src="https://badges.gitter.im/Join%20Chat.svg" alt="Gitter" title="" /></a>
  <a href="https://opalrb.com/docs"><img src="https://img.shields.io/badge/docs-updated-blue.svg" alt="Documentation" title="" /></a>
  <br>
  <strong>Code:</strong><br>
  <a href="https://badge.fury.io/rb/opal"><img src="https://img.shields.io/gem/v/opal.svg?style=flat" alt="Gem Version" title="" /></a>
  <a href="https://travis-ci.org/opal/opal"><img src="https://img.shields.io/travis/opal/opal/master.svg?style=flat" alt="Build Status (Linux)" title="" /></a>
  <a href="https://ci.appveyor.com/project/elia/opal/branch/master"><img src="https://ci.appveyor.com/api/projects/status/jtsvwl8tfgn3u67n/branch/master?svg=true" alt="Build Status (Windows)" title="" /></a>
  <a href="https://codeclimate.com/github/opal/opal"><img src="https://img.shields.io/codeclimate/maintainability-percentage/opal/opal.svg" alt="Code Climate" title="" /></a>
  <a href="https://coveralls.io/github/opal/opal?branch=elia%2Fcoveralls"><img src="https://coveralls.io/repos/opal/opal/badge.svg?branch=master&amp;service=github" alt="Coverage Status" title="" /></a>
</p>

## Usage

See the website for more detailed instructions and guides for Rails, jQuery, Sinatra, rack, CDN, etc. [https://opalrb.com](https://opalrb.com).

### Compiling Ruby code with the CLI (Command Line Interface)

Contents of `app.rb`:

```ruby
puts 'Hello world!'
```

Then from the terminal

```bash
$ opal --compile app.rb > app.js # The Opal runtime is included by default
                                 # but can be skipped with the --no-opal flag
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

Running this by itself is not enough; you need the opal runtime/corelib.

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


### Compiling Ruby code from HTML (or using it as you would with inline JavaScript)

`opal-parser` allows you to *eval* Ruby code directly from your HTML (and from Opal) files without needing any other building process.

So you can create a file like the one below, and start writing ruby for
your web applications.


```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <script src="https://cdn.opalrb.com/opal/current/opal.js" onload="Opal.load('opal')"></script>
    <script src="https://cdn.opalrb.com/opal/current/opal-parser.js" onload="Opal.load('opal-parser')"></script>

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
production and should only be used as a quick way to get your hands
on opal.

## Running tests

The Ruby Spec Suite related repos must be cloned as git submodules:

    $ git submodule update --init

Then, install dependencies:

    $ bundle install
    $ npm install -g jshint

The test suite can be run using:

    $ bundle exec rake

This will command will run all RSpec and MSpec examples in sequence.

#### Automated runs

A `Guardfile` with decent mappings between specs and lib/corelib/stdlib files is in place.
Run `bundle exec guard -i` to start `guard`.


### MSpec

[MSpec][] tests can be run with:

    $ rake mspec

Alternatively, you can just load up a rack instance using `rackup`, and
visit `http://localhost:9292/` in any web browser.


### RSpec

[RSpec][] tests can be run with:

    $ rake rspec


## Code Overview

What code is supposed to run where?

* `lib/` code runs inside your Ruby env. It compiles Ruby to JavaScript.
* `opal/` is the runtime+corelib for our implementation (runs in browser).
* `stdlib/` is our implementation of Ruby's stdlib. It is optional (runs in browser).

### lib/

The `lib` directory holds the **Opal parser/compiler** used to compile Ruby
into JavaScript. It is also built ready for the browser into `opal-parser.js`
to allow compilation in any JavaScript environment.

### opal/

This directory holds the **Opal runtime and corelib** implemented in Ruby and
JavaScript.

### stdlib/

Holds the **stdlib currently supported by Opal**. This includes `Observable`,
`StringScanner`, `Date`, etc.

## Browser support

* Internet Explorer 9+
* Firefox (Current - 1) or Current
* Chrome (Current - 1) or Current
* Safari (Current - 1) or Current
* Opera (Current - 1) or Current

Any problems encountered using the browsers listed above should be reported as bugs.

(Current - 1) or Current denotes that we support the current stable version of
the browser and the version that preceded it. For example, if the current
version of a browser is 24.x, we support the 24.x and 23.x versions.

12.1x or (Current - 1) or Current denotes that we support Opera 12.1x as well
as the last 2 versions of Opera. For example, if the current Opera version is 20.x,
then we support Opera 12.1x, 19.x and 20.x but not Opera 15.x through 18.x.

Cross-browser testing is sponsored by [SauceLabs](https://saucelabs.com).

## Contributors

This project exists thanks to all the people who contribute. [![contributors](https://opencollective.com/opal/contributors.svg?width=890&button=false")](https://github.com/opal/opal/graphs/contributors)


## Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/opal#backer)]

<a href="https://opencollective.com/opal#backers" target="_blank"><img src="https://opencollective.com/opal/backers.svg?width=890"></a>


## Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. [[Become a sponsor](https://opencollective.com/opal#sponsor)]

<a href="https://opencollective.com/opal/sponsor/0/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/0/avatar.svg"></a>
<a href="https://opencollective.com/opal/sponsor/1/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/1/avatar.svg"></a>
<a href="https://opencollective.com/opal/sponsor/2/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/2/avatar.svg"></a>
<a href="https://opencollective.com/opal/sponsor/3/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/3/avatar.svg"></a>
<a href="https://opencollective.com/opal/sponsor/4/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/4/avatar.svg"></a>
<a href="https://opencollective.com/opal/sponsor/5/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/5/avatar.svg"></a>
<a href="https://opencollective.com/opal/sponsor/6/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/6/avatar.svg"></a>
<a href="https://opencollective.com/opal/sponsor/7/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/7/avatar.svg"></a>
<a href="https://opencollective.com/opal/sponsor/8/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/8/avatar.svg"></a>
<a href="https://opencollective.com/opal/sponsor/9/website" target="_blank"><img src="https://opencollective.com/opal/sponsor/9/avatar.svg"></a>


## License

(The MIT License)

Copyright (C) 2013-2019 by Adam Beynon and the Opal contributors

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


[MSpec]: https://github.com/ruby/mspec#readme
[RSpec]: https://github.com/rspec/rspec#readme
