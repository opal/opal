# The {Enumerable} module.
module Enumerable

  # Returns an array containing the items in the receiver.
  #
  # @example
  #
  #     (1..4).to_a       # => [1, 2, 3, 4]
  #     [1, 2, 3].to_a    # => [1, 2, 3]
  #
  # @return [Array]
  def to_a
    ary = []
    each { |arg| `ary.push(arg);` }
    ary
  end

  alias_method :entries, :to_a

  def collect(&block)
    raise "Enumerable#collect no block given" unless block_given?
    `var result = [];`

    each do |*args|
      `result.push(#{block.call *args});`
    end

    `return result;`
  end

  alias_method :map, :collect
end

