h = {}

10_000.times do |i|
  h[Object.new] = nil
end

100.times do
  h.inspect
end
