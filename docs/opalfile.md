# Adjusting Load Paths with Opalfile

The `Opalfile` plays a role in the configuration of Opal projects, particularly in adjusting and managing the load paths that are essential for the inclusion and execution of Ruby code in the Opal environment. This document outlines how to leverage `Opalfile` for customizing load paths and adding gem dependencies to streamline the development of Opal-based applications and libraries.

## Overview

An `Opalfile` is used to define a set of directives that influence how an Opal project is built and compiled. Among its capabilities, adjusting load paths is a fundamental feature, allowing developers to specify which directories or files should be accessible to the Opal compiler. This is essential for including project-specific libraries or dependencies.

`Opalfile` location is resolved whenever a file is compiled or a load path is added (either by `Opalfile` or in compilation process). The path is scanned for `Opalfile` - first directly, then its parent directories, the resolution is finished when `Opalfile` is located.

`Opalfile` can be used both inside a standalone project or inside a gem.

## Adjusting Load Paths

The load path adjustment in `Opalfile` is straightforward. By using the `add_load_path` directive, you can add directories to the load path, making them searchable by the Opal builder.

For standalone applications, there is no default load path specified, so one must be added either in the build process or inside `Opalfile` and it's recommended to use `Opalfile` for this case.

For gems, the default load paths are specified by the gem specification (by default: `lib`) if no `Opalfile` is present. There are many cases for which you would want to serve different directories, for instance some gems may have different implementations for frontend and backend code - in this case, it's customary to use `lib` and `lib-opal`. `Opalfile` provides a way to override the default gem dependencies and provide `lib-opal` and not `lib` to Opal, or whatever other setting you desire.

### Syntax

```ruby
add_load_path 'path/to/directory/relative/to/opalfile'
add_load_path '/absolute/path'
```

### Example

Consider you have a directory structure like this:

```
my_opal_project/
  |- lib/
  |    `- my_project
  |         `- version.rb
  |- src/
  `- vendor/
```

To include the `lib` and `vendor` directories in the load path, your `Opalfile` would look like this:

```ruby
add_load_path 'lib'
add_load_path 'vendor'
```

This ensures that the Opal compiler can find and include any Ruby file located within these directories. For instance, if you want to load the `version.rb` file, you would write `require "my_project/version"` and Opal will know where to find it.

## Adding Gem Dependencies

Beyond adjusting load paths, `Opalfile` allows for the inclusion of Ruby gem dependencies directly into your project. This is done using the `add_gem_dependency` directive, specifying the name of the gem to be included.

In the case of standalone applications, the default behavior of Opal is to not include any gems in Opal's load paths. If you want to use some external gem, you have to specify the gems in the build process or inside `Opalfile`.

In the case of gems, when `Opalfile` is not present in a gem, it will default to process the gem's dependencies (as defined in a `gemspec` file). If `Opalfile` is present, only the gems that are specified in `Opalfile` will be processed.

### Syntax

```ruby
add_gem_dependency 'gem_name'
```

### Example

To include the `opal-jquery` gem in your project, your `Opalfile` would include:

```ruby
add_gem_dependency 'opal-jquery'
```

This line tells Opal to include the `opal-jquery` gem, making its functionality available within your Opal project.

### Warning

Do note, that `Opalfile` does not replace `Gemfile` - if you use `Bundler` in your project, it's necessary to add `gem "opal-jquery"` to `Gemfile` (or `gemspec`) as well.
