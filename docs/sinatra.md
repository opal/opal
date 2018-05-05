# Using Opal with Sinatra

Add Opal-Sprockets to your Gemfile (or install using `gem`):

```ruby
# Gemfile
gem 'sinatra'
gem 'opal-sprockets'
```

Opal-Sprockets uses `sprockets` as its default build system, so the asset-pipeline
from rails can be mimicked here to map all ruby assets in the `/assets`
path to be compiled using opal.

## Basic Application

```ruby
# config.ru
require 'opal-sprockets'
require 'sinatra'

opal = Opal::Sprockets::Server.new {|s|
  s.append_path 'app'
  s.main = 'application'
}

maps_prefix = Opal::Sprockets::Server::SOURCE_MAPS_PREFIX_PATH
maps_app = Opal::SourceMapServer.new(opal.sprockets, maps_prefix)

map maps_prefix do
  use Rack::ConditionalGet
  use Rack::ETag
  run maps_app
end

map '/assets' do
  run opal.sprockets
end

get '/' do
  <<-HTML
    <!doctype html>
    <html>
      <head>
        <script src="/assets/opal.js"></script>
        <script src="/assets/application.self.js"></script>
        <script type="text/javascript">Opal.load("application")</script>
      </head>
    </html>
  HTML
end

run Sinatra::Application
```

This creates a simple sprockets instance under the `/assets` path. Opal
uses a set of load paths to compile assets using sprockets. The
`Opal::Environment` instance is a simple subclass of `Sprockets::Environment`
with all the custom opal paths added automatically.

This `env` object includes all the opal corelib and stdlib paths. To add
any custom application directories, you must add them to the load path using
`env.append_path`. You can now add an `app/application.rb` file into this
added path with some basic content:

```ruby
# app/application.rb
require 'opal'

puts "wow, running ruby!"
```

It is necessary to require the opal corelib (seen in the `require` call) above.
This just makes the Opal runtime and corelib available. Then it is possible to
use all the corelib methods and classes, e.g. `Kernel#puts` as seen above.

### Running Application

As this is just a simple sinatra application, you can run it:

```sh
$ bundle exec rackup
```

And point your browser towards `http://localhost:9292/` and view the browser
debug console. You should see this message printed.
