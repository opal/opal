`opal-sprockets` provides a simple `Opal::Server` class to make it easy to get a rack server up and running for trying out opal. This server will automatically recompile ruby sources when they change, meaning you just need to refresh your page to autorun.

## Getting setup

Add `opal` and `opal-sprockets` to a `Gemfile`:

```ruby
#Gemfile
source 'https://rubygems.org'

gem 'opal', '>= 0.4.3'
gem 'opal-sprockets'
```

And install with `bundle install`.

We need a directory to hold our opal code, so create `app/` and add a simple demo script to `app/application.rb`:

```ruby
# app/application.rb

require 'opal'

puts "hello world"
```

Finally, we need a html page to run, so create `index.html`:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>opal server example</title>
  <script src="/assets/application.js"></script>
</head>
<body>
</body>
</html>
```

## Using Opal::Server

`Opal::Server` can be run like any rack app, so just add a `config.ru` file:

```ruby
# config.ru

require 'bundler'
Bundler.require

run Opal::Server.new { |s|
  s.append_path 'app'

  s.main = 'application'
}
```

This rack app simply adds our `app/` directory to opal load path, and sets our main file to `application`, which will be found inside `app/`.
Other options are:

* use_index: tell opal to serve a default index page, turn off if you want to use your own index page (for example served by your sinatra app) (default on)
* public_dir: default directory where opal-sprockets looks for files to serve (default '.')
* source_map: enable source_map server (default on)

## Running the app

Run `bundle exec rackup` and visit the page `http://127.0.0.1:9292` in any browser. Observe the console to see the printed statement.

You can just change `app/application.rb` and refresh the page to see any changes.
