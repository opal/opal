---
title: Libraries
---

# Using external libraries in your opal app

As described in the getting started docs, opal uses a load path which works
with sprockets to create a set of locations which opal can require files
from. If you want to add a directory to this load path, you can add it to
either the global environment, or a sprockets instance.

### Global Environment

In the `Opal` module, a property `paths` is used to hold the load paths which
`Opal` uses to require files from. You can add a directory to this:

```ruby
Opal.append_path '../my_lib'
```

Now, any ruby files in this directory can be discovered.

### Sprockets instances

`Opal::Environment` is a subclass of the sprockets environment class which
can have instance specific paths added to it. This class will inherit all
global paths, but you can also add your instance paths as:

```ruby
env = Opal::Environment.new
env.append_path '../my_lib'
```

## with Opal::Builder

_WIP_

## With opal-sprockets

_WIP_
