puts "in block fixtures"

module BlockSpecs
  class Yield
    def splat(*args)
      yield *args
    end

    def two_args
      yield 1, 2
    end

    def two_arg_array
      yield [1, 2]
    end

    def yield_splat_inside_block
      [1, 2].send(:each_with_index) { |*args| yield(*args) }
    end
  end
end
