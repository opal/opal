h = {}

10_000.times do |i|
  h[i.to_s] = i
end

1_000.times do
  h.keep_if{|k, v| v % 2 == 0}
end
