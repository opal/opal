h1 = {}
h2 = {}

1.upto(5_000) do |i|
  h1[i.to_s] = nil
end

2_501.upto(7_500) do |i|
  h2[i.to_s] = nil
end

500.times do
  h1.merge!(h2)
end

500.times do
  h2.merge!(h1){|k, v, v2| 42}
end
