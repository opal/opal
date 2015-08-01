h = {}
a = []

10_000.times do |i|
  a[i] = Object.new
  h[a[i]] = nil
end

10_000.times do |i|
  h.has_key?(a[i])
end
