# Browser demo. Check out your browsers' debug console to see these
puts "Hello, world! Running in the browser.."

# Generated code is debug friendly
"All code is generated to keep the same line as the original ruby"
puts "This code is generated from line #{__LINE__}, in file: #{__FILE__}"

# Opal supports inline javascript
title = `document.title`
puts "The document title is '#{title}'"

# Blocks
[1, 2, 3, 4, 5].each do |a|
  puts a
end

# method_missing is fully supported with full ruby naming
class ClassA
  def method_missing(method_id, *args)
    puts "Tried to call '#{method_id}' with: #{args.inspect}"
  end
end

@cls = ClassA.new
@cls.try_this
@cls.do_assign = "this won't work"
@cls['neither'] = :will_this
@cls.is_this_true?
@cls.no_its_not!
@cls + 'something to add'

# Full operator overloading
puts(1 + 2)
puts [1, 2, 3, 4][0]
puts [1, 2, 3, 4][-2]

# Exceptions work on top of native error/try/catch/throw
class CustomBrowserException < Exception; end

