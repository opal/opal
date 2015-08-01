h = {}

10_000.times do |i|
  h[Object.new] = i
end

1_000.times do |i|
  k, v = h.rassoc(i)
end
