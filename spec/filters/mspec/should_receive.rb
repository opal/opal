opal_filter "should_receive" do
  fails "Array#at tries to convert the passed argument to an Integer using #to_int"
  fails "Array#include? calls == on elements from left to right until success"
  fails "A block taking |a| arguments does not call #to_ary to convert a single yielded object to an Array"
end
