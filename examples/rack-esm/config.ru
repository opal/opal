require 'bundler'
Bundler.require

# Instructions: bundle in this directory
# then run `bundle exec rackup` to start the server
# and browse to http://localhost:9292

# a very small application that just tries to authenticate a user and fails
# it just writes to the console in the browser (no visible html)

# with gems like opal-jquery or opal-browser you could manipulate the dom directly

# the directory where the code is (add to opal load path )
Opal.append_path 'app'

# Enable ESM
Opal::Config.esm = true

run Opal::SimpleServer.new { |s|
  # the name of the ruby file to load. To use more files they must be required from here (see app)
  s.main = 'application'
  # need to set the index explicitly for opal server to pick it up
  s.index_path = 'index.html.erb'
}

