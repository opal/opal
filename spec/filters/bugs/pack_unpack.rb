# NOTE: run bin/format-filters after changing this file
opal_filter "String#unpack" do
  fails "String#unpack with format 'A' decodes into raw (ascii) string values" # Expected "UTF-16LE" to equal "ASCII-8BIT"
  fails "String#unpack with format 'H' should make strings with US_ASCII encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#unpack with format 'Q' adds nil for each element requested beyond the end of the String" # Expected [7523094288207668000, nil, nil] to be computed by "abcdefgh".unpack from "Q3" (computed [7523094288207667000, nil, nil] instead)
  fails "String#unpack with format 'Q' decodes one long for a single format character" # Expected [7523094288207667000] to equal [7523094288207668000]
  fails "String#unpack with format 'Q' decodes the number of longs requested by the count modifier" # Expected [7523094283929477000, 7378418357791582000] to equal [7523094283929478000, 7378418357791582000]
  fails "String#unpack with format 'Q' decodes two longs for two format characters" # Expected [7233738012216484000, 7233733596956420000] to equal [7233738012216485000, 7233733596956420000]
  fails "String#unpack with format 'Q' ignores NULL bytes between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'Q' ignores spaces between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'Q' with modifier '<' decodes one long for a single format character" # Expected [7523094288207667000] to equal [7523094288207668000]
  fails "String#unpack with format 'Q' with modifier '<' decodes the number of longs requested by the count modifier" # Expected [7523094283929477000, 7378418357791582000] to equal [7523094283929478000, 7378418357791582000]
  fails "String#unpack with format 'Q' with modifier '<' decodes two longs for two format characters" # Expected [7233738012216484000, 7233733596956420000] to equal [7233738012216485000, 7233733596956420000]
  fails "String#unpack with format 'Q' with modifier '<' ignores NULL bytes between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'Q' with modifier '<' ignores spaces between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'Q' with modifier '>' decodes one long for a single format character" # Expected [7523094288207667000] to equal [7523094288207668000]
  fails "String#unpack with format 'Q' with modifier '>' decodes the number of longs requested by the count modifier" # Expected [7523094283929477000, 7378418357791582000] to equal [7523094283929478000, 7378418357791582000]
  fails "String#unpack with format 'Q' with modifier '>' decodes two longs for two format characters" # Expected [7233738012216484000, 7233733596956420000] to equal [7233738012216485000, 7233733596956420000]
  fails "String#unpack with format 'Q' with modifier '>' ignores NULL bytes between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'Q' with modifier '>' ignores spaces between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'U' decodes UTF-8 max codepoints" # Expected [65536] to be computed by "𐀀".unpack from "U" (computed [55296, 56320] instead)
  fails "String#unpack with format 'U' does not decode any items for directives exceeding the input string size" # ArgumentError: malformed UTF-8 character
  fails "String#unpack with format 'a' decodes into raw (ascii) string values" # Expected "UTF-16LE" to equal "ASCII-8BIT"
  fails "String#unpack with format 'b' decodes into US-ASCII string values" # Expected "UTF-16LE" to equal "US-ASCII"
  fails "String#unpack with format 'h' should make strings with US_ASCII encoding" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT (dummy)>
  fails "String#unpack with format 'm' produces binary strings" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT>
  fails "String#unpack with format 'q' adds nil for each element requested beyond the end of the String" # Expected [7523094288207668000, nil, nil] to be computed by "abcdefgh".unpack from "q3" (computed [7523094288207667000, nil, nil] instead)
  fails "String#unpack with format 'q' decodes a long with most significant bit set as a negative number" # Expected [-71870673923813380] to equal [-71870673923814400]
  fails "String#unpack with format 'q' decodes one long for a single format character" # Expected [7523094288207667000] to equal [7523094288207668000]
  fails "String#unpack with format 'q' decodes the number of longs requested by the count modifier" # Expected [7523094283929477000, 7378418357791582000] to equal [7523094283929478000, 7378418357791582000]
  fails "String#unpack with format 'q' decodes two longs for two format characters" # Expected [7233738012216484000, 7233733596956420000] to equal [7233738012216485000, 7233733596956420000]
  fails "String#unpack with format 'q' ignores NULL bytes between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'q' ignores spaces between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'q' with modifier '<' decodes a long with most significant bit set as a negative number" # Expected [-71870673923813380] to equal [-71870673923814400]
  fails "String#unpack with format 'q' with modifier '<' decodes one long for a single format character" # Expected [7523094288207667000] to equal [7523094288207668000]
  fails "String#unpack with format 'q' with modifier '<' decodes the number of longs requested by the count modifier" # Expected [7523094283929477000, 7378418357791582000] to equal [7523094283929478000, 7378418357791582000]
  fails "String#unpack with format 'q' with modifier '<' decodes two longs for two format characters" # Expected [7233738012216484000, 7233733596956420000] to equal [7233738012216485000, 7233733596956420000]
  fails "String#unpack with format 'q' with modifier '<' ignores NULL bytes between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'q' with modifier '<' ignores spaces between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'q' with modifier '>' decodes a long with most significant bit set as a negative number" # Expected [-71870673923813380] to equal [-71870673923814400]
  fails "String#unpack with format 'q' with modifier '>' decodes one long for a single format character" # Expected [7523094288207667000] to equal [7523094288207668000]
  fails "String#unpack with format 'q' with modifier '>' decodes the number of longs requested by the count modifier" # Expected [7523094283929477000, 7378418357791582000] to equal [7523094283929478000, 7378418357791582000]
  fails "String#unpack with format 'q' with modifier '>' decodes two longs for two format characters" # Expected [7233738012216484000, 7233733596956420000] to equal [7233738012216485000, 7233733596956420000]
  fails "String#unpack with format 'q' with modifier '>' ignores NULL bytes between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'q' with modifier '>' ignores spaces between directives" # Expected [7523094288207667000, 7233738012216484000] to equal [7523094288207668000, 7233738012216485000]
  fails "String#unpack with format 'u' decodes into raw (ascii) string values" # Expected "UTF-16LE" to equal "ASCII-8BIT"
