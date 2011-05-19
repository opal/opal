
module Spec
  
  module Example
    
    class ExampleGroup
      
      extend Spec::Example::ExampleGroupMethods
      include Spec::Example::ExampleMethods
    end
  end
end
