module EnsureSpec
  class Container
    attr_reader :executed

    def initialize
      @executed = []
    end

    def raise_in_method_with_ensure
      @executed << :method
      raise "An Exception"
    ensure
      @executed << :ensure
    end

    def raise_and_rescue_in_method_with_ensure
      @executed << :method
      raise "An Exception"
    rescue
      @executed << :rescue
    ensure
      @executed << :ensure
    end

    def implicit_return_in_method_with_ensure
      :method
    ensure
      :ensure
    end

    def explicit_return_in_method_with_ensure
      return :method
    ensure
      return :ensure
    end
  end
end
