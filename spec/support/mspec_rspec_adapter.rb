module MSpecRSpecAdapter
  def expect(object)
    MSpecRSpecAdapterShould.new(object)
  end

  def eq(expected)
    MSpecRSpecAdapterEq.new(expected)
  end

  class MSpecRSpecAdapterEq < Struct.new(:object)
  end

  class MSpecRSpecAdapterShould < Struct.new(:object)
    def to(expectation)
      apply_expectation(:should, expectation)
    end

    def apply_expectation(type, expectation)
      if MSpecRSpecAdapterEq === expectation
        object.send(type) == expectation.object
      else
        object.send(type, expectation)
      end
    end

    def not_to
      apply_expectation(:should_not, expectation)
    end
    alias to_not not_to
  end
end

include MSpecRSpecAdapter unless defined? RSpec
