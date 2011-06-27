# Running in the browser

Opal is primarily aimed at running in the browser. Opal works as a source to source compiler which compiles the ruby code into fast javascript that relies on the opal runtime to provide some core language features.

For development, the ruby compiler and parser for opal can be compiled into javascript as well, so they can run in the browser to load from `<script>` tags and dynamically eval ruby code. In production, this is slow, so the opal build tools are used to precompile your ruby code into javascript, which can then be minified (and gzipped) so it is ready to run on the target device.

### opal.js

The main js file distributed as part of opal is `opal.js` which includes the core runtime features as well as all the core libraries (Array, String, Hash etc) which are readily available for use. This currently measures 52kb once minified (~10 kb gzipped).

### opal-parser.js

This file contains all the dev tools, that are written in ruby, and compiled down to js. This relies on the core opal.js runtime file, so should be loaded afterwards. These tools will automatically scan all the `<script>` tags in your html page and parse/run any ruby tags once found.

## Running ruby code

Opal maintains the concept of files so that libs and their dependencies can be loaded in order, using `Kernel#require`. The opal js library exposes some public APIs allowing generated code to "register" itself, so it can be loaded. When running in the browser, opal has a fake file system allowing files to be stored as relative paths allowing common require idioms to replicate those of running code on the command line. Furthermore, opal tries to maintain support for gems running in the browser, and the `Bundle` class in the build tools can take a `.gemspec` and build a single javascript file which will go through and register all listed lib files (and optionally test_files) with opal ready for running.
