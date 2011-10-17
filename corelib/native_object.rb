class NativeObject

  def [](key)
    `self.hasOwnProperty(key) ? self[key] : null`
  end

  def []= (key, val)
    `self[key] = val`
  end

  def to_hash
    hash = {}
    obj  = @native

    `
      for (var name in obj) {
        if (obj.hasOwnProperty(name)) {
          #{hash[`name`] = `obj[name]`};
        }
      }
    `
    hash
  end

  def to_s
    "#<NativeObject>"
  end

  alias_method :inspect, :to_s
end
