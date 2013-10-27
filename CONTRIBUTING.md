# Contributing

This is the issue tracker for Opal. If you have a more general question about
using opal (or related libraries) then use the
[google group for opal](http://groups.google.com/forum/#!forum/opalrb), or the
[#opal](http://webchat.freenode.net/?channels=opal) irc channel on
FreeNode.

## Contributing

* Before opening a new issue, search for previous discussions including closed
ones. At comments there if a similar issue is found.

* Before sending pull requests make sure all tests run and pass (see below).

* Make sure to use a similar coding style to the rest of the code base. In ruby
and javascript code we use 2 spaces (no tabs).

## Quick Start

Clone repo:

```
$ git clone git://github.com/opal/opal.git
```

Get dependencies:

```
$ bundle
```

## Running Tests

### Runtime

Some opal specific tests are found inside `spec/`, but the majority of our
runtime tests now come from rubyspec. Rubyspec is included as a git submodule.
To get our latest referenced checkout, just run:

```
$ git submodule update --init
```

You need phantomjs installed to run tests. To build opal, its dependencies
and all specs, run:

```
$ bundle exec rake mspec
```

You can alternatively run tests in a browser using:

```
$ rackup
```

And then opening `http://127.0.0.1:9292` in a web browser.

### Gem/lib tests

We also include some tests for running under your standard ruby implementation
which are in `mri_spec/`. To run tests tests using rake, use:

```
$ bundle exec rake mri_spec
```

### All tests

To run all the tests together (which you should do while contributing), run:

```
$ bundle exec rake
```

