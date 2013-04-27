# Opal Example Application

This example shows how to use `Opal::Server` on top of a rack app to run
a simple opal application.

## Run example

Change into this directory, and install dependencies:

```
$ bundle install
```

Start the rack server (which will compile/build opal runtime for you):

```
$ bundle exec rackup
```

Then just open `http://127.0.0.1:9292` in any browser and checkout the console.

Happy hacking.
