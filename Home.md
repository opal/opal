Opal is a ruby runtime build to run on top of Javascript.

Opal aims to implement as many features of ruby as possible, as long as they can be implemented efficiently. Opal currently runs in the browser and on the command line using `therubyracer`. Node.js support is partially implemented but is only useful for experimental purposes.

## Working features

* `method_missing` support built in
* full operator overloading (`+`, `-`, `[]`, `[]=`, `==` etc)
* toll free bridges to javascript objects (Array, String, Number etc)
* use inline javascript within ruby sources (using back ticks)
* parser runs in browser to load `<script type="text/ruby">` sources
* generated code is clean and maintains correct line numbers and indentation
* `super`, `block_given?`, `yield`, lambda, singletons, etc...

## Missing features and incompatibilities

* single Numeric class instead of Integer/Fixnum/Float etc
* strings are immutable
* `method_missing` does not work for strings, arrays and numerics

## Optional features

* argument count checking - raise errors when wrong number of args given
* compiler warnings when inefficient javascript will have to be generated
