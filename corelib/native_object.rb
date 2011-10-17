##
# +NativeObject+ is a class used to represent native javascript objects
# to opal. Whenever a message is sent to a native js object, then it will
# act like an instance of this class. If a method is not found, then the
# method name will be used to look up a raw property on the receiver, or
# even set a property value.
#
# It is not possible to create new instances of this class. +.new+ simply
# returns an empty javascript object, which you can interact with using
# the methods listed in this class.

class NativeObject < BasicObject

  def self.new
    `{}`
  end

  def [] key
    `self.hasOwnProperty(key) ? self[key] : null`
  end

  def []= key, val
    `self[key] = val`
  end

  ##
  # Returns +true+ if the receiver has a property +member+, +false+
  # otherwise. The object's native +hasOwnProperty()+ method is called
  # to determine the result.
  #
  #     $document.include? :some_random_property  # => false
  #     $document.include? :body                  # => true

  def include? member
    `self.hasOwnProperty(member)`
  end

  def to_hash
    hash = {}

    `for (var name in self) {
      if (self.hasOwnProperty(name)) {
        #{hash[`name`] = `self[name]`};
      }
    }`

    hash
  end

  def to_s
    `self.toString()`
  end

  def inspect
    `return "#<NativeObject: " + self.toString() + "#>";`
  end
end

