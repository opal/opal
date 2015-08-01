h = {}

10_000.times do |i|
  h[Object.new] = i * 2
end

1_000.times do |i|
  h.has_value?(i * 2)
end
