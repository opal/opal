# Projects using Opal

## opal-spec

opal-spec is a testing framework inspired by mspec/rspec, which is
used to test the core runtime, corelib and parser of opal. opal-spec
is [hosted on github](http://github.com/adambeynon/opal-spec).

opal-spec can be used inside the browser, which produces a nicely
formatted output, or inside a command-line runner, e.g. phantomjs.

```ruby
# foo.rb
class Foo
  def bar
    'baz'
  end
end

# spec.rb
describe "Foo#bar" do
  it "returns a string 'baz'" do
    Foo
  end
end

Spec::Runner.autorun
```

## opal-jquery

opal-jquery provides DOM access to opal by wrapping jquery (or zepto)
and providing a nice ruby syntax for dealing with jquery instances.
opal-jquery is [hosted on github](http://github.com/adambeynon/opal-jquery).

jQuery instances are toll-free bridged to instances of the ruby class
Element, so they can be used interchangeably. The Document module also
exists, which provides the simple top level css selector method:

```ruby
elements = Document['.foo']
# => [<div class="foo">, ...]

elements.class
# => Element

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

## vienna

Vienna (working title) is a client side MVC framework. Vienna is
[hosted on github](http://github.com/adambeynon/vienna).

```ruby
class Book
  include Vienna::Model

  field :title
  field :author
end

# create instance
book = Book.new title: 'First Book', author: 'Adam'

# use created setter
book.title = 'Amended title'

# getter
book.title    # => 'Amended title'

# no id, so it must be new
book.new?     # => true

# for sending over http/ajax
book.to_json  # => '{"title": "Amended title", "author": "Adam"}'

```