module EnumerableSpecs
  class Numerous
    include Enumerable
    def initialize(*list)
      @list = list.empty? ? [2, 5, 3, 6, 1, 4] : list
    end

    def each
      @list.each { |i| yield i }
    end
  end

  class Empty
    include Enumerable
    def each
    end
  end

  class ThrowingEach
    include Enumerable
    def each
      raise "from each"
    end
  end

  class EachDefiner
    include Enumerable

    attr_reader :arr

    def initialize(*args)
      @arr = arr
    end

    def each
      i = 0
      loop do
        break if i == @arr.size
        yield @arr[i]
        i += 1
      end
    end
  end
end