end

opal_filter "Array#pack" do
  fails "Array#pack with format 'A' calls #to_str to coerce the directives string" # RuntimeError: Unsupported pack directive "x" (no chunk reader defined)
  fails "Array#pack with format 'A' returns a string in encoding of common to the concatenated results" # RuntimeError: Unsupported pack directive "U" (no chunk reader defined)
  fails "Array#pack with format 'C' calls #to_str to coerce the directives string" # RuntimeError: Unsupported pack directive "x" (no chunk reader defined)
  fails "Array#pack with format 'C' returns an ASCII-8BIT string" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT>
  fails "Array#pack with format 'L' calls #to_str to coerce the directives string" # RuntimeError: Unsupported pack directive "x" (no chunk reader defined)
  fails "Array#pack with format 'L' returns an ASCII-8BIT string" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT>
  fails "Array#pack with format 'L' with modifier '>' and '!' calls #to_int to convert the pack argument to an Integer" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Array#pack with format 'L' with modifier '>' and '!' encodes a Float truncated as an Integer" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '!' encodes all remaining elements when passed the '*' modifier" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '!' encodes the least significant 32 bits of a negative number" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '!' encodes the least significant 32 bits of a positive number" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '!' encodes the number of array elements specified by the count modifier" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '!' ignores NULL bytes between directives" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '!' ignores spaces between directives" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '_' calls #to_int to convert the pack argument to an Integer" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Array#pack with format 'L' with modifier '>' and '_' encodes a Float truncated as an Integer" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '_' encodes all remaining elements when passed the '*' modifier" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '_' encodes the least significant 32 bits of a negative number" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '_' encodes the least significant 32 bits of a positive number" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '_' encodes the number of array elements specified by the count modifier" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '_' ignores NULL bytes between directives" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' and '_' ignores spaces between directives" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' calls #to_int to convert the pack argument to an Integer" # Mock 'to_int' expected to receive 'to_int' exactly 1 times but received it 0 times
  fails "Array#pack with format 'L' with modifier '>' encodes a Float truncated as an Integer" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' encodes all remaining elements when passed the '*' modifier" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' encodes the least significant 32 bits of a negative number" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' encodes the least significant 32 bits of a positive number" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' encodes the number of array elements specified by the count modifier" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' ignores NULL bytes between directives" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'L' with modifier '>' ignores spaces between directives" # RuntimeError: Unsupported pack directive "L>" (no chunk reader defined)
  fails "Array#pack with format 'U' calls #to_str to coerce the directives string" # RuntimeError: Unsupported pack directive "x" (no chunk reader defined)
  fails "Array#pack with format 'U' encodes values larger than UTF-8 max codepoints" # Exception: Invalid code point 1114112
  fails "Array#pack with format 'U' raises a TypeError if #to_int does not return an Integer" # Expected TypeError but no exception was raised ("\u0005" was returned)
  fails "Array#pack with format 'a' calls #to_str to coerce the directives string" # RuntimeError: Unsupported pack directive "x" (no chunk reader defined)
  fails "Array#pack with format 'a' returns a string in encoding of common to the concatenated results" # RuntimeError: Unsupported pack directive "U" (no chunk reader defined)
  fails "Array#pack with format 'c' calls #to_str to coerce the directives string" # RuntimeError: Unsupported pack directive "x" (no chunk reader defined)
  fails "Array#pack with format 'c' returns an ASCII-8BIT string" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT>
  fails "Array#pack with format 'l' calls #to_str to coerce the directives string" # RuntimeError: Unsupported pack directive "x" (no chunk reader defined)
  fails "Array#pack with format 'l' returns an ASCII-8BIT string" # Expected #<Encoding:UTF-16LE> to equal #<Encoding:ASCII-8BIT>
  fails "Array#pack with format 'l' with modifier '>' and '!' calls #to_int to convert the pack argument to an Integer" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Array#pack with format 'l' with modifier '>' and '!' encodes a Float truncated as an Integer" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '!' encodes all remaining elements when passed the '*' modifier" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '!' encodes the least significant 32 bits of a negative number" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '!' encodes the least significant 32 bits of a positive number" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '!' encodes the number of array elements specified by the count modifier" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '!' ignores NULL bytes between directives" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '!' ignores spaces between directives" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '_' calls #to_int to convert the pack argument to an Integer" # Mock 'to_int' expected to receive to_int("any_args") exactly 1 times but received it 0 times
  fails "Array#pack with format 'l' with modifier '>' and '_' encodes a Float truncated as an Integer" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '_' encodes all remaining elements when passed the '*' modifier" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '_' encodes the least significant 32 bits of a negative number" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '_' encodes the least significant 32 bits of a positive number" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '_' encodes the number of array elements specified by the count modifier" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '_' ignores NULL bytes between directives" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' and '_' ignores spaces between directives" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' calls #to_int to convert the pack argument to an Integer" # Mock 'to_int' expected to receive 'to_int' exactly 1 times but received it 0 times
  fails "Array#pack with format 'l' with modifier '>' encodes a Float truncated as an Integer" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' encodes all remaining elements when passed the '*' modifier" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' encodes the least significant 32 bits of a negative number" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' encodes the least significant 32 bits of a positive number" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' encodes the number of array elements specified by the count modifier" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' ignores NULL bytes between directives" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'l' with modifier '>' ignores spaces between directives" # RuntimeError: Unsupported pack directive "l>" (no chunk reader defined)
  fails "Array#pack with format 'u' appends a newline to the end of the encoded string" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' calls #to_str to coerce the directives string" # RuntimeError: Unsupported pack directive "x" (no chunk reader defined)
  fails "Array#pack with format 'u' calls #to_str to convert an object to a String" # Mock 'pack m string' expected to receive 'to_str' exactly 1 times but received it 0 times
  fails "Array#pack with format 'u' emits a newline after complete groups of count / 3 input characters when passed a count modifier" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' encodes 1, 2, or 3 characters in 4 output characters (uuencoding)" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' encodes all ascii characters" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' encodes an empty string as an empty string" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' encodes one element per directive" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' ignores whitespace in the format string" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' implicitly has a count of 45 when passed '*', 0, 1, 2 or no count modifier" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' prepends the length of each segment of the input string as the first character (+32) in each line of the output" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' raises a TypeError if #to_str does not return a String" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' raises a TypeError if passed an Integer" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' raises a TypeError if passed nil" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' raises an ArgumentError if there are fewer elements than the format requires" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
  fails "Array#pack with format 'u' sets the output string to US-ASCII encoding" # RuntimeError: Unsupported pack directive "u" (no chunk reader defined)
end
