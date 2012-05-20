# Opal Dependency Example

This example shows how easy it is to use gem dependencies with opal to
easily maintain app dependencies.

Dependencies in opal are referenced from the rake task, and they must
be installed as system gems, or through bundler.

## Setting up

To ensure the required gems are installed, just run bundler:

```
bundle install
```

## Building dependencies

To build the gem dependency (`opal-json`), as well as the opal runtime
`opal.js`, just use the simple rake task:

```
rake dependencies
```

This will build the two files into `./build`.

## Building the app

Again, a simple rake task is available:

```
rake build
```

Which will build `./build/my-app.js` ready for use.

## Running application

Simply open `index.html` and observe the parsed json string as a ruby
hash instance.