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

`opal` includes sprockets support to sprockets for compiling ruby (and erb) assets, and treating them as first class javascript citizens. It works in a similar way to coffeescript, where javascript files can simply require ruby sources, and ruby sources can require javascript and other ruby files.

This relies on the opal load path. Any gem containing opal code registers that directory to the opal load path. opal will then use all opal load paths when running sprockets instances. For rails applications, opal-rails does this automatically. For building a simple application, we have to do this manually.
