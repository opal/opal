klass = Class.new do
  class Howdy
  end

  def self.get_class_name
    Howdy.name
  end
end

p Howdy.name
p klass.get_class_name


`debugger`

123
