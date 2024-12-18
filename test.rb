require 'opal'
puts 'ready'

t = String.new('bla')
puts t
puts t.size
puts `t.length`

t << 'haha'
puts t
puts t.size
puts `t.length`
