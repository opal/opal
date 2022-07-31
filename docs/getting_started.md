# Getting Started

Opal is a ruby to javascript compiler, an implementation of the ruby corelib and stdlib, and associated gems for building fast client side web applications in ruby.

## Installation

Opal is available as a gem, and can be installed via:

```
$ gem install opal
```

Or added to your Gemfile as:

```ruby
gem 'opal'
```

## Getting started with Opal

At its very core, opal provides a simple method of compiling a string of ruby into javascript that can run on top of the opal runtime, provided by `opal.js`:

```ruby
Opal.compile("[1, 2, 3].each { |a| puts a }")
# => "(function() { ... })()"
```

`opal` includes sprockets support for compiling Ruby (and ERB) assets, and treating them as first class JavaScript citizens. It works in a similar way to CoffeeScript, where JavaScript files can simply require Ruby sources, and Ruby sources can require JavaScript and other Ruby files.

This relies on the Opal load path. Any gem containing opal code registers that directory to the Opal load path. Opal will then use all Opal load paths when running sprockets instances. For rails applications, `opal-rails` does this automatically. For building a simple application, we have to do this manually.


### Adding lookup paths

Opal uses a load path which works with sprockets to create a set of locations which opal can require files
from. If you want to add a directory to this load path, you can add it to the global environment.

In the `Opal` module, a property `paths` is used to hold the load paths which
`Opal` uses to require files from. You can add a directory to this:

```ruby
Opal.append_path '../my_lib'
```

Now, any ruby files in this directory can be discovered.


## FAQ

### Why does Opal exist?

To try and keep ruby relevant in a world where client-side applications are making javascript the primary development platform.

### How compatible is Opal?

We run opal against the [ruby spec](https://github.com/ruby/spec) as our primary testing setup. We try to make Opal as compatible as possible, whilst also taking into account restrictions of JavaScript when applicable. Opal supports the majority of ruby syntax features, as well as a very large part of the corelib implementation. We support method\_missing, modules, classes, instance\_exec, blocks, procs and lots lots more. Opal can compile and run RSpec unmodified, as well as self hosting the compiler at runtime.

### What version of ruby does Opal target?

We are running tests under ruby 3.0.0 conditions, but are mostly compatible with 2.6 level features.

### Why doesn't Opal support mutable strings?

All strings in Opal are immutable because ruby strings just get compiled directly into javascript strings, which are immutable. Wrapping ruby strings as a custom JavaScript object would add a lot of overhead as well as making interaction between ruby and javascript libraries more difficult.
