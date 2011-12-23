Opal runtime
------------

This directory holds the opal runtime and corelib files.

### kernel

This is the very core runtime, written in javascript, that sets up the class/object heirarchy etc.

### corelib

This holds Opal's implementation of the ruby corelib, written in ruby with inline javascript.

### spec

Specs taken from RubySpec to test the runtime/corelib. This is not complete, but it contains tests
for parts of Opal that have been implemented.

### gemlib

Additional files used by opal when running on the command line (it gives opal proper file access).

### stdlib

The parts of the ruby standard library that are implemented for opal. This is very incomplete.
