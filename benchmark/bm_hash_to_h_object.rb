class MyHash < Hash; end
h = MyHash.new

10_000.times do |i|
  h[Object.new] = nil
end

1_000.times do
  h.to_h
end
