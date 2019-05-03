# frozen_string_literal: true

require 'pathname'
require 'opal/version'
require 'opal/nodes/scope'
require 'opal/es6_modules_helpers'

module Opal
  module Nodes
    # Generates code for an entire file, i.e. the base sexp
    class TopNode < ScopeNode
      handle :top

      children :body

      def compile
        push version_comment unless compiler.es6_modules?

        if compiler.es6_modules?
          module_name = Opal::Compiler.module_name_from_paths(compiler.file)
          opening(module_name)
        else
          opening
        end

        in_scope do
          body_code = stmt(stmts)
          body_code = [body_code] unless body_code.is_a?(Array)

          if compiler.eval?
            add_temp '$nesting = self.$$is_a_module ? [self] : [self.$$class]'
          else
            add_temp 'self = Opal.top'
            add_temp '$nesting = []'
          end
          add_temp 'nil = Opal.nil'
          add_temp '$$$ = Opal.const_get_qualified'
          add_temp '$$ = Opal.const_get_relative'

          add_used_helpers
          add_used_operators
          line scope.to_vars

          compile_method_stubs
          compile_irb_vars
          compile_end_construct

          line body_code
        end

        if compiler.es6_modules?
          import_lines = compiler.requires.map do |module_path|
            Opal::ES6ModulesHelpers.generate_module_imports(module_path)
          end
          if compiler.required_trees.any?
            base_dir = Pathname.new(compiler.file).dirname

            compiler.required_trees.each do |module_path|
              # ES6 javascript import doesn't allow for import of directories, to support require_tree
              # the compiler must import each file in the tree separately
              import_lines << Opal::ES6ModulesHelpers.generate_directory_imports(base_dir, module_path)
            end
          end
          unshift(*import_lines.flatten) if import_lines.any?
          unshift("\n")
          unshift(version_comment)
        end

        closing
      end

      def opening(module_name = nil)
        if compiler.es6_modules?
          # to enable some webpack features for opal-webpack-loader it has to refer to the opal code from within webpack later on
          # so we give it a handle 'opal_code'
          line 'const opal_code = function() {'
          # global makes sure we get the webpack global context and its Opal.modules, and not a locally shielded Opal.modules
          line "  global.Opal.modules[#{module_name.inspect}] = function(Opal) {"
        elsif compiler.requirable?
          line "Opal.modules[#{Opal::Compiler.module_name(compiler.file).inspect}] = function(Opal) {"
        elsif compiler.eval?
          line '(function(Opal, self) {'
        else
          line '(function(Opal) {'
        end
      end

      def closing
        if compiler.es6_modules?
          line '  }'
          line "}\n"
          line "export default opal_code\n"
        elsif compiler.requirable?
          line "};\n"
        elsif compiler.eval?
          line '})(Opal, self)'
        else
          line "})(Opal);\n"
        end
      end

      def stmts
        compiler.returns(body)
      end

      def compile_irb_vars
        if compiler.irb?
          line 'if (!Opal.irb_vars) { Opal.irb_vars = {}; }'
        end
      end

      def add_used_helpers
        helpers = compiler.helpers.to_a
        helpers.to_a.each { |h| add_temp "$#{h} = Opal.#{h}" }
      end

      def add_used_operators
        operators = compiler.operator_helpers.to_a
        operators.each do |op|
          name = Nodes::CallNode::OPERATORS[op]
          line "function $rb_#{name}(lhs, rhs) {"
          line "  return (typeof(lhs) === 'number' && typeof(rhs) === 'number') ? lhs #{op} rhs : lhs['$#{op}'](rhs);"
          line '}'
        end
      end

      def compile_method_stubs
        if compiler.method_missing?
          calls = compiler.method_calls
          stubs = calls.to_a.map { |k| "'$#{k}'" }.join(', ')
          line "Opal.add_stubs([#{stubs}]);" unless stubs.empty?
        end
      end

      # Any special __END__ content in code
      def compile_end_construct
        if content = compiler.eof_content
          line 'var $__END__ = Opal.Object.$new();'
          line "$__END__.$read = function() { return #{content.inspect}; };"
        end
      end

      def version_comment
        "/* Generated by Opal #{Opal::VERSION} */"
      end
    end
  end
end
