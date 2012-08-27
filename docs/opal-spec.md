# opal-spec

opal-spec is a small rspec/mspec port for opal. It is used to test the
opal corelib and runtime. opal-spec is also
[hosted on github](http://github.com/adambeynon/opal-spec). opal-spec
can be ued inside the browser, which produces a nicely formatted
output, or inside a command-line runner, e.g. phantomjs.

You can see the opal corelib specs [running here](/specs).

## Getting Started

Setup your Gemfile to include the latest opal and opal-spec.

```ruby
# Gemfile
gem "opal", :git => "git://github.com/adambeynon/opal.git"
gem "opal-spec", :git => "git://github.com/adambeynon/opal-spec.git"
```

You will also need to setup a rake task to build your library and specs
ready to run inside the browser:

```ruby
# Rakefile
require 'opal/rake_task'

Opal::RakeTask.new do |t|
  t.name = 'my_app'
  t.dependencies = %w(opal-spec)
end
```

### Simple specs

To get started, make a simple test file named `./spec/first_spec.rb`:

```ruby
# spec/first_spec.rb

describe "My First test" do
  it "should work as expected" do
    1.should == 1
  end
end
```

You don't need to have any lib files present, as this simple test does
not make any calls to your library.

### Building

To get your app working, you need to build 3 files.

This will build opal.js, opal-spec.js and specs.js into `build/`:

```
rake opal
```

### Running

The easiest way to run your specs is to run them inside a webpage:

```html
<!doctype html>
<html>
<head>
  <title>Specs</title>
  <script src="build/opal.js"></script>
  <script src="build/opal-spec.js"></script>
  <script src="build/specs.js"></script>
</head>
<body>
</body>
</html>
```

Now open `index.html` inside a browser and view the results.