Opal supports `method_missing`! This is a key feature of ruby, and opal wouldn't be much use without it! This page details the implementation of `method_missing` for Opal.

## Method dispatches

Firstly, a ruby call `foo.bar 1, 2, 3` is compiled into the following javascript:

```javascript
foo.$bar(1, 2, 3)
```

This should be pretty easy to read. The `bar` method has a `$` prefix just to distinguish it from underlying javascript properties, as well as ruby ivars. Methods are compiled like this to make the generated code really readable.

## Handling method_missing

Javascript does not have an equivalent of `method_missing`, so how do we handle it? If a function is missing in javascript, then a language level exception will be raised.

To get around this, we make use of our compiler. During parsing, we collect a list of all method calls made inside a ruby file, and this gives us a list of all possible method calls. We then add stub methods to the root object prototype (an opal object, not the global javascript Object) which will proxy our method missing calls for us.

For example, assume the following ruby script:

```ruby
first 1, 2, 3
second "wow".to_sym
```

After parsing, we know we only ever call 3 methods: `[:first, :second, :to_sym]`. So, imagine we could just add these 3 methods to `BasicObject` in ruby, we would get something like this:

```ruby
class BasicObject
  def first(*args, &block)
    method_missing(:first, *args, &block)
  end

  def second(*args, &block)
    method_missing(:second, *args, &block)
  end

  def to_sym(*args, &block)
    method_missing(:to_sym, *args, &block)
  end
end
```

It is obvious from here, that unless an object defines any given method, it will always resort in a dispatch to `method_missing` from one of our defined stub methods. This is how we get `method_missing` in opal.

## Optimising generated code

To optimise the generated code slightly, we reduce the code output from the compiler into the following javascript:

```javascript
Opal.add_stubs(["first", "second", "to_sym"]);
```

You will see this at the top of all your generated javascript files. This will add a stub method for all methods used in your file.

## Alternative approaches

The old approach was to inline `method_missing` calls by checking for a method on **every method dispatch**. This is still supported via a parser option, but not recommended.