h = {}

10_000.times do |i|
  h[Object.new] = nil
end

1_000_000.times do
  k, v = h.shift
  h[k] = v
end
