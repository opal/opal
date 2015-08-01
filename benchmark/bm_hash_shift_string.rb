h = {}

10_000.times do |i|
  h[i.to_s] = nil
end

1_000_000.times do
  k, v = h.shift
  h[k] = v
end
