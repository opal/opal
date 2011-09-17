rbp: Ruby Package (manager)
===========================

rbp is distributed as part of opal, but it is aimed to move it out and
make it a more generic library that is useful for package management.
rbp is an alternative to rubygems in that it is not required at runtime
as all packages (similar to gems) are stored locally to the root package
to also aid in deployment.

The basic idea
--------------

In your app directory there will be a vendor folder where each
dependancy is stored in its own directory by name. For example:

```
app/
 |-bin/
 |-lib/
 |-vendor/
    |-setup.rb
    |-rake/
    |-otest/
```

Installing or removing (or updating) packages will be done through the
`rbp` command, which is simply a ruby library. rbp is only needed during
development - not production. Of course, the vendor directory should be
added to `.gitignore` (or similar).

setup.rb
--------

`setup.rb` in the vendor directory is where all the magic happens. As
packages are added or removed, their load paths are registered inside
setup.rb automatically by rbp, so when your package code runs, all the
relevant load paths are setup so you can just require() away. Your
packages own load path is also added to this file, so simply requiring
this file will add your library to the load path as well.

Local development
-----------------

To run your code, setup.rb needs to be called, so an example Rakefile
may look like the following:

```ruby
require File.expand_path('../vendor/setup.rb')
require 'your_lib_name'
```

When your lib requires its dependencies they will already be on the load
path thanks to setup.rb.

Listing dependencies and package.yml
------------------------------------

An apps dependencies are listed in its package.yml file, which is in the
base directory. It is based off/inspired by commonjs' package.json. rbp
doesn't use gemspecs because it aims to be a replacement/alternative to
rubygems.

Dependencies are listed as a hash in the package.yml file and it can
list either their required version numbers or a git url. Only git urls
are currently supported as there is no centeral server for distributing
packages. Alternatively, rbp could just use rubygems as a host and
download gems and convert them into packages as required (just extract
them).

Example setup.rb
----------------

```ruby
# your packages' path
path = File.expand_path('..', __FILE__)

# your packages' lib
$:.unshift File.expand_path("#{path}/../lib")

# dependency 1: `otest'
$:.unshift File.expand_path("#{path}/../vendor/otest/lib")

# dependency 2: `rake'
$:.unshift File.expand_path("#{path}/../vendor/rake/lib")
```

Installing packages globally
----------------------------

Obviously some people want to install packages globally. This is still
work in progress. The basic idea will be that they will be stored in
~/.rbp, or similar, but these will not be in the ruby load path. Either
we can then symlink these global packages into the local vendor/
directory, or we can add some clever addition to setup.rb that adds
`~/.rbp/packages/some_package/lib` into the load path. Obviously rbp can
check if the package is installed and available.

Global packages must be supported for things like rails which install
bin files. The bin files could be replaced with wrappers that will setup
the load paths before the true bin file is actually run. Afterall,
vendor/setup.rb will **not** be present at runtime.

