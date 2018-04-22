# Opal & Sprockets

The `opal-sprockets` gem adds sprockets support to Opal, providing a simple
`Opal::Sprockets::server` class to make it easy to get a rack server up and 
running for trying out opal. This server will automatically recompile ruby 
sources when they change, meaning you just need to refresh your page to autorun.

## Getting setup

Add `rack` & `opal-sprockets` to your `Gemfile`:

```ruby
#Gemfile
source 'https://rubygems.org'

gem 'rack'
gem 'opal-sprockets'
```

And install with `bundle install`.

We need a directory to hold our opal code, so create `app/` and add a simple
demo script to `app/application.rb`:

```ruby
# app/application.rb
require 'opal'

puts "hello world"
```


If we do not provide an HTML index, sprockets will generate one automatically; 
however, it is often useful to override the default with a custom `erb` file: 

```html
<%# index.erb %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>opal server example</title>
    <%= javascript_include_tag @server.main %>
  </head>
  <body>
    you've reached the custom index!
  </body>
</html>
```

## Using Opal::Server

`Opal::Server` can be run like any rack app, so just add a `config.ru` file:

```ruby
# config.ru
require 'opal-sprockets'

run Opal::Server.new { |s|
  s.append_path 'app'

  s.main = 'application'

  # override the default index with our custom index
  s.index_path = 'index.erb'
}
```

This rack app simply adds our `app/` directory to opal load path, and sets our
main file to `application`, which will be found inside `app/`.

## Running the app

Run `bundle exec rackup` and visit the page `http://localhost:9292` in any
browser. Observe the console to see the printed statement.

You can just change `app/application.rb` and refresh the page to see any changes.


## Using an existing `sprockets` instance

We only need to append Opal paths to the existing sprockets instance.

```ruby
require 'sprockets'
environment = Sprockets::Environment.new

require 'opal'
Opal.paths.each do |path|
  environment.append_path path
end
```
