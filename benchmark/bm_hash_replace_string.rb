h1 = {}
h2 = {}

1.upto(5_000) do |i|
  h1[i.to_s] = nil
end

2_501.upto(7_500) do |i|
  h2[i.to_s] = nil
end

1_000.times do
  h1.replace(h2)
end
