`Opal.get_singleton_class(Opal.Object)`

module Kernel
  def test_m
    'm1'
  end
end

p Object.test_m

# `window.DEBUG = true`

puts "\n" * 5

module Kernel
  def test_m
    'm2'
  end
end

p Object.test_m
