Opal
====

Opal is a ruby runtime for javascript and includes a ruby to javascript
source-to-source compiler. The core libraries are written in ruby.

**Homepage**:      [http://opalscript.org](http://opalscript.org)
**Github**:
[http://github.com/adambeynon/opal](http://github.com/adambeynon/opal)

See homepage for examples etc.

Installation
------------

Ruby is distributed as a gem, so install with:

    $ gem install opal

Usage
-----

Opal has a built in REPL that uses `therubyracer` to hold a built in
context. Try the REPL with:

    $ opal irb

### Using in the browser

Ruby code needs to be compiled into javascript before running in the
browser. The easiest way is through a rake task:

```ruby
require "opal/bundle_task"

Opal::BundleTask.new do |t|
  t.name    = "my_project"
  t.version = "0.0.1"
end
```

Then run `rake bundle`. See [the bundle
guide](http://adambeynon.github.com/opal/docs/bundle.html) for more
information.

Project structure
-----------------

This repo contains the code for the opal gem as well as the opal core
library and runtime. Files inside `bin/` and `lib/` are the files that
are used as part of the gem and run directly on your ruby environment.

`corelib/` contains opal's core library implementation and is not used
directly by the gem. These files are precompiled during development
ready to be used in the gem or in a browser.

`runtime/` contains opal's runtime written in javascript. It is not used
directly by the gem, but is built ready to use in the js contexts that
opal runs.

`stdlib/` contains the stdlib files that opal comes packaged with. The
gem does use these, but only as required. Opal does not include the full
opal stdlib, and some parts are actually written in javascript for
optimal performance. These can be `require()` at runtime.

`opal.js` and `opal-parser.js` are included in the gem, but not the
source repo. They are the latest built versions of opal and its parser
which are built before the gem is published.

