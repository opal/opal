# Encoding

Encoding support is partial and mostly given by the encoding set by the HTML page.
We suggest to always set encoding to UTF-8 explicitly:

```html
<!doctype html>
<html>
  <head>
    <meta charset="UTF-8" />
    <!-- ... -->
```

Support for EUC-JP, JIS and ShiftJIS encodings is available but must be explicitly required:
```ruby
require 'corelib/string/encoding/eucjp' # for EUC-JP
require 'corelib/string/encoding/jis'   # for JIS
require 'corelib/string/encoding/sjis'  # for ShiftJIS
```
