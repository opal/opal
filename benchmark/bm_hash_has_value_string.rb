h = {}

10_000.times do |i|
  h[i.to_s] = i * 2
end

1_000.times do |i|
  h.has_value?(i * 2)
end
