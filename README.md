Opal: Ruby runtime for javascript
=================================

**Homepage**:      [http://opalscript.org](http://opalscript.org)  
**Github**:        [http://github.com/adambeynon/opal](http://github.com/adambeynon/opal)  

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

Alternativley you can clone the build tools repo with:

    $ git clone git://github.com/adambeynon/opalite.git

Note that this repo does not contain the ruby build tools. The build
tools can be found at [http://github.com/adambeynon/opalite](http://github.com/adambeynon/opalite)

Usage
-----

Opal can be used within in the browser, or on the command line using the
build tools. A Nodejs environment is also partially implemented.

To run within the browser, you can either use the latest build version
on the opal website, or clone the build tools as above, and then run the
following task in that directory:

    $ rake opal_js

This will place a non minified version ready to run within the browser
into `extras/opal.js`

Examples
--------

Examples can be found in the `examples/` directory in this repo, and
rely on `extras/opal.js` being created using the above commands.

