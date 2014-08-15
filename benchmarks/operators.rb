t1 = Time.now

a = 0
100000.times do
  a = a + 1
end
puts a

puts Time.now - t1
