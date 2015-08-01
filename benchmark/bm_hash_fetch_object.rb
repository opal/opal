h = {}
a = []

10_000.times do |i|
  a[i] = Object.new
  h[a[i]] = nil
end

1_000.times do |i|
  h.fetch(a[i])
end
