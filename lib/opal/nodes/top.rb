# frozen_string_literal: true

require 'pathname'
require 'opal/version'
require 'opal/nodes/scope'

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
            # modules should have the ending .rb for imports, so that the opal-webpack-resolver-plugin
            # or the opal-webpack-loader don't mix them up with javascript imports
            # that is just a sensible convention for example, a require 'react', without ending:
            #   import 'react';  --> resolves to react.js in javascript space, may be resolved by webpack otherwise
            # vs. with ending:
            #   import 'react.rb';  --> resolves to react.rb in the opal/ruby space which gets transpiled to js by the loader
            # if a javascript file gets required as:
            #   require 'runtime'
            # it gets imported like so:
            #   import 'runtime.rb'
            # the opal-webpack-resolver-plugin will then check for a runtime.rb, but also for a runtime.js if the runtime.rb is not found.
            real_module_name = if module_path.start_with?('/')
                                 module_path_rb = module_path.end_with?('.rb') ? module_path : module_path + '.rb'
                                 Opal::Compiler.module_name_from_paths(module_path_rb)
                               else
                                 module_path
                               end
            # in ruby its legal to require the same module several times, in webpack es6 importing the same module only works, if the import name
            # is different, using the same import will result in a error.
            # As large ruby projects tend to require the same module in a context several times, the import name must be different
            # for each import. here a random inport name is generated. webpack will make sure, that the code the different imports refer to,
            # is imported only once
            module_import_name = generate_import_name(module_path)
            module_import_lines = []
            has_extension = module_path.end_with?('.js', '.rb')
            module_import_lines << "import #{module_import_name} from '#{module_path}#{'.rb' unless has_extension}';\n"
            unless module_path == 'corelib/runtime'
              # webpack replaces module_import_name with a function, but
              # during bootstrapping on the client, when the imports are imported, for a circular import
              # module_import_name is just a object, because the outer module_import_name() did not finish execution and thus
              # the result of the webpack function looking up module_import_name is not a function yet.
              # once the import returned, the result of the webpack function looking up module_import_name will be a function.
              # checking if module_import_name actually is a function will make the bootstrapping work,
              # at this time the module_import_name has not been imported into local context, luckily the opal require happens
              # later in time, after all the imports, then Opal.modules is filled correctly and the opal require
              # can be resolved
              #
              # This behaviour is needed for all modules, except corelib/runtime!
              module_import_lines << "if (typeof global.Opal.modules[#{real_module_name.inspect}] === 'undefined') {\n"
              module_import_lines << "  if (typeof #{module_import_name} === 'function') { #{module_import_name}(); }\n"
              module_import_lines << "}\n"
            end
            module_import_lines
          end
          if compiler.required_trees.any?
            base_dir = Pathname.new(compiler.file).dirname

            compiler.required_trees.each do |module_path|
              # javascript import doesn't allow for import of directories, to support require_tree
              # the compiler must import each file in the tree separately
              import_child_paths(import_lines, base_dir, module_path)
            end
          end
          unshift(*import_lines.flatten) if import_lines.any?
          unshift(version_comment)
        end

        closing
      end

      def opening(module_name = nil)
        if compiler.es6_modules?
          line 'export default function() {'
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

      private

      def generate_import_name(module_name)
        # generate random import name for a ruby module_name. Also replaces some characters that are illegal in JS import names.
        module_name.gsub('.', 'o_').tr('-', '_').tr('/', '_').gsub('@', '_at_') + rand(36**8).to_s(36)
      end

      def import_child_paths(import_lines, base_dir, module_path)
        # recursively walk a directory and generate import lines for all .rb/.js files
        directory_path = base_dir + module_path
        directory_path.each_child do |child_path|
          if child_path.directory?
            import_child_paths(import_lines, base_dir, child_path.expand_path.to_s[(base_dir.expand_path.to_s.length + 1)..-1])
          elsif child_path.file?
            path_s = child_path.basename.to_s
            if path_s.end_with?('.rb', '.js')
              module_path = child_path.expand_path.to_s[(base_dir.expand_path.to_s.length + 1)..-4]
              import_name = generate_import_name(module_path + path_s[-3..-1])
              import_lines << "import #{import_name} from '#{module_path}#{path_s[-3..-1]}';\n"
              import_lines << "if (typeof Opal.modules[#{module_path.inspect}] === 'undefined') {\n"
              import_lines << "  if (typeof #{import_name} === 'function') { #{import_name}(); }\n"
              import_lines << "}\n"
              import_lines
            end
          end
        end
      end
    end
  end
end
