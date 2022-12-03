# Directory Mode

By default, `Opal::Builder` and `opal` CLI tool build all the dependencies, then concatenate all the resulting JavaScript into a single file, possibly with a concatenated source map. This used to be a robust idea, before introduction of protocols like HTTP/2, HTTP/3 and before Rails 7. This also kind of duplicates the work of JavaScript bundlers and makes their work a little bit more difficult.

Since Opal 2.0, we have introduced a directory mode, which builds the resulting JavaScript into a directory instead of building a single file. It also duplicates the source files into this resulting directory and we debundle the source maps. **It is now, along with the ESM mode, the recommended way to build your Opal project and we will explore the ways to make it the default in some future major release.**

This results in a much more readable output.

## `opal` CLI tool

Let's say your input file is `my_program.rb` containing the following source:

```ruby
require "json"

puts "Hello world!".to_json
```

To compile it in regular, concatenated mode, to a file named `my_program.js` you would issue the following command:

```bash
opal -c my_program.rb > my_program.js
```

To compile it to a directory, you need to specify `--directory` option.

```bash
opal --directory -c my_program.rb -O my_program
```

In `my_program` directory you will find files, most notably, an `index.js` entrypoint file, which you can run in Node. Do note, that we use `require()` function to load the dependent programs, which doesn't work in browsers - this is the CommonJS output, which is the default. Therefore, we recommend to also add an `--esm` option:

```bash
opal --esm --directory -c my_program.rb -O my_program
```

Now, we get almost the same output, except that our entrypoint is named `index.mjs`, which as before, can be ran in Node. In addition, as convenience, we also build `index.html` which you can run directly in your favorite browser.

As in the default mode, instead of outputting your compiled program to a directory, you can use a runner, like `node` (node that not all the runners are supported yet):

```bash
opal --esm --directory -Rnode my_program.rb
```

This command should simply output the following:

```
"Hello world!"
```

## `Opal::Builder`

If you build your program with `Opal::Builder` class, for instance in your Rake task, its semantics in the directory mode also change slightly. For instance, you may have a code like this:

```ruby
builder = Opal::Builder.new
builder.append_paths __dir__
builder.build_require "opal", load: true
builder.build "my_program.rb"
File.binwrite("my_program.js", builder.to_s)
```

To use the directory mode and ESM, build your program like follows:

```ruby
builder = Opal::Builder.new(compiler_options: {esm: true, directory: true})
builder.append_paths __dir__
builder.build_require "opal", load: true
builder.build "my_program.rb"
builder.compile_to_directory "my_program"
```

To set compiler options, you can also use global variables:

```ruby
Opal::Config.esm = true
Opal::Config.directory = true
```

Note two differences: you can't use `#to_s` anymore and you need to define the correct compiler options.

## Sprockets

Unfortunately, the Sprockets pipeline is not supported with directory mode. While we intend to support the Sprockets pipeline for the foreseeable future, it's mostly in a maintenance stage and new features like directory mode won't be supported. We recommend you to migrate to any pipeline that uses `Opal::Builder` under the hood.
