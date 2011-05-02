Browser demo
============

This directory contains a very simple browser demo. It is meant to be
run from within this repo, as it relies on the opal.js build being
located in its doc/opal.js location. To run this example manually, alter
the html file to include your local copy of `opal.js`.

Running the demo
----------------

There is a rake task `opal` in the bundled file, which will build the
`browser.rb` file to the needed `browser.js` file. The `Rakefile` is
setup to use the development version of opal, but to use the gem simply
comment out the first line. So, to build:

    $ rake opal

From there, open `index.html` in your browser of choice and view the
debug console to view the additional output.

