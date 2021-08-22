# Using Opal with Roda and Sprockets

Add Opal-Sprockets and Roda-Sprockets to your Gemfile (or install using `gem`):

```ruby
# Gemfile
gem "opal-sprockets"
gem "roda-sprockets"
gem "puma"
```

Roda-Sprockets uses `sprockets` as its default build system, so the asset-pipeline
from rails can be mimicked here to map all ruby assets in the `/assets`
path to be compiled using opal.

## Basic Application

```ruby
# config.ru
require 'roda'

class App < Roda
   plugin :sprockets, precompile: %w(application.js),
                      prefix: %w(app/),
                      opal: true,
                      debug: ENV['RACK_ENV'] != 'production'
   plugin :public

   route do |r|
     r.public
     r.sprockets

     r.root do
       <<~END
         <!doctype html>
         <html>
           <head>
             #{ javascript_tag 'application' }
             #{ opal_require 'application' }
           </head>
         </html>
       END
     end
   end     
end

run App.app

```

This creates a sprockets instance under the `/assets` path, serving Opal assets
from `app/` with all the custom opal paths added automatically.

This `env` object includes all the opal corelib and stdlib paths. To add
any custom application directories, you must add them to the load path using
`Opal.append_path` or adding them to the `prefix` parameter. You can now add
an `app/application.rb` file into this added path with some basic content:

```ruby
# app/application.rb
require 'opal'

puts "wow, running ruby!"
```

It is necessary to require the opal corelib (seen in the `require` call) above.
This just makes the Opal runtime and corelib available. Then it is possible to
use all the corelib methods and classes, e.g. `Kernel#puts` as seen above.

### Running Application

As this is just a simple Roda application, you can run it:

```sh
$ bundle exec rackup
```

And point your browser towards `http://localhost:9292/` and view the browser
debug console. You should see this message printed.

### Extending the integration

It's possible to extend this integration, for that please look into the
[roda-sprockets documentation](https://github.com/hmdne/roda-sprockets)
