# Bridging in Opal

## Introduction

Opal introduces a mechanism known as "bridging", which enables JavaScript classes to be treated as Ruby classes. This feature enhances the interoperability between both languages and optimizes performance by leveraging native JavaScript counterparts of certain Ruby classes.

## Basics of Bridging

In Opal's bridging process, the native JavaScript constructor function's prototype chain is modified by injecting a Ruby class and its superclasses. Before the bridging, the prototype chain of a JavaScript constructor function might look something like:

- constructor (e.g. window.String)
  - super

What Opal's bridging does is inject the Ruby class and its superclass chain between the constructor and its super. After bridging, for instance, after injecting `::Object` into JavaScript's `String`, the prototype chain would look like:

- constructor (e.g. window.String)
  - Bridged Ruby class (e.g. Opal.Object)
    - Superclass chain of the bridged Ruby class (e.g. Opal.Kernel, Opal.BasicObject)
      - Super of the constructor (e.g. window.Object)
        - null

This allows the bridged JavaScript classes to inherit behaviors of the Ruby class and its superclasses, essentially treating them as Ruby classes.

Opal employs the `Opal.bridge` function to bridge a native JavaScript class with a Ruby class, modifying the JavaScript class's prototype chain to include the Ruby class and its superclass chain. This allows the JavaScript class to inherit the behavior of the Ruby class.

The bridged JavaScript classes can then be used in Ruby code. However, the interface isn't seamless: when accessing JavaScript methods from Ruby, you'll need to use x-strings, and when accessing Ruby methods from JavaScript, you'll need to use $-prefixed method names (e.g., reduce becomes $reduce). 

While this bridging mechanism requires some adaptation in terms of method naming conventions, it has the advantage of not involving type casting, as long as the objects being passed are bridged. For non-bridged, or "wrapped", objects, type casting may still be necessary.

This bridging mechanism is a core part of Opal's strategy to enhance performance. By leveraging native JavaScript objects where possible, Opal optimizes the execution speed of Ruby classes that are toll-free bridged to their native JavaScript counterparts.

Let's consider a user-defined JavaScript class `Car`. Here's how you could bridge it in Opal:

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

In your Ruby code, you can create a Ruby class `MyCar` which bridges this `Car` class:

```ruby
class MyCar < `Car`
  # This is needed if we want to pass arguments
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

In the provided example, we're bridging a user-defined JavaScript class `Car` to a Ruby class `MyCar`. We override the `new` method of the `MyCar` class to create an instance of the JavaScript `Car` class, passing the appropriate arguments (`make`, `model`). The JavaScript `new Car(make, model)` expression is embedded directly in the Ruby code using backticks. This allows us to create a new `Car` JavaScript object from within Ruby.

Within the `MyCar` class, we define a method `car_info` that directly calls a method on the JavaScript `Car` object. We use `self` in the backtick-enclosed JavaScript to refer to the JavaScript object, which is exactly the same as the Ruby object due to the bridging.

Now when we create a new instance of `MyCar` with `'Toyota', 'Corolla'` as arguments, we're actually creating a new instance of the JavaScript `Car` class. When we call `car_info` on the `car` object, it outputs `"Toyota Corolla"`, demonstrating the direct interaction between the Ruby object and its underlying JavaScript object.

This example highlights how bridging can provide a seamless interaction between Ruby and JavaScript, with objects and their methods being interchangeable between the two languages.

## Inheritance and Bridging

It is possible to create a subclass of a native JavaScript class. Bridging does not alter the normal behavior or the inheritance hierarchy of JavaScript classes. 

## Bridging Considerations

### Bridged Class Methods

JavaScript class methods can be accessed as properties on the constructor by calling `class.$$constructor`, where `class` is an instance of a Ruby `Class` class.

### Performance

Bridging is faster than wrapping since it does not involve the use of a wrapper object. However, the modification of the prototype chain may have an impact on JavaScript engine performance.

### Exception Handling

JavaScript `Error` is bridged to Ruby `Exception`, providing a more unified error handling experience.

### Native JavaScript Interactions

You can use x-strings for interacting with native JavaScript. A helper class `Native` is provided that wraps JavaScript objects and offers a Ruby-like API for interacting with them. 

### Type Conversions

Since bridging creates objects that are equivalent between Ruby and JavaScript, no explicit type conversion is required for them. The `Native` library provides a `#to_n` method on everything that needs conversion into JavaScript.

### JavaScript Functions

JavaScript functions are bridged to `Proc`. This means, you can use `Proc#call` to call a JavaScript function, but do note that no type conversions will occur.

## Bridged Classes in Opal's Corelib

Opal's core library provides bridging for several commonly used JavaScript classes. These include `Array`, `Boolean`, `Number` (which maps to Ruby's `Float`), `Proc`, `Time`, `RegExp`, and `String`. This bridging allows you to interact with instances of these JavaScript classes as if they were their Ruby counterparts.

Notably, there are also common JavaScript classes that Opal does not bridge. Specifically, `Hash` and `Set` are not bridged in Opal's core library. This is due to the significant differences in the behavior and interfaces of these classes between Ruby and JavaScript.

## Drawbacks

Bridging offers a great way to utilize JavaScript objects within the Ruby programming environment, making them behave like Ruby objects. However, like all programming techniques, it does have its downsides.

The most significant drawback of bridging in Opal is that it modifies the prototypes of the JavaScript classes. In JavaScript, each object has a prototype from which it inherits properties. By modifying this prototype, we effectively alter the structure and behavior of the JavaScript object. This is often referred to as "polluting" the prototypes.

While this pollution is necessary for bridging to work, it can have unintended side effects. For instance, it can lead to conflicts with other JavaScript code that expects the prototype to be in its original state. If other code relies on certain properties or methods that were overwritten during bridging, this could lead to bugs that are hard to trace. Furthermore, changing the prototypes might also impact the performance of the JavaScript engine, potentially leading to slower code execution.

Moreover, bridging requires a deep understanding of both Ruby and JavaScript, as well as the way Opal implements bridging between the two. It is a sophisticated technique, and using it incorrectly could lead to complex and hard-to-debug issues.

For these reasons, you may want to consider using an alternative to bridging such as `Native::Wrapper`. This module, provided in Opal's standard library, allows you to interact with JavaScript objects without modifying their prototypes. It provides a friendly Ruby API for accessing and calling JavaScript methods, and even for dealing with JavaScript properties. `Native::Wrapper` wraps the JavaScript objects rather than directly modifying them, hence it avoids the prototype pollution problem.

In summary, while bridging provides powerful functionality in mixing Ruby and JavaScript code, it should be used with caution and a deep understanding of its implications. Depending on your needs, `Native::Wrapper` might be a safer and more intuitive alternative for working with JavaScript objects in Opal.

## Testing

Testing in a bridged environment does not have any special considerations compared to regular testing methodologies.

## Conclusion

The bridging mechanism provided by Opal offers a compelling method for fusing the functionality and benefits of both Ruby and JavaScript into a singular environment. Despite the necessity for careful consideration due to potential pitfalls, the bridging process ultimately affords developers the ability to utilize the individual strengths of both languages within a cohesive and unified codebase. Through the leveraging of this mechanism, we are given the capacity to push the boundaries of conventional web programming paradigms and create richer, more dynamic applications.
