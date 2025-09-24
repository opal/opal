# NOTE: run bin/format-filters after changing this file
opal_filter "Specs that use temporary files" do
  fails "A Symbol literal inherits the encoding of the magic comment and can have a binary encoding" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x94928>
  fails "The BEGIN keyword returns the top-level script's filename for __FILE__" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0xab0bc>
  fails "The return keyword at top level file loading stops file loading and execution" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level file requiring stops file loading and execution" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level stops file execution" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8>
  fails "The return keyword at top level within a begin fires ensure block before returning while loads file" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a begin fires ensure block before returning" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a begin is allowed in begin block" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a begin is allowed in ensure block" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a begin is allowed in rescue block" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a begin swallows exception if returns in ensure block" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a block is allowed" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within a class raises a SyntaxError" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within if is allowed" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
  fails "The return keyword at top level within while loop is allowed" # NoMethodError: undefined method `tmp' for #<MSpecEnv:0x6bbf8 @filename=nil>
end
