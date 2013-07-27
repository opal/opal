`opal-sprockets` makes it easy to build static opal applications. Opal uses internal load paths to make it easy to handle resolving requirements during building. `opal-sprockets` forms the basis of rails support, so anything you can do there, you can do standalone as well.

## Overview

First, install `opal` and `opal-sprockets` by simply adding to a `Gemfile`:

```ruby
# Gemfile

gem "opal", ">= 0.4.3"
gem "opal-sprockets"
```

Next, we want to add our main app code. Keep all opal code inside `app/` directory, and edit `app/application.rb`:

```ruby
# app/application.rb

require "opal"

puts "Wow, running opal!"
```

You will notice the `require "opal"` line which will automatically include the opal runtime and corelib into our output, giving us access to the `puts()` method.

To build this, we need a rake task to load a new opal environment, add our `app/` directory to the load path, and then to build our target file `application.rb` which will be found because it is inside our added load path.

```ruby
# Rakefile

require 'opal'
require 'opal-sprockets'

desc "Build our app to build.js"
task :build do
  env = Opal::Environment.new
  env.append_path "app"

  File.open("build.js", "w+") do |out|
    out << env["application"].to_s
  end
end
```

Now, if you run `rake build` you will get the `build.js` output file with our application compiled, with the opal runtime included as well.

To run the application, lets create a very simple html file:

```html
<!DOCTYPE html>
<html>
  <head>
    <script src="build.js"></script>
  </head>
  <body>
  </body>
</html>
```

Now, open this html file and check the browsers console. You should see our message printed in the console.