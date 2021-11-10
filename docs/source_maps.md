# Source maps

Source maps are available on most environments we support.

#### Processor `source_map_enabled` flag
To enable sourcemaps in the Sprockets processor you need to turn on the relative flag:

```ruby
Opal::Config.source_map_enabled = true # default
```


#### Sprockets debug mode

The source maps only work with Sprockets in debug mode - this is a limitation of Sprockets.

## Enable source maps

### Rails

Rails has debug mode already enabled in development environment with the following line from `config/environments/development.rb`:

```ruby
# Debug mode disables concatenation and preprocessing of assets.
# This option may cause significant delays in view rendering with a large
# number of complex assets.
config.assets.debug = true
```

`opal-rails` also enables sourcemaps in development so with the standard setup you ready to go.


### Sinatra

You can add `Opal::Server` as in the official example: [sinatra/config.ru](https://github.com/opal/opal/blob/master/examples/sinatra/config.ru).

### Opal::Server

`Opal::Server` (which is based on Sprockets) implements sourcemaps and can be used alone or with `Rack::Cascade` in conjunction with other apps.

### Opal::SimpleServer

Like `Opal::Server`, `Opal::SimpleServer` (which isn't based on Sprockets) implements sourcemaps properly.

### Opal::Builder

`Opal::Builder` is a bit lower level and doesn't support source maps by itself. It requires you to call in a specific method to generate them yourself.

