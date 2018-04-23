module M1
  def from_included_module
  end
end

class BasicObject
  include ::M1

  def basic_object
  end
end

module M1
  def from_included_module2
  end
end

if RUBY_ENGINE == 'opal'
  `console.log("Opal:")`
  `console.log(Opal.BasicObject.$$methods.sort())`
  `debugger`
  `123`
else
  puts "MRI:"
  p (BasicObject.instance_methods + BasicObject.private_instance_methods).sort
end
