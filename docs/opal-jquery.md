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

## HTTP/AJAX requests

jQuery's Ajax implementation is also wrapped in the top level HTTP
class.

```ruby
HTTP.get("/users/1.json") do |response|
  puts response.body
  # => "{\"name\": \"Adam Beynon\"}"
end
```

The block passed to this method is used as the handler when the request
succeeds, as well as when it fails. To determine whether the request
was successful, use the `ok?` method:

```ruby
HTTP.get("/users/2.json") do |response|
  if response.ok?
    alert "successful!"
  else
    alert "request failed :("
  end
end
```

It is also possible to use a different handler for each case:

```ruby
request = HTTP.get("/users/3.json")

request.callback {
  puts "Request worked!"
}

request.errback {
  puts "Request didn't work :("
}
```

The request is actually triggered inside the `HTTP.get` method, but due
to the async nature of the request, the callback and errback handlers can
be added anytime before the request returns.

### Handling responses

Web apps deal with json responses quite frequently, so there is a useful
`#json` helper method to get the json content from a request:

```ruby
HTTP.get("/users.json") do |response|
  puts response.body
  puts response.json
end

# => "[{\"name\": \"Adam\"},{\"name\": \"Ben\"}]"
# => [{"name" => "Adam"}, {"name" => "Ben"}]
```

The `#body` method will always return the raw response string.

If an error is encountered, then the `#status_code` method will hold the
specific error code from the underlying request:

```ruby
request = HTTP.get("/users/3.json")

request.callback { puts "it worked!" }

request.errback { |response|
  puts "failed with status #{response.status_code}"
}
```