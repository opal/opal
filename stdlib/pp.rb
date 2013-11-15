module Kernel
  def pretty_inspect; inspect; end

  if `(typeof console === "undefined" || typeof console.log === "undefined")`
    alias :pp :p
  else
    def pp *args
      args.each { |obj| `console.log(obj);` }
      args.length <= 1 ? args[0] : args
    end
  end
end
