`Opal.exit = process.exit`

module Kernel
  NODE_REQUIRE = `require`

  def caller
    %x{
      var stack;
      try {
        var err = Error("my error");
        throw err;
      } catch(e) {
        stack = e.stack;
      }
      return stack.$split("\n").slice(3);
    }
  end

  def node_require(path)
    `#{NODE_REQUIRE}(#{path.to_str})`
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
