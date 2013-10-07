Accessing classes and methods defined in Opal from the javascript runtime is possible via the Opal js object. The following class:

```ruby
class Foo
  def bar
    puts "called bar on class Foo defined in ruby code"
  end
end
```

Can be accessed from javascript like this:

```javascript
Opal.Foo.$new().$bar();
// => "called bar on class Foo defined in ruby code"
```

Remember that all ruby methods are prefixed with a '$'.