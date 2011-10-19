class NativeObject < BasicObject
  def self.new
    `{}`
  end

  def [](key)
    `self.hasOwnProperty(key) ? self[key] : null`
  end

  def []=(key, value)
    `self[key] = value`
  end

  ##
  # Returns +true+ if the receiver has a property +member+, +false+
  # otherwise. The object's native +hasOwnProperty()+ method is called
  # to determine the result.
  #
  #     $document.include? :some_random_property  # => false
  #     $document.include? :body                  # => true
  def include?(member)
    `self.hasOwnProperty(member)`
  end

  def to_hash
    hash = {}

    `
      for (var name in self) {
        if (self.hasOwnProperty(name)) {
          #{hash[`name`] = `self[name]`};
        }
      }
    `

    hash
  end

  def to_s
    `self.toString()`
  end

  def inspect
    "#<NativeObject: #{self}>"
  end
end

