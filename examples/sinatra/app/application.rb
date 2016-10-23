require 'opal'

def alert(msg)
  `alert(msg)`
  raise "an example exception with source-map powered backtrace"
end

alert "Hi there!"

