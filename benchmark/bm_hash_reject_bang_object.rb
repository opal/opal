h = {}

10_000.times do |i|
  h[Object.new] = i
end

10_000.times do |i|
  h.reject!{|k, v| v <= i}
end
