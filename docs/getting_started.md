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


