module Kernel
  def exit status = 0
    `callPhantom(["exit", #{status}]);`
  end
end
