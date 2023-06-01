# Getting Started

Opal is a Ruby to JavaScript compiler, an implementation of the Ruby corelib and stdlib, and associated gems for building fast client-side web applications in Ruby.

## Installation

Opal is available as a gem and can be installed via:

```
$ gem install opal
```

Or added to your Gemfile as:

```ruby
gem 'opal'
```

## Getting Started with Opal

At its core, Opal provides a simple method of compiling a string of Ruby into JavaScript that can run on top of the Opal runtime:

```ruby
Opal.compile("[1, 2, 3].each { |a| puts a }")
# => "(function() { ... })()"
```

Opal allows for Ruby (and ERB) assets to be compiled and treated as first-class JavaScript citizens. Ruby sources can require JavaScript and other Ruby files, working similar to CoffeeScript.

This relies on the Opal load path. Any gem containing Opal code registers that directory to the Opal load path. Opal will then use all Opal load paths when running instances.

### Adding Lookup Paths

Opal uses a load path to create a set of locations from which Opal can require files. If you want to add a directory to this load path, you can add it to the global environment.

In the `Opal` module, a property `paths` is used to hold the load paths which `Opal` uses to require files from. You can add a directory to this:

```ruby
Opal.append_path '../my_lib'
```

Now, any Ruby files in this directory can be discovered.

## FAQ

### Why Does Opal Exist?

Opal aims to keep Ruby relevant in a world where client-side applications are making JavaScript the primary development platform.

### How Compatible is Opal?

Opal is tested against the [Ruby spec](https://github.com/ruby/spec) as our primary testing setup. The goal is to make Opal as compatible as possible while also considering the restrictions of JavaScript when applicable. Opal supports the majority of Ruby syntax features, as well as a very large part of the corelib implementation. Opal can compile and run RSpec unmodified, as well as self-host the compiler at runtime.

### What Version of Ruby Does Opal Target?

Opal's tests are run under Ruby 3.2.0 conditions, but it remains mostly compatible with 2.6 level features.

### Why Doesn't Opal Support Mutable Strings?

All strings in Opal are immutable because Ruby strings are compiled directly into JavaScript strings, which are immutable. Wrapping Ruby strings as a custom JavaScript object would add a lot of overhead and complicate interaction between Ruby and JavaScript libraries.
