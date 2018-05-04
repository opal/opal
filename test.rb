module Mixin
  def test_method
    "hello"
  end
  module_function :test_method
end

class BaseClass
  include Mixin
  def call_test_method
    test_method
  end
end

p Mixin.test_method
p "hello"

$c = BaseClass.new
p $c.call_test_method
p "hello"

module Mixin
  def test_method
    "goodbye"
  end
end

p Mixin.test_method
p "hello"

p $c.call_test_method
p "goodbye"
