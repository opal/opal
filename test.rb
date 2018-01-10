old_methods_of = ->(obj, all = true) do
  %x{
    var methods = [];

    for (var key in obj) {
      if (key[0] == "$" && typeof(obj[key]) === "function") {
        if (all == false || all === nil) {
          if (!Opal.hasOwnProperty.call(obj, key)) {
            continue;
          }
        }
        if (obj[key].$$stub === undefined) {
          methods.push(key.substr(1));
        }
      }
    }

    return methods;
  }
end

new_methods_of = ->(object, all = true) do
  %x{
    return object.$$methods || [];
  }
end

check = ->(object, methods_of, kind) do
  puts "#{object.class} (#{kind}):"
  puts "Keys (#{kind}): #{`Object.keys(object)`.sort.uniq.inspect}"
  puts "All = true (#{kind}):  #{methods_of.call(object, true).sort.uniq.inspect}"
  puts "All = false (#{kind}): #{methods_of.call(object, false).sort.uniq.inspect}"
  puts
end

# check.call(BasicObject.new, old_methods_of, 'old')
# check.call(BasicObject.new, new_methods_of, 'new')

# module M
#   def in_module
#   end
# end

# class Object
#   def inline
#   end

#   include M
# end

check.call(Object.new, old_methods_of, 'old')
check.call(Object.new, new_methods_of, 'new')

# check.call(Array.new, old_methods_of)
# check.call(Array.new, new_methods_of)

# check.call(Array, old_methods_of)
# check.call(Array, new_methods_of)

# check.call(Kernel, old_methods_of)
# check.call(Kernel, new_methods_of)

`debugger`

123
