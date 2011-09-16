class Boolean

  def to_s
    # Yeah, this is another one for the wtf? collection. As the receiver
    # is a true or false literal, it is coerced into a Boolean object,
    # therefore it is always truthy. Therefore we comapre ourself with
    # true to see if we are actually true or false. We could instead do
    # `return self.valueOf() ? "true" : "false", but this way seems a
    # little faster..
    `return self == true ? "true" : "false";`
  end

  def ==(other)
    `return self.valueOf() === other.valueOf();`
  end
end

TRUE = true
FALSE = false

