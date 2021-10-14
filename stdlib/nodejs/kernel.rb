# use_strict: true
# frozen_string_literal: true

`Opal.exit = process.exit`

module Kernel
  NODE_REQUIRE = `require`

  # @deprecated Please use `require('module')` instead
  def node_require(path)
    warn '[DEPRECATION] node_require is deprecated. Please use `require(\'module\')` instead.'
    `#{NODE_REQUIRE}(#{path.to_str})`
  end
end

ARGV = `process.argv.slice(2)`
