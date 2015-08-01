h = {}
a = []

10_000.times do |i|
  a[i] = Object.new
  h[a[i]] = nil
end

10_000.times do |i|
  h.delete(a[i])
end
