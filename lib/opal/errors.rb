module Opal
  # raised if Gem not found in Opal#use_gem
  class GemNotFound < StandardError
    # name of gem that not found
    attr_reader :gem_name

    # @param gem_name [String] name of gem that not found
    def initialize(gem_name)
      @gem_name = gem_name
      super("can't find gem #{gem_name}")
    end
  end
end
