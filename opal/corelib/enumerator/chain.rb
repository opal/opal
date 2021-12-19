class ::Enumerator
  class self::Chain < self
    def initialize(*enums)
      @enums = enums
      @iterated = []
      @object = self
    end

    def each(*args, &block)
      return to_enum(:each, *args) { size } unless block_given?

      @enums.each do |enum|
        @iterated << enum
        enum.each(*args, &block)
      end

      self
    end

    def size(*args)
      accum = 0
      @enums.each do |enum|
        size = enum.size(*args)
        return size if [nil, ::Float::INFINITY].include? size
        accum += size
      end
      accum
    end

    def rewind
      @iterated.reverse_each do |enum|
        enum.rewind if enum.respond_to? :rewind
      end
      @iterated = []
      self
    end

    def inspect
      "#<Enumerator::Chain: #{@enums.inspect}>"
    end
  end
end
