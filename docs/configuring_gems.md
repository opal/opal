# Configuring Gems For Opal

To configure a gem to run in Opal the gem will need a couple of things:

1. The opal gem running on a server (so the ruby code can get compiled to .js.)
2. The opal search path has to know to look for your gem when it is required.

This is done by having the following 2 lines in your outermost .rb file:

```ruby
require 'opal'
Opal.append_path File.expand_path('..', __FILE__).untaint
```

However it only makes sense to execute these lines outside of Opal, since what they do is set things up for Opal to find and compile the files to .js. So how these lines get added to your gem depends on whether the gem can usefully run in the normal server environment as well as in Opal, or just strictly in Opal.

For example, you have a gem that parses, validates, and gives details on email addresses.  This gem would be just as useful on the server, as running
in the browser.

On the other hand you have a gem that does something with the DOM.  There would be no point in making this gem available to the server.

Each case is detailed below, assuming you have a Gem file structure like this:


```
/lib
  /your_gem_directory
    /your_gem_file1.rb
    /your_gem_file2.rb
    /...
    /version.rb
  /your_gem.rb
```

## Configuring Gems To Run Everywhere

If your gem will work both in Opal and in a classic ruby environment
your outer .rb file (`your_gem.rb`) needs to look like this

```ruby
# require all the files, regardless of whether this code is running
# to run on the server, or inside of Opal.
require_relative 'your_gem_directory/your_gem_file1.rb'
require_relative 'your_gem_directory/your_gem_file2.rb'
# etc
require_relative 'your_gem_directory/version'
unless RUBY_ENGINE == 'opal'
  # Now if we are NOT running inside of opal, set things up so opal can find
  # the files. The whole thing is rescued in case the opal gem is not available.
  # This would happen if the gem is being used server side ONLY.
  begin
    require 'opal'
    Opal.append_path File.expand_path('..', __FILE__).untaint
  rescue LoadError
  end
end
```

So lets see what happens here.

1. Somebody is going to require this file, perhaps implicitly (for example you are running in rails.)
2. Standard ruby is going to execute the `require`s, which will load your gem sources, then
3. because the `RUBY_ENGINE` is _not_ `opal`, Opal will be required, and your directory of sources added to Opal's search path.
4. Someplace else in some Opal code, the gem will _again_ be required, and so opal searches and finds the gem,
5. and runs this file again, _but now inside_ of the Opal environment.  This time the `RUBY_ENGINE` _is_ Opal so the `require 'opal'` etc will not be executed.

The result is that you have two versions of the code, one in standard ruby, and a second compiled to .js and ready to be served.

## Configuring Gems To Run In Opal Only

If it makes no sense to run the code in standard Ruby (i.e. on the server) then the above code can look like this:

```ruby
# require all the files, only if Opal is executing
if RUBY_ENGINE == 'opal'
  require_relative 'your_gem_directory/your_gem_file1.rb'
  require_relative 'your_gem_directory/your_gem_file2.rb'
  # etc
  require_relative 'your_gem_directory/version'
else
  # NOT running inside of opal, set things up
  # so opal can find the files.
  require 'opal'
  Opal.append_path File.expand_path('..', __FILE__).untaint
end
```

## Testing

Regardless of which case your gem is designed for, you will want to make sure you test inside the Opal environment.  If nothing else you will want to make sure you have all the above configuration setup correctly.

To do this add the following to your gemspec:

```ruby
spec.add_development_dependency "opal-rspec"
spec.add_development_dependency "opal"
```

Then setup the following in config.ru (assuming your specs are in the /spec directory.)

```ruby
require 'bundler'
Bundler.require

require 'opal-rspec'
Opal.append_path File.expand_path('../spec', __FILE__)

run Opal::Server.new { |s|
  s.main = 'opal/rspec/sprockets_runner'
  s.append_path 'spec'
  s.debug = false
  s.index_path = 'spec/index.html.erb'
}
```

Finally create a index.html.erb file in the spec directory with the following contents:

```html
<!DOCTYPE html>
<html>
<head>
</head>
<body>
  <%= javascript_include_tag @server.main %>
</body>
</html>
```

With all this setup, you can run specs normally to test standard ruby execution, and then do

    bundle exec rackup

and point your browser to localhost, and you will see your spec results running in the Opal environment.

Don't forget to checkout the added features of the opal-rspec gem such as async specs.

## Conditional Execution

In some cases you might have to check whether you are in Opal or not, just wrap the code in:

```ruby
if RUBY_ENGINE == 'opal'
  # …
end
```

This might happen in your specs or in the actual gem code.

