Opal: Ruby runtime for javascript
=================================

**Homepage**:      [http://opalscript.org](http://opalscript.org)  
**Github**:        [http://github.com/adambeynon/opal](http://github.com/adambeynon/opal)  
**Documentation**: [http://adambeynon.github.com/opal/index.html](http://adambeynon.github.com/opal/index.html)  

Description
-----------

Opal is a ruby runtime and set of core libraries designed to run
directly on top of javascript. It supports the gem packaging system for
building ruby ready for the browser. It also uses therubyracer to
provide a command line REPL and environment for running ruby server-side
inside a javascript context.

Installation
------------

Opal is distributed as a gem, so install with:

    $ gem install opal

Alternativley, you may just clone this git repo. No building is
neccessary.

Usage
-----

The opal build tools can be used in three ways. As a simple repl, the
bundler tasks and the simple build tasks.

**1. opal Command-line tool**

In its current form, the `opal` executable is very simple - it provides
a simple ruby repl that uses therubyracer to provide an embedable
javascript context. If you have installed the gem, to run the REPL,
simply type:

    $ opal

or if you have cloned this repository, type:

    $ bin/opal

The REPL can be used like any other repl, and internally each command is
being compiled into javascript, and run in the context which opal is
already loaded into.

**2. Builder Rake Task**

To build simple ruby files (without a .gemspec) is to use the
BuilderTask class in a rake file. This can be done by adding the
following to a `Rakefile`:

    require 'opal'

    Opal::Rake::BuilderTask.new do |t|
      t.files   = 'ruby/**/*.rb'
      t.out     = 'js/ruby_code.js'
    end

When using the rake task, the `files` and `out` optional are usually
best required. The `files` will take an array, or a single string, and
can be globs. It is important to use relative paths here not absolute
paths. This will be default create a rake task called `opal` in your
rakefile, but you can rename it by passing another name into `new`. To
compile the javascript run:

    $ rake opal

The out file will now contain the compiled ruby code. Run this in a
browser by including it into a html document, but make sure to include
the latest `opal.js` file first.

**Main file**

By default the builder task will automatically load the first listed
file in the `files` array when the file is loaded in the browser. The
`main` option allows you to specify another file:

    Opal::Rake::BuilderTask.new do |t|
      t.files = ['ruby/file_1.rb', 'ruby/file_2.rb', 'ruby/file_3.rb']
      t.out   = 'out.js'
      t.main  = 'ruby/file_2.rb'
    end

**File watching**

To save manually compiling each time you change a file, the `watch`
option can be set to automatically recompile everytime a listed file is
modified. Observe the command line after using this task:

    Opal::Rake::BuilderTask.new do |t|
      t.files  = 'ruby/*.rb'
      t.out    = 'my_code.js'
      t.watch  = true
    end

**Examples**

See the `examples/` directory for runnable demos.

Built-in gems
------------

Opal uses gems as the main means of distributing and building code ready
for the browser. Opal uses its own gem system, and cannot access gems
included in the standard ruby installation. To aid this, the actual opal
gem includes several gems that offer the basic features. These gems are:

**core**

The core gem offers the ruby core library. It is mostly written in ruby,
but has a large proportion of inline javascript to make it as performant
as possible. Many of the classes are toll-free bridged to native
javascript objects, including Array, String, Numeric and Proc. Read the
[core library documentation](http://adambeynon.github.com/opal/gems/core/index.html)
for more information.

**dev**

The dev gem contains a ruby parser and compiler written in javascript.
It is a clone of the default opal parser written in ruby. This gem is in
the process of being replaced with the pure ruby version, which will be
compiled into javascript for this gem. This gem can be loaded into
javascript to allow in browser compilation of ruby sources from external
files or through html `script` tags.

**json**

The json gem included methods for parsing json strings and then
generating json objects from a string of json code. This gem aims to be
API compatible with the standard json library. Similarly to that
library, json objects are mapped to Hash, Array, true, false, nil,
String and Numeric as appropriate. See the
[JSON documentation](http://adambeynon.github.com/opal/gems/json/index.html)
for the full api.

**rquery**

RQuery is a port/abstraction of the jQuery javascript library for DOM
manipulation. jQuery is actually included as part of the gem, and top
level classes like Element, Document and Request are used to interact
with the document and elements. The api tries to stay as close to the
jquery interface as possible, but adds appropriate ruby syntax features
on top. See the [rquery documentation](http://adambeynon.github.com/opal/gems/rquery/index.html)
for the full api.

**ospec**

OSpec is a minimal clone of the ruby rspec library. It implements the
core features available in rspec, and works both from the command line
and in browser. The core, json and rquery gems all have tests/specs
written ready for ospec. See the [ospec guide](http://adambeynon.github.com/opal/gems/ospec/index.html)
to get started.

Browser version
---------------

**Latest version**:          0.3.2  
**Minified and gzipped**:    42kb  
**Download**:
[http://adambeynon.github.com/opal/opal.js](http://adambeynon.github.com/opal/opal.js)  

Opal is distributed ready for the browser in a single file `opal.js`.
This file contains the opal bootloader, the core library gem, the json
gem and the rquery gem. In addition to these, jquery is also included as
part of rquery. This self contained file is all that is needed to get
started with opal.

Using the `BuilderTask` as described above, running that file is as
simple as using the given html file:

    <!doctype html>
    <html>
      <head>
        <script src="path/to/opal.js"></script>
        <script src="ruby_code.js"></script>
      </head>
    </html>

Changelog
---------

- **31 March 2011**: 0.3.2 Release
    - Added BuilderTask for easy building for simple projects.
    - Amended build options in Builder to support new rake task.

- **30 March 2011**: 0.3.1 Release
    - Fix to make `opal` an executable

- **30 March 2011**: 0.3.0 Release
    - Major redesign of build tools to use v8 for server side opal
    - Split all opal packages into actual gems
    - File and Dir classes for both browser and v8 gem runtimes

