h1 = {}
h2 = {}

a = []

10_000.times do |i|
  a[i] = Object.new
  h1[a[i]] = nil
  h2[a[i]] = nil
end

1_000.times do
  h1 == h2
end
