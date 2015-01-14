module Kernel
  def exit(status = true)
    `process.exit(status === true ? 0 : status)`
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
