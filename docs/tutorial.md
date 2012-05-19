# Opal Tutorial

## Installation

Firstly, you need to install Opal. You can either install as a gem:

```
gem install opal
```

Or add it to a local Gemfile:

```ruby
gem "opal"
```

## Requirements

To run apps written in opal, you need the opal runtime. This can be
downloaded from [http://opalrb.org/opal.js](http://opalrb.org/opal.js).
Save this file as `opal.js`.

Next you need a HTML page to actually load the app. The following
template should be enough to get started:

```html
<!doctype html>
<html>
<head>
  <title>Test Opal App</title>
</head>
<body>
  <script src="opal.js"></script>
  <script src="app.js"></script>
</body>
</html>
```

You may notice the `app.js` file. This doesn't exist yet, but it
will contain the generated code for your app.

## Ruby code

To keep things clean, place the ruby code into a file called `app.rb`.
We will then compile this code into the `app.js` file ready to run
in the browser.

```ruby
# app.rb
puts "Hello World!"
```

## Compiling the app

To actually compile the app code, the easiest approach is to use a
rake task that uses the Opal lib. Create a Rakefile similar to the
following:

```ruby
# Rakefile

require 'opal'

desc "build app"
task :build do
  src = File.read 'app.rb'
  js  = Opal.parse src

  File.open('app.js', 'w+') do |o|
    o.write js
  end
end
```

This rake task simply reads the ruby code, compiles it and then writes
it into the destination file.

## Running the app

Simply open the HTML file `index.html` and observe the browser's
console. You should see the famous `"Hello World!"` message.