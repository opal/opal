
require 'ospec/expectations/fail_with'
require 'ospec/expectations/handler'
require 'ospec/expectations/errors'

module Kernel
  
  def should(matcher = nil, message = nil, &block)
    r = Spec::Expectations::PositiveExpectationHandler.handle_matcher self, 
                                                                  matcher, 
                                                                  message
  end
  
  def should_not(matcher = nil, message = nil, &block)
    Spec::Expectations::NegativeExpectationHandler.handle_matcher self,
                                                                  matcher,
                                                                  message
  end
end
