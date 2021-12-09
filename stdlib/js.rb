# The JS module provides syntax sugar for calling native javascript
# operators (e.g. typeof, instanceof, new, delete) and global functions
# (e.g. parseFloat, parseInt).
module JS
  # Use delete to remove a property from an object.
  def delete(object, property)
    `delete #{object}[#{property}]`
  end

  # The global object
  def global
    `Opal.global`
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
  if `typeof Function.prototype.bind == 'function'`
    def new(func, *args, &block)
      args.insert(0, `this`)
      args << block if block
      `new (#{func}.bind.apply(#{func}, #{args}))()`
    end
  else
    def new(func, *args, &block)
      args << block if block
      f = `function(){return func.apply(this, args)}`
      f.JS[:prototype] = func.JS[:prototype]
      `new f()`
    end
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
  def call(func, *args, &block)
    g = global
    args << block if block
    g.JS[func].JS.apply(g, args)
  end

  def [](name)
    `Opal.global[#{name}]`
  end

  alias method_missing call

  extend self
end
