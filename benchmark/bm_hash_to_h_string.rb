class MyHash < Hash; end
h = MyHash.new

10_000.times do |i|
  h[i.to_s] = nil
end

1_000.times do
  h.to_h
end
