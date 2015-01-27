# 'asdf' =~ /(a)./
#
# p $'
# p $1
# p $2
# `console.log(2, $opal.gvars['1'])`
# b = $1
# `console.log(1, b)`
# nil

puts [*1..3].to_s
puts [*(1..3)].to_s
puts [*Object.new].to_s
