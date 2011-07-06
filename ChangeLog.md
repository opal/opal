Changelog
=========

**Edge**

* Full method\_missing support for all classes
* Use $m\_tbl to keep bridged classes clean
* Add private and public method support
* Debug mode to check for argument count errors and stack traces

**27 June 2011**: 0.3.5 Release

* Added method\_missing support
* Fixed various parts of runtime to allow parser to self compile
* Parser runs standalone in browser to run `<script>` tags
* Implemented basic IO classes to allow reassignment of stdin, stdout.
* Lots of fixes, additions and improvements to core library

**31 March 2011**: 0.3.2 Release

* Added BuilderTask for easy building for simple projects.
* Amended build options in Builder to support new rake task.

**30 March 2011**: 0.3.1 Release

* Fix to make `opal` an executable

**30 March 2011**: 0.3.0 Release

* Major redesign of build tools to use v8 for server side opal
* Split all opal packages into actual gems
* File and Dir classes for both browser and v8 gem runtimes

