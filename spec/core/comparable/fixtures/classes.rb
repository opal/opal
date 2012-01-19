module ComparableSpecs
  class Weird
    include Comparable

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def <=>(other)
      self.value <=> other.value
    end
  end
end
