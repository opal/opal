# Contributing

This is the issue tracker for Opal. If you have a more general question about
using opal (or related libraries) then use the
[google group for opal](http://groups.google.com/forum/#!forum/opalrb), or the
[#opal](http://webchat.freenode.net/?channels=opal) irc channel on
FreeNode.

## Contributing

1. Before opening a new issue, search for previous discussions including closed
ones. Add comments there if a similar issue is found.

2. Please report the version on which the issue is found.

3. Before sending pull requests make sure all tests run and pass (see below).

4. Make sure to use a similar coding style to the rest of the code base. In ruby
and javascript code we use 2 spaces (no tabs).

## Quick Start

Clone repo:

```
$ git clone git://github.com/opal/opal.git
```

Get dependencies:

```
$ bundle install
```

RubySpec related repos must be cloned as a git submodules:

```
$ git submodule update --init
```

Run the test suite:

```
$ bundle exec rake
```

You are now ready to make your first contribution to Opal! At a high level, your workflow will be to:

1. Make changes to Opal source code
2. Run the test suite to make sure it still passes
3. Submit a pull request

## Down The Rabbit Hole

Before making changes to Opal source, you need to understand a little about how the test suite works. Every spec that Opal test suite executes is listed in `spec/rubyspecs` file. Each line in that file is a path to either a spec file or a directory full of spec files. If it's a path to a directory, all spec files in that directory will be executed when you run the test suite. All paths are relative to the top-level `specs` directory. Let's follow one of these paths - `corelib/core/string/sub_spec` - and see where it goes.

Navigating to `spec/corelib/core` directory, you see that it contains multiple sub-directories, usually named after the Ruby class or module. Drilling further down into `spec/corelib/core/string` you see all the spec files for the various `String` behaviors under test, usually named by a method name followed by `_spec.rb`. Opening `spec/corelib/core/string/sub_spec.rb` you finally see the code that checks the correctness of Opal's implementation of `String#sub` method's behavior.

When you execute `$ bundle exec rake`, the code in this file is executed, along with all the other specs in the entire test suite. It's a good idea to run the entire test suite when you feel you reached a certain milestone in the course of making your changes (exactly what that means is up to you), and definitely do `$ bundle exec rake` before commiting your changes to make sure they have not introduced regressions or other unintended side effects.

But you will want to run tests as often as possible, after every small change, and running the entire test suite will slow you down. You need to be able to execute a single spec that is concerned with the feature you are currently working on. To accomplish this, just add `PATTERN` to your spec invocation command, like this:
```
$ bundle exec rake mspec_node PATTERN=spec/corelib/core/string/sub_spec.rb
```
This will make sure that only `spec/corelib/core/string/sub_spec.rb` is run, and no other specs are executed.

Let's recap what we covered so far. `spec/rubyspecs` is the "master list" of all the specs that get executed when you do `$ bundle exec rake`. You know where to find individual specs, inspect them, and execute them selectively or in bulk. But how do you know which specs to work on? You may be tempted to compare the contents of one of the directories in `spec/corelib/core` with the list of paths in `spec/rubyspecs`, add the missing paths to the "master list", run `$ bundle exec rake`, and start fixing the failures by implementing the missing features. However, chances are that as you are reading this, there are plenty of failing tests in the specs that are already listed in `spec/rubyspecs`. How can that be if `$ bundle exec rake` runs green? To understand this, you need to get acquainted with the concept of spec filters.

There are two types of spec filters in the Opal project: `spec/filters/bugs` and `spec/filters/unsupported`. Both filters have the same effect: any spec failures that are noted inside any of the files inside of these directories are ignored when running the spec suite, i.e. they are not reported as failures. Even though their effect is the same, the purpose of `bugs` and `unsupported` filters is different. As the name suggests, `unsupported` filters list _permanent_ failures, things that other Ruby implementations can do that Opal cannot and will never be able to do (by design and by virtue of being implemented on top of JavaScript running in the browser environment). `bugs` filters, on the other hand, are _temporary_ failures, problems that need to be worked on. Problems that Opal needs your help with. Think of the `bugs` directory and the files contained within it as your "TO DO" list for contributing to Opal.

Comment out any of the `fail` lines in any of the files in the `spec/filters/bugs` directory, run `$bundle exec rake`, and watch it fail. Make it pass and submit a pull request - that's all there is to it :) Happy hacking!
