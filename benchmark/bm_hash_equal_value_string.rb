h1 = {}
h2 = {}

10_000.times do |i|
  h1[i.to_s] = nil
  h2[i.to_s] = nil
end

1_000.times do
  h1 == h2
end
