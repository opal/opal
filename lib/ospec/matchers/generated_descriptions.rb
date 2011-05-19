module Spec  
  module Matchers
    
    def self.last_matcher
      @last_matcher
    end
    
    def self.last_matcher=(last_matcher)
      @last_matcher = last_matcher
    end
    
    def self.last_should
      @last_should
    end
    
    def self.last_should=(last_should)
      @last_should = last_should
    end
  end
end
