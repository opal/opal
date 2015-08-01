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

1_000.times do
  h1.replace(h2)
end
