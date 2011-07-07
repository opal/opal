---
layout: main
title: "Opal: Ruby runtime for Javascript"
---

{{ page.title }}
=====

**Homepage**:      [http://opalscript.org](http://opalscript.org)  
**Github**:
[http://github.com/adambeynon/opal](http://github.com/adambeynon/opal)  

Overview
--------

Opal is a ruby runtime and standard library designed to run directly on
top of javascript. It can be run within a browser or on the command line
with the bundled tools. Opal include a parser/compiler written in ruby
that build ruby ahead of time directly into javascript that can run
alongside the bundled runtime.

{% highlight ruby %}
Document.ready do
  Document['a'].click do
    alert "Thanks for visiting.."
  end
end
{% endhighlight %}

Installation and Usage
----------------------

Opal is distributed as a gem that includes the ruby compiler and a set
of build tools used to compile the ruby code into javascript that runs
in all modern web browsers. To install ruby from rubygems:

    gem install opal

Once opal has been installed, the `opal` command is available for use.
The easiest way to get started is to open an opal REPL which acts like
the standard IRB shell. To run the REPL, use:

    opal irb

You can run commands in this REPL in the exact same way you can with
IRB. The REPL relies on `therubyracer` which embeds the v8 javascript
engine directly inside ruby. The REPL then takes your ruby commands,
parses and compiles them into javascript and runs them in the v8 context
which has the opal runtime loaded. The result is then printed back to
your console after having `#inspect` called on it.

Using in the Browser
--------------------

Opal is primarily meant to run in the browser. There are two core files
used for running opal in the browser. `opal.js` contains the ruby
runtime and core library files which is the minimal base needed for
running ruby code in any opal environment. Additionally,
`opal-parser.js` contains the ruby parser and compiler allowing ruby to
be dynamically loaded and evaluated directly inside the browser. The
parser is only required in development mode to ease compilation of ruby.
Only the ruby runtime is required for production code which is already
compiled.

**Latest version**:  0.3.6  
**Opal runtime**: [opal.js](js/opal.js)  
**Opal parser**: [opal-parser.js](js/opal-parser.js)  

Using the parser, ruby code will automatically be loaded from script
tags in a webpage. Scripts can either contain inline ruby code or
reference external files.

{% highlight html %}
<!doctype html>
<html>
<head>
  <title>Opal demo</title>
</head>
<body>
  <script src="opal.js"></script>
  <script src="opal-parser.js"></script>

  <script type="text/ruby">
    [1, 2, 3, 4].each { |a| puts a }
  </script>

</body>
</html>
{% endhighlight %}

Features
--------

### Toll free bridged to native objects

To make opal fast and efficient, the runtime makes use of native
javascript object whenever possible. Array, String, Number, Regexp and
more are all bridged to ruby objects so the runtime and external
libraries can just deal with native objects instead of casting between
the two environments.

Any native prototype can be toll free bridged to a ruby class using the
`Class#native_prototype` method which attaches all the necessary methods
and properties onto a native object. For example, to bridge javascript
arrays to instances of the Array class we use:

{% highlight ruby %}
class Array
  # bridge native arrays
  native_prototype `Array.prototype`
end
{% endhighlight %}

This uses the backtick feature outlined below and basically attaches the
releavant properties to the passed in prototype.

### Inline javascript

While opal aims to be as syntactically close to ruby as possible, one
change is that backticks are used to hold inline javascript inside ruby
code. Infact, most of the core library uses this method. Looking at the
source code of `Array#size` for instance, we have:

{% highlight ruby %}
def size
  `return self.length;`
end
{% endhighlight %}

This inline code simply looks at the arrays length property and returns
it. The entire core library is written in this style.

### Full method\_missing support

Method missing is a cruicial part of ruby and it is fully supported in
Opal. The opal compiler generates optimal javascript code to make method
calls as fast as possible and does not use a method dispatch function
which can cause large slow downs in runtime code.

### Public/Private methods

Opal fully supports public and private methods in the runtime. Protected
methods are not currently supported and `Module#protected` acts as a
noop. Method calls do not require a dispatch function so calling public
and private methods has no performance hit.

### And the rest..

* Full operator overloading support
* Generated code is clean and maintains line numbers
* Debug mode to provide clean stack tracers in all browsers
* super, metaclasses, block, yield, block\_given?, ranges etc..

Changelog
=========

**0.3.6**: 7 July 2011

* Private/public method support
* Method missing for ALL classes
* Debug mode to check for arg count errors and full stack traces

**0.3.5**: 27 June 2011

* Added method\_missing support
* Fixed various parts of runtime to allow parser to self compile
* Parser runs standalone in browser to run `<script>` tags
* Implemented basic IO classes to allow reassignment of stdin, stdout.
* Lots of fixes, additions and improvements to core library

