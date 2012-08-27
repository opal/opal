# opal-jquery

opal-jquery provides DOM access to opal by wrapping jquery (or zepto)
and providing a nice ruby syntax for dealing with jquery instances.
opal-jquery is [hosted on github](http://github.com/adambeynon/opal-jquery).

jQuery instances are toll-free bridged to instances of the ruby class
`JQuery`, so they can be used interchangeably. The `Document` module also
exists, which provides the simple top level css selector method:

```ruby
elements = Document['.foo']
# => [<div class="foo">, ...]

elements.class
# => JQuery

elements.on(:click) do
  alert "element was clicked"
end
```

jQuery's Ajax implementation is also wrapped in the top level HTTP
class.

```ruby
HTTP.get("/users/1.json") do |response|
  puts response.body
  # => "{\"name\": \"Adam Beynon\"}"
end
```