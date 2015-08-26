# Opal & Sprockets

Opal comes with built-in sprockets support, and provides a simple `Opal::Server`
class to make it easy to get a rack server up and running for trying out opal.
This server will automatically recompile ruby sources when they change, meaning
you just need to refresh your page to autorun.

## Getting setup

Add `opal` to a `Gemfile`:

```ruby
#Gemfile
source 'https://rubygems.org'

gem 'opal', '>= 0.6.0'
```

And install with `bundle install`.

We need a directory to hold our opal code, so create `app/` and add a simple
demo script to `app/application.rb`:

```ruby
# app/application.rb
require 'opal'

puts "hello world"
```

Finally, we need a html page to run, so create `index.html`:

```html
<!DOCTYPE html>
<html>
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

  s.index_path = 'index.html'
}
```

This rack app simply adds our `app/` directory to opal load path, and sets our
main file to `application`, which will be found inside `app/`.

## Running the app

Run `bundle exec rackup` and visit the page `http://localhost:9292` in any
browser. Observe the console to see the printed statement.

You can just change `app/application.rb` and refresh the page to see any changes.
