module IncludedInObject
  module IncludedModuleSpecs
  end
end

class Object
  include IncludedInObject
end

module IncludedModuleSpecs; end
p IncludedModuleSpecs.name

# `debugger`

# 123
