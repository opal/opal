class OSpecFilter
  def self.main
    @main ||= self.new
  end

  def initialize
    @filters = {}
  end

  def register
    MSpec.register :exclude, self
  end

  def ===(description)
    @filters.has_key? description
  end

  def register_filters(description, block)
    instance_eval(&block)
  end

  def fails(description)
    @filters[description] = true
  end
end

class Object
  def opal_filter(description, &block)
    OSpecFilter.main.register_filters(description, block)
  end
end

