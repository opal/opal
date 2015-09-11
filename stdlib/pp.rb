module Kernel
  def pretty_inspect
    inspect
  end

  def pp(*objs)
    objs.each {|obj|
      PP.pp(obj)
    }
    objs.size <= 1 ? objs.first : objs
  end
  module_function :pp
end

class PP
  class << self
    if `(typeof(console) === "undefined" || typeof(console.log) === "undefined")`
      def pp(obj, out=$stdout, width=79)
        p(*args)
      end
    else
      def pp(obj, out=$stdout, width=79)
        if String === out
          out + obj.inspect + "\n"
        else
          out << obj.inspect + "\n"
        end
      end
    end

    alias :singleline_pp :pp
  end
end
