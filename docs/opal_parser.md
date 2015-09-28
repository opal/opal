# Parsing Ruby from JavaScript with `opal-parser`

Generally is best to precompile Ruby source files to JavaScript server-side but sometimes may become useful to be able to compile Ruby to JavaScript directly from JS.

Opal is able to compile its – pure Ruby – compiler to JavaScript (how cool is that!). The whole compiler chain is available in the `stdlib` as `opal-parser`.

```ruby
require 'opal-parser'
```


## Features

### `Kernel#eval`

`opal-parser` provides a partial implementation of `Kernel#eval` that only support the first parameter (String) and refuse any passed `binding`, `lineno` or `filename`.

Example:

```ruby
require 'opal-parser'
eval "puts 'hello world!'"
```


### `Kernel#require_remote`

Will fetch a remote URL (by means of a sync `XMLHttpRequest`) and evaluate its contents as Ruby code.

Example:

```ruby
require 'opal-parser'
require_remote 'http://pastie.org/pastes/10444960/text'
HelloWorld.new.say_hello!
```


### `Opal.compile()` and `Opal.eval()` (JavaScript)

After requiring `opal-parser` both `Opal.compile()` and `Opal.eval()` functions are added to the JavaScript API.

`Opal.compile(string, options)` (JavaScript) will forward the call to `Opal.compile` (Ruby) converting options from a plain JS object to a Ruby Hash.
`Opal.eval(string)` will compile the given code to JavaScript and then pass it to the [native `eval()` function][eval].


### Support for `<script type="text/ruby">`

When `opal-parser` is required it will search the page for any `<script>` tag with type `text/ruby`.
If an `src` attribute is present will fetch and eval the file with `Kernel#require_remote` otherwise it will get the script tags contents and eval them with `Kernel#eval`.


[eval]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/eval
