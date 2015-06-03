# The JS module provides syntax sugar for calling native javascript
# operators (e.g. typeof, instanceof, new, delete) and global functions
# (e.g. parseFloat, parseInt).
module JS
  # Use delete to remove a property from an object.
  def delete(object, property)
    `delete #{object}[#{property}]`
  end

  # Use in to check for a property in an object.
  def in(property, object)
    `#{property} in #{object}`
  end

  # Use instanceof to return whether value is an instance of the function.
  def instanceof(value, func)
    `#{value} instanceof #{func}`
  end

  # Use new to create a new instance of the prototype of the function.
  def new(func, *args)
    f = `function(){return func.apply(this, args)}`
    f.JS[:prototype] = func.JS[:prototype]
    `new f()`
  end

  # Use typeof to return the underlying javascript type of value.
  # Note that for undefined values, this will not work exactly like
  # the javascript typeof operator, as the argument is evaluated before
  # the function call.
  def typeof(value)
    `typeof #{value}`
  end

  # Use void to return undefined.
  def void(expr)
    # Could use `undefined` here, but this is closer to the intent of the method
    `void #{expr}`
  end

  # Call the global javascript function with the given arguments.
  def call(func, *args)
    g = case
    when `typeof window === 'object'` then `window`
    when `typeof global === 'object'` then `global`
    else raise "cannot determine global object, neither window or global is an object"
    end

    g.JS[func].JS.apply(g, args)
  end
  alias method_missing call

  extend self
end
