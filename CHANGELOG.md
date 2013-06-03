## edge

*   Added native #[]= and #to_h methods, for setting properties and
    converting to a hash respectivaly.

*   Fix bug where '::' was parsed as :colon2 instead of :colon3 when in
    an args scope. Fixes #213

*   Remove lots of properties added to opal classes. This makes normal
    js constructors a lot closer to opal classes, making is easier to
    treat js classes as opal classes.

## 0.3.44 2013-05-31

*   Cleanup runtime, and remove various flags and functions from opal
    objects and classes (moving them to runtime methods).

*   Remove some activesupport methods into external lib.

*   Add/fix lots of String methods, with specs.

*   Add more methods to MatchData class.

*   Implement $' and $` variables.

*   Opal can now call methods on all native objects, via method missing
    dispatcher.

*   Add Opal::Environment as custom sprockets subclass which adds all
    opal load paths automatically.

## 0.3.43 2013-05-02

*   Stop inlining respond_to? inside the parser. This now fully respects
    an object overriding respond_to?.

*   Expose `Opal.eval()` function when parser is loaded for parsing
    and running strings of ruby code.

*   Add erb to corelib (as well as compiler to gem lib). ERB files with
    .opalerb extension will automatically be compiled into Template
    constant.

*   Added some examples into examples/ dir.

*   Add Opal.send() javascript function for sending methods to ruby
    objects.

*   Native class for wrapping and interacting with native objects and
    function calls.

*   Add local_storage to stdlib as a basic wrapper around localStorage.

*   Make method_missing more performant by reusing same dispatch function
    instead of reallocating one for each run.

*   Fix Kernel#format to work in firefox. String.prototype.replace() had
    different semantics for empty matching groups which was breaking
    Kernel#format.

## 0.3.42 2013-03-21

*   Fix/add lots of language specs.

*   Seperate sprockets support out to opal-sprockets gem.

*   Support %r[foo] style regexps.

*   Use mspec to run specs on corelib and runtime. Rubyspecs are now
    used, where possible to be as compliant as possible.

## 0.3.41 2013-02-26

*   Remove bin/opal - no longer required for building sources.

*   Depreceate Opal::Environment. The Opal::Server class provides a better
    method of using the opal load paths. Opal.paths still stores a list of
    load paths for generic sprockets based apps to use.

## 0.3.40 2013-02-23

*   Add Opal::Server as an easy to configure rack server for testing and
    running Opal based apps.

*   Added optional arity check mode for parser. When turned on, every method
    will have code which checks the argument arity. Off by default.

*   Exception subclasses now relfect their name in webkit/firefox debuggers
    to show both their class name and message.

*   Add Class#const_set. Trying to access undefined constants by a literal
    constant will now also raise a NameError.

## 0.3.39 2013-02-20

*   Fix bug where methods defined on a parent class after subclass was defined
    would not given subclass access to method. Subclasses are now also tracked
    by superclass, by a private '_inherited' property.

*   Fix bug where classes defined by `Class.new` did not have a constant scope.

*   Move Date out of opal.rb loading, as it is part of stdlib not corelib.

*   Fix for defining methods inside metaclass, or singleton_class scopes.

## 0.3.38 2013-02-13

*   Add Native module used for wrapping objects to forward calls as native
    calls.

*   Support method_missing for all objects. Feature can be enabled/disabled on
    Opal::Processor.

*   Hash can now use any ruby object as a key.

*   Move to Sprockets based building via `Opal::Processor`.
