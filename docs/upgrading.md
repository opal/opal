# Upgrading from v0.8 to v0.9

## `Opal::Processor.load_asset_code` deprecated

`Opal::Processor.load_asset_code(sprockets, name)` has been deprecated in favor of `Opal::Sprockets.load_asset(name, sprockets)`.

## `$console.log` instead of `pp`

Previously `pp` would have forwarded the object to JS own `console.log` but now just prints calling `.inspect` on it similarly to what `p` does.

```ruby
require 'pp'
pp a: 1, b: {c: 3}
```

Now:

```ruby
require 'console'
$console.log a: 1, b: {c: 3}
```

