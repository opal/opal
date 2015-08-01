h = {}

10_000.times do |i|
  h[Object.new] = i
end

10_000.times do |i|
  h.select!{|k, v| v > i}
end
