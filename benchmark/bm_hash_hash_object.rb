h = {}

1_000.times do |i|
  h[Object.new] = nil
end

100.times do |i|
  h.hash
end
