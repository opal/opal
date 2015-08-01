h1 = {}
h2 = {}

a = []

1.upto(5_000) do |i|
  a[i] = Object.new
  h1[a[i]] = nil
end

2_501.upto(7_500) do |i|
  a[i] = Object.new
  h2[a[i]] = nil
end

500.times do
  h1.merge!(h2)
end

500.times do
  h2.merge!(h1){|k, v, v2| 42}
end
