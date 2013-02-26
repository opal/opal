## 0.3.41 2012-02-26

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
