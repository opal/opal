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

The following encodings have implementations and are available by default:
- ASCII-8BIT (US-ASCII, ISO-8859-1, BINARY)
- UTF-8
- UTF-16LE
- UTF-16BE
- UTF-32LE
- UTF-32BE


Support for EUC-JP, JIS and ShiftJIS encodings is available too but must be explicitly required:
```ruby
require 'corelib/string/encoding/eucjp' # for EUC-JP
require 'corelib/string/encoding/jis'   # for JIS
require 'corelib/string/encoding/sjis'  # for ShiftJIS
```

The following encodings are available with a dummy implementation,
- based on ASCII: IBM437, CP437
- based on UTF16-LE: EUC_KR, IBM720, IBM866, ISO-8859-15 ISO-8859-16, ISO-8859-2, ISO-8859-5, KOI8_U, UTF-7, WINDOWS-1250,
WINDOWS-1251, CP1251, WINDOWS-1252
- based on SJIS: CP932
Support for these encodings must be explicitly required:
```ruby
require 'corelib/string/encoding/dummy'
```

## Limitations

Please be aware that the internal representation of Strings, regardless of encoding, is always the same UCS2/UTF-16 because the String implementation is currently based on JavaScript primitives or JavaScript String objects. In consequence, the range of codepoints is limited to the range made accessible by the JavaScript engines UCS2/UTF-16 range. Certain (high) codepoints may not be representable or even be accessible at all, throwing errors. UTF-32 is therefore also limited to the UCS2/UTF-16 codepoint range.

Some characters in the UTF range may be available via multiple codepoints. So Strings, which may appear visually identical in Matz Ruby and Opal may still end up having different codepoints or binary representations for those characters, depending on the JavaScript engines internal interpretation of Strings.

## Binary Representation

The binary representation of String encodings is emulated and likewise limited to the codepoint range made available by the JavaScript engine. So when calling #bytes on a ruby String encoded in UTF-8, the result will be correct and different from calling #bytes on the same String encoded in UTF-16, even though the internal representation is in both cases USC2/UTF-16:
```ruby
a = 'hello'
a.encoding # => #<Encoding:UTF-8>
a.bytes # => [104, 101, 108, 108, 111]

b = 'hello'.encode(Encoding::UTF_16)
b.encoding # => #<Encoding:UTF-16>
b.bytes # => [0, 104, 0, 101, 0, 108, 0, 108, 0, 111]
```

When concatenating Strings with different encodings, the resulting bytes may be different from what would be expected in Matz Ruby.
If String bytes are important, its best to ensure the Strings have the same encoding before concatenating them.

Accessing String bytes in Opal may be a performance issue, contrary to Matz Ruby, due to the emulation.

## Multi Byte Characters / UTF Surrogates

Although JavaScript strings are UCS2/UTF-16 -ish, working with strings that contain multi byte characters is rather cumbersome in JavaScript.

For example, given a String 'a𝌆a𝌆a𝌆':

JavaScript reports its length in 16 bit units instead of characters:
```JavaScript
'a𝌆a𝌆a𝌆'.length // => 9
```

Trying to access characters by index will result in broken multi byte characters / surrogates:
```JavaScript
'a𝌆a𝌆a𝌆'[1] // => '\ud834'
```

And in addition the functions for manipulating JavaScript strings all ignore multi byte characters / surrogates and tend to brake them.

Opal is in advantage here, as multi byte characters / surrogates are treated naturally, as expected from Ruby.

Given the String 'a𝌆a𝌆a𝌆':

Its length is correctly reported as count of characters:
```Ruby
'a𝌆a𝌆a𝌆'.length # => 6
```

Accessing characters by index will correctly return multi byte characters / surrogates:
```JavaScript
'a𝌆a𝌆a𝌆'[1] // => '𝌆'
```

And all the methods of the Opal String class are aware of multi byte characters and will not break them (unless thats intended).

So Opal is perfectly suited for languages that depend on these characters and makes working with such strings very easy and natural.

Working around JavaScript's problems with multi byte characters makes some String methods a bit slower though.
