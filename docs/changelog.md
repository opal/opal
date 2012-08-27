# Change Log

**0.3.21** _(16 July 2012)_

* Add `method_missing` support to all objects and classes
* Add `Opal.build_gem()` method to quickly build installed gem
* Add `Opal.build_files()` method to build directories of files

**0.3.20** _(23 June 2012)_

* Merge JSON into core. JSON module and various #to_json methods are
  now included as part of corelib
* Make `Time` class bridge to native `Date` constructor
* Use named functions as class constuctors to make debugging easier
* Classes are now real functions with prototypes. Bridged classes are
  now directly corresponding to the ruby class (e.g. Array === Opal.Array)
* Set ivars used inside methods in class to `nil` inside class definition
  to avoid doing it everytime method is called
* Add debug comments to output for def, class and module stating the file
  and line number the given code was generated from

**0.3.19** _(30 May 2012)_

* Add BasicObject as the root class
* Add `Opal.define` and `Opal.require` for requiring files
* Builder uses a `main` option to dictate which file to require on load
* Completely revamp runtime to reduce helper methods
* Allow native bridges (Array, String, etc) to be subclassed
* Make sure `.js` files can be built with `Opal::Builder`
* Include the current file name when raising parse errors

**0.3.18** _(20 May 2012)_

* Fix various core lib bugs
* Completely remove `require` from corelib
* Improve Builder to detect dependencies in files

**0.3.17** _(19 May 2012)_

* Revamp of Builder and Parser tools
* Remove opal-repl
* Added a lot of specs for core lib

**0.3.16** _(15 January 2012)_

* Added HEREDOCS support in parser
* Parser now handles masgn (mass/multi assignments)
* More useful DependencyBuilder class to build gems dependencies
* Blocks no longer passed as an argument in method calls

**0.3.15**

* Initial Release.