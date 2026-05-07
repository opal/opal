# Opal::JS

`Opal::JS` is the usual way for Ruby code compiled by Opal to work with the
JavaScript world. Use it when you need to read browser or Node globals, call JS
methods, pass callbacks, or wrap a JS class with a Ruby API.

```ruby
require 'opal/js'
```

Requiring `opal/js` defines `$js`, a wrapped JavaScript global object.

## Ruby To JavaScript

Use `$js` to read properties, assign properties, and call JavaScript methods.

```ruby
$js.document.title = 'Hello from Opal'

element = $js.document.query_selector('#app')
element[:textContent] = 'Loaded'
```

Dynamic Ruby method names try the exact JavaScript property first, then a
camelCase translation. This means both forms can work:

```ruby
$js.document.querySelector('#app')
$js.document.query_selector('#app')
```

Use bracket access for exact JavaScript property names. Bracket access never
translates names.

```ruby
$js[:document][:body]
$js.document[:querySelector].call('#app')
```

If bracket access returns a JavaScript function, the wrapper keeps the original
receiver so `this` is preserved when calling it.

## Conversion Rules

Values passed from Ruby to JavaScript are made JavaScript-friendly:

- `nil` becomes JavaScript `undefined`.
- `Array` becomes a JavaScript array.
- `Hash` becomes a plain JavaScript object.
- `Proc` becomes a stable JavaScript function.
- `Opal::JS` wrappers unwrap to their JavaScript value.

Hash keys are not camelized during normal Ruby-to-JavaScript conversion.
Unsupported keys raise `Opal::JS::ConversionError`. Use string, symbol, or
numeric keys for plain JavaScript object conversion.

JavaScript objects coming back to Ruby stay live by default. Call `to_h` or
`to_a` only when you want a snapshot.

```ruby
config = Opal::JS.wrap(`{name: 'opal', nested: {ok: true}}`)
config[:nested][:ok] # => true
config.to_h         # => { 'name' => 'opal', 'nested' => { 'ok' => true } }
```

Snapshot conversion raises `Opal::JS::ConversionError` for cyclic object graphs.

## Callbacks

Ruby blocks and procs can be passed to JavaScript callbacks.

```ruby
callback = proc do
  $js.console.log('later')
end

$js.set_timeout(callback, 100)
```

During a synchronous JavaScript callback, `Opal::JS.this` exposes the JavaScript
receiver.

```ruby
$js.button.add_event_listener('click') do
  Opal::JS.this[:disabled] = true
end
```

The same Ruby callable maps to the same JavaScript function, so listener removal
can use the same proc object.

## Wrapper Classes

Use `Opal::JS::Wrapper` to give a JavaScript class a Ruby API.

```ruby
class Document
  include Opal::JS::Wrapper

  js_object
  js_register_wrapper $js.Document

  js_method :query, 'querySelector'
end

$js.document.query_selector('#app') # dynamic access works directly

doc = Document.wrap($js.document)
doc.query('#app')                   # typed wrapper access
```

`.wrap` takes an existing JavaScript value, allocates the Ruby wrapper, and
passes that value to `initialize_wrapped`. Override `initialize_wrapped` when a
wrapper needs to initialize Ruby state for an existing JS object.

You often do not need to call `.wrap` yourself. JavaScript values are
automatically wrapped whenever they cross into Ruby through `Opal::JS` and a
matching `js_register_wrapper` or `js_constructor` registration exists. Use
`.wrap` when you explicitly want to project an existing value, such as
`document`, an event target, or a value returned from another JS API, into a
specific wrapper class. Use `.new` only when the wrapper has a `js_constructor`
and should construct a new JavaScript object.

`js_object` installs the dynamic object behavior: exact `[]`/`[]=`, `dig`,
`to_h`, Ruby-style method dispatch, and setter support. It is recommended for
most object wrappers so the wrapper still behaves like `$js.document` when you
have not defined a more specific Ruby method.

Use `js_array` for array-like JS values. It includes the object behavior plus
`Enumerable`, `length`, `to_a`, `push`, `pop`, `shift`, and `unshift`.

Use `js_constructor` when `.new` should construct a JavaScript object.

```ruby
class URL
  include Opal::JS::Wrapper

  js_object
  js_constructor $js.URL
end

url = URL.new('https://opalrb.com')
```

`js_method` can reshape Ruby arguments for JavaScript APIs. The example below
lets Ruby callers write `window.set_timeout(100) { ... }` while JS receives the
callback first, as `setTimeout(callback, delay)` expects.

```ruby
module Timers
  include Opal::JS::Wrapper

  js_method :set_timeout, 'setTimeout', args: [:&, :*]
end

class Window
  include Timers
  include Opal::JS::Wrapper

  js_object
  js_register_wrapper $js.Window
end

window = Window.wrap($js)
window.set_timeout(100) { $js.console.log('later') }
```

Without an `args:` option, `js_method` passes positional arguments first, then
keyword options if present, then a block if present. Use `args:` only when the
JavaScript API expects a different shape:

```ruby
js_method :append_child, 'appendChild'
js_method :request_animation_frame, 'requestAnimationFrame', args: [:&]
js_method :listen, 'addEventListener', args: [0, :&, :*]
```

Useful projection tokens are:

- `:*` remaining positional arguments.
- `:**` keyword/options object.
- `:&` block.
- integers such as `0`, `1`, or `-1` for specific positional arguments.

Keyword keys are converted only when requested with `kwargs: :convert`.

## JavaScript To Ruby: `Opal.$`

`Opal.$` exposes Ruby constants and objects to JavaScript through a proxy facade.

```javascript
const Converter = Opal.$.MarkdownConverter;
const converter = new Converter({format: 'html'});

converter.inputText = 'text';       // Ruby: converter.input_text = 'text'
converter.renderMarkdown();         // Ruby: converter.render_markdown
converter.exportTo('clipboard');    // Ruby: converter.export_to('clipboard')
```

Unlike Ruby-to-JavaScript Hash conversion, `Opal.$` prepares the final plain JS
object argument for Ruby keyword extraction. Use Ruby keyword names in that
object unless the called Ruby API documents another shape.

Property reads are callable on the JavaScript side. This is surprising but
intentional: JavaScript `Proxy` cannot tell whether `obj.prop` is meant as a
method call or as a value read. Use `converter.outputHtml()` to call the Ruby
getter `output_html`, and `converter.outputHtml = value` to call `output_html=`.

```javascript
converter.outputHtml();              // Ruby: converter.output_html
converter.outputHtml = '<p>ok</p>';  // Ruby: converter.output_html = '<p>ok</p>'
```

Uppercase names look up Ruby constants first:

```javascript
Opal.$.Asciidoctor.Converters.HTML
```

Use escape helpers when you need exact Ruby access independent of JavaScript
property syntax:

```javascript
obj.__send__('empty?');
obj.__const__('NestedName');
```

For exact method names that are valid JavaScript property keys, bracket member
access can also call the method:

```javascript
obj['empty?']();
```

Use `__send_raw__` when you need explicit positional args, kwargs, and block
shaping without the default final-function-as-block heuristic.

```javascript
obj.__send_raw__(
  'method_name',
  [arg1, arg2],
  {kwarg: 123},
  function () { return 'block'; }
);

obj.__send_raw__('method_name', function () { return 'block'; });
obj.__send_raw__('method_name', {kwarg: 123});
```

`Object.keys`, `in`, and property descriptors expose JavaScript-facing names.
For example, Ruby `my_property` appears as `myProperty`. Exact Ruby names remain
available through `__send__`.
