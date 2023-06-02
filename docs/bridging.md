# Opal Bridging

## Intro

Opal's "bridging" makes JavaScript objects become Ruby object in Opal, boosting language interoperability and performance by using native JavaScript versions of certain Ruby classes.

## Bridging Basics

Opal modifies the prototype chain of a JavaScript constructor function by injecting a Ruby class and its superclasses, enabling bridged JavaScript classes to inherit Ruby behaviors.

Prototype chain pre-bridging: 

- constructor (window.String)
  - JavaScript prototype chain (window.Object)
    - null

After bridging with `::Object`:

- constructor (window.String)
  - Ruby superclass chain (Opal.Object, Opal.Kernel, Opal.BasicObject)
    - JavaScript prototype chain (window.Object)
      - null

The `Opal.bridge` function is used for this, allowing the JavaScript class to become a Ruby class. You can also use a syntax like: ```class MyCar < `Car` ``` which counterintuitively doesn't mean inheritance - `MyCar`'s superclass will be Object, but `MyCar` will be bridged into native JavaScript `Car` class.

The bridged JavaScript classes are usable in Ruby, but with an adapted interface: JavaScript methods accessed from Ruby use x-strings and Ruby methods accessed from JavaScript use $-prefixed method names (e.g., reduce->$reduce). 

This strategy avoids type casting for bridged objects and boosts performance by utilizing native JavaScript objects. 

Example:

JavaScript `Car` class:

```javascript
class Car {
  constructor(make, model) {
    this.make = make;
    this.model = model;
  }

  getCarInfo() {
    return `${this.make} ${this.model}`;
  }
}
```

Bridged Ruby `MyCar` class:

```ruby
class MyCar < `Car`
  def self.new(make, model)
    `new Car(make, model)`
  end

  def car_info
    `self.getCarInfo()`
  end
end

car = MyCar.new('Toyota', 'Corolla')
puts car.car_info  # Outputs: "Toyota Corolla"
```

This bridges `Car` to `MyCar`, creating a `Car` instance with `new Car(make, model)`. We call `getCarInfo()` via `self`, referencing the same JavaScript and Ruby object due to bridging. Thus, creating a `MyCar` instance makes a `Car` instance, and `car_info` on the `car` object outputs `"Toyota Corolla"`. This shows seamless Ruby-JavaScript interaction via bridging.

## Inheritance & Bridging

Creating a subclass of a native JavaScript class is possible. Bridging doesn't affect JavaScript's behavior or inheritance hierarchy.

## Bridging Considerations

### Bridged Class Methods

Access JavaScript class methods as properties on the constructor with `class.$$constructor`, where `class` is a Ruby class. You can access it using `self`.

### Performance

Bridging is quicker than wrapping as no wrapper object is used, but altering the prototype chain could affect JavaScript engine performance.

### Exception Handling

JavaScript `Error` is bridged to Ruby `Exception` for unified error handling.

### Native JavaScript Interactions

Use x-strings for interacting with native JavaScript. The `Native` class wraps JavaScript objects and offers a Ruby-like API.

### Type Conversions

With bridging creating equivalent Ruby and JavaScript objects, no explicit type conversion is needed. The `Native` library's `#to_n` is how you convert non-bridged objects.

## Bridged Classes in Corelib

Opal's core library bridges several commonly used JavaScript classes, including `Array`, `Boolean`, `Number` (think: `Float` which also may act as an `Integer`), `Proc`, `Time`, `RegExp`, and `String`, allowing interaction with these JavaScript instances as their Ruby equivalents.

However, Opal doesn't bridge common JavaScript classes like `Hash` and `Set` due to significant differences in behavior and interfaces between Ruby and JavaScript.

## Drawbacks

Bridging effectively utilizes JavaScript objects within Ruby, but it does have its downsides.

The main drawback of Opal bridging is that it modifies the prototypes of JavaScript classes, potentially leading to prototype pollution. This can cause conflicts with other JavaScript code expecting the prototype in its original state, potentially causing hard-to-trace bugs or slower code execution due to changes impacting the JavaScript engine's performance.

Additionally, bridging requires comprehensive knowledge of both Ruby and JavaScript, and understanding how Opal implements the bridge. Incorrect usage can lead to complex, hard-to-debug issues.

An alternative to bridging is using `Native::Wrapper`. This module in Opal's standard library allows interaction with JavaScript objects without modifying their prototypes. It offers a Ruby-friendly API for accessing and calling JavaScript methods, as well as handling JavaScript properties, thus avoiding the prototype pollution issue.

In conclusion, bridging provides powerful functionality for Ruby-JavaScript code interaction, but it should be used cautiously and with a deep understanding of its implications. Depending on your needs, `Native::Wrapper` may be a safer and more intuitive alternative.

## Conclusion

Opal's bridging mechanism offers an enticing method for combining Ruby and JavaScript's strengths into a single environment. Despite requiring caution due to potential drawbacks, bridging enables developers to create Ruby idiomatic APIs for accessing JavaScript code. By leveraging this mechanism, we can redefine conventional web programming paradigms and create more vibrant, dynamic applications.
