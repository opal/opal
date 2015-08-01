h = {}

10_000.times do |i|
  h[Object.new] = nil
end

5_000.times do
  h.to_a
end
