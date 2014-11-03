module Kernel
  def exit(status)
    `process.exit(status)`
  end
end

ARGV = `process.argv.slice(2)`

ENV = Object.new
def ENV.[]= name, value
  `process.env[#{name.to_s}] = #{value.to_s}`
end

def ENV.[] name
  `process.env[#{name}] || nil`
end
