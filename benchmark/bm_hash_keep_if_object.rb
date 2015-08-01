h = {}

10_000.times do |i|
  h[Object.new] = i
end

1_000.times do
  h.keep_if{|k, v| v % 2 == 0}
end
