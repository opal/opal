# RSpec

`opal-rspec` allows opal to use rspec for running specs in javascript
environments. It comes with built-in support for running rspec with custom
`phantomjs` and standard web browser formatters. Also, async spec examples
are supported to reflect browser usage of ruby applications.

```ruby
describe User do
  it "can be created with a name" do
    expect(User.new).to_not be_persisted
  end
end
```

### Installation

Add the `opal-rspec` gem to your Gemfile:

```ruby
# Gemfile
gem 'opal'
gem 'opal-rspec'
```

## Running specs

### phantomjs

To run specs, a rake task can be added which will load all spec files
from `spec/`:

```ruby
# Rakefile
require 'opal/rspec/rake_task'
Opal::RSpec::RakeTask.new(:default)
```

Then, to run your specs inside phantomjs, just run the rake task:

```sh
$ bundle exec rake
```

### In a Browser

`opal-rspec` can use sprockets to build and serve specs over a simple rack server. Add the following to a `config.ru` file:

```ruby
# config.ru
require 'bundler'
Bundler.require

sprockets_env = Opal::RSpec::SprocketsEnvironment.new
run Opal::Server.new(sprockets: sprockets_env) { |s|
  s.main = 'opal/rspec/sprockets_runner'
  s.append_path 'spec'
  s.debug = false
}
```

Then run the rack server bundle exec rackup and visit `http://localhost:9292` in any web browser.

## Async examples

`opal-rspec` adds support for async specs to rspec. These specs are defined using
`#async` instead of `#it`:

```ruby
describe MyClass do
  # normal example
  it 'does something' do
    expect(:foo).to eq(:foo)
  end

  # async example
  async 'does something else, too' do
    # ...
  end
end
```

This just marks the example as running async. To actually handle the async result,
you also need to use a `run_async` call inside some future handler:

```ruby
async 'HTTP requests should work' do
  HTTP.get('/users/1.json') do |res|
    run_async {
      expect(res).to be_ok
    }
  end
end
```

The block passed to `run_async` informs the runner that this spec is finished
so it can move on. Any failures/expectations run inside this block will be run
in the context of the example.

