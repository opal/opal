h = {}

10_000.times do |i|
  h[Object.new] = i
end

100.times do |i|
  h.select{|k, v| v % 2 == 0}
end
