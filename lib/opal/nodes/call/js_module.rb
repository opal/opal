# frozen_string_literal: true

require 'opal/nodes/base'
require 'opal/nodes/call'

module Opal
  module Nodes
    class CallNode < Base
      # fs = ::JS.import("fs")
      add_special :import do # module: :JS
        if compiler.esm?
          name = compiler.esm_import(arglist.children[0].children.first)

          unless stmt?
            push "Opal.esm_imports[", expr(s(:str, name)), "]"
          end
        else
          push "require(", expr(arglist.children[0]), ")"
        end
      end

      # ::JS.export("func", proc{})
      add_special :export do # module: :JS
        if compiler.esm?
          name = compiler.esm_export(arglist.children[0].children.first)
          push "Opal.esm_exports[", expr(s(:str, name)), "] = ", expr(arglist.children[1])
        else
          push "exports[", expr(arglist.children[0]), "] = ", expr(arglist.children[1])
        end
      end
    end
  end
end
