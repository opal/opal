# Why .$$is_number is better than isNaN:
#
#
# Warming up --------------------------------------
#         .$$is_number   106.722k i/100ms
#              isNaN()   105.040k i/100ms
#      obj.$$is_number   106.864k i/100ms
#           isNaN(obj)    89.287k i/100ms
# Calculating -------------------------------------
#         .$$is_number     12.052M (± 6.6%) i/s -     59.978M in   5.002614s
#              isNaN()     12.338M (± 5.4%) i/s -     61.448M in   4.997957s
#      obj.$$is_number     12.514M (± 6.8%) i/s -     62.302M in   5.005715s
#           isNaN(obj)      4.211M (± 5.9%) i/s -     20.982M in   5.001643s
#
# Comparison:
#      obj.$$is_number: 12513664.2 i/s
#              isNaN(): 12338259.3 i/s - same-ish: difference falls within error
#         .$$is_number: 12051756.8 i/s - same-ish: difference falls within error
#           isNaN(obj):  4211175.7 i/s - 2.97x  slower
#
Benchmark.ips do |x|
  number = 123
  number_obj = 123.itself
  x.report(".$$is_number")    { number.JS['$$is_number'] }
  x.report("isNaN()")         { `!isNaN(number)` }
  x.report("obj.$$is_number") { number_obj.JS['$$is_number'] }
  x.report("isNaN(obj)")      { `!isNaN(number_obj)` }
  x.compare!
end
