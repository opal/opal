h = {}

10_000.times do |i|
  h[i.to_s] = nil
end

10_000.times do |i|
  k, v = h.assoc(i.to_s)
end
