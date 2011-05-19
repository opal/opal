module Spec
  module Expectations

    def self.fail_with(message, expected = nil, target = nil)
      raise Spec::Expectations::ExpectationNotMetError.new(message)
    end
  end
end

