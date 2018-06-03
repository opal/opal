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
        push version_comment unless compiler.es_six_imexable?

        if compiler.es_six_imexable?
          mod_name = self.class.module_name(compiler.file)
          opening(mod_name)
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

        if compiler.es_six_imexable?
          import_lines = compiler.requires.map do |module_path|
            # modules should have the ending .rb for imports, so that the opal-webpack-resolver-plugin
            # or the opal-webpack-loader don't mix them up with javascript imports
            # that is just a sensible convention for example, a require 'react', without ending:
            # import 'react';  --> resolves to react.js in javascript space, may be resolved by webpack otherwise
            # vs. with ending:
            # import 'react.rb';  --> resolves to react.rb in the opal/ruby space which gets transpiled to js by the loader
            # if a javascript file gets required by like: require 'runtime'
            # it gets imported like so: import 'runtime.rb'
            # the opal-webpack-resolver-plugin will then check for a runtime.rb, but also for a runtime.js if the runtime.rb is not found.
            real_m_path = if module_path.start_with?('/')
                            t_path = module_path.end_with?('.rb') ? module_path : module_path + '.rb'
                            self.class.module_name(t_path)
                          else
                            module_path
                          end
            i_name = import_name(module_path)
            i_line = []
            i_line << "import #{i_name} from '#{module_path}#{'.rb' unless module_path.end_with?('.js') || module_path.end_with?('.rb')}';\n"
            unless module_path == 'corelib/runtime'
              # webpack replaces i_name with a function, but
              # during bootstrapping on the client, when the imports are imported, for a circular import
              # i_name is just a object, because the outer i_name() did not finish execution and thus
              # the result of the webpack function looking up i_name is a object.
              # once the import returned, the result of the webpack function looking up i_name will be a function.
              # checking if i_name actually is a function will make the bootstrapping work,
              # at this time the i_name has not been imported into local context, luckily the opal require happens
              # later in time, after all the imports, then Opal.modules should be filled correctly and the opal require
              # can be resolved
              i_line << "if (typeof global.Opal.modules[#{real_m_path.inspect}] === 'undefined') {\n"
              i_line << "  if (typeof #{i_name} === 'function') { #{i_name}(); }\n"
              i_line << "}\n"
            end
            i_line
          end
          if compiler.required_trees.size > 0
            base_dir = Pathname.new(compiler.file).dirname

            compiler.required_trees.each do |module_path|
              # javascript import doesn't allow for import of directories, to support require_tree
              # the compiler must import each file in the tree separately
              import_child_paths(import_lines, base_dir, module_path)
            end
          end
          if import_lines.size > 0
            unshift(*import_lines.flatten)
          else
            unshift(version_comment)
          end
        end

        closing
      end

      def opening(mod_name = nil)
        if compiler.es_six_imexable?
          line "export default function() {"
          line "  global.Opal.modules[#{mod_name.inspect}] = function(Opal) {"
        elsif compiler.requirable?
          line "Opal.modules[#{Opal::Compiler.module_name(compiler.file).inspect}] = function(Opal) {"
        elsif compiler.eval?
          line '(function(Opal, self) {'
        else
          line '(function(Opal) {'
        end
      end

      def closing
        if compiler.es_six_imexable?
          line "  }"
          line "};\n"
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


      def self.module_name(filenamepath, original_filepath = nil, original_filename = nil)
        original_filename = filenamepath unless original_filename
        original_filepath = Pathname.new(filenamepath).realpath unless original_filepath
        o_s = original_filepath.to_s
        path, _ = Pathname.new(filenamepath).realpath.split
        if Opal.paths.include?(path.realpath.to_s)
          e = if o_s.end_with?('.js.rb')
                -7
              elsif o_s.end_with?('.rb') || o_s.end_with?('.js')
                -4
              else
                -1
              end
          return o_s[(path.realpath.to_s.size+1)..e]
        end
        if path.root?
          pwd = Dir.pwd
          if o_s.start_with?(pwd)
            e = if o_s.end_with?('.js.rb')
                  -7
                elsif o_s.end_with?('.rb') || o_s.end_with?('.js')
                  -4
                else
                  -1
                end
            return o_s[(pwd.size+1)..e]
          else
            return o_s
          end
        end
        module_name(path, original_filepath, original_filename)
      end

      private

      def import_name(m_name)
        m_name.gsub('.','o_').gsub('-','_').gsub('/','_').gsub('@','_at_') + rand(36**8).to_s(36)
      end

      def import_child_paths(import_lines, base_dir, module_path)
        directory_path = base_dir + module_path
        directory_path.each_child do |child_path|
          if child_path.directory?
            import_child_paths(import_lines, base_dir, child_path.realpath.to_s[(base_dir.realpath.to_s.length+1)..-1])
          elsif child_path.file?
            path_s = child_path.basename.to_s
            if path_s.end_with?('.rb') || path_s.end_with?('.js')
              module_path = child_path.realpath.to_s[(base_dir.realpath.to_s.length+1)..-4]
              i_name = import_name(module_path + path_s[-3..-1])
              import_lines << "import #{i_name} from '#{module_path}#{path_s[-3..-1]}';\n"
              import_lines << "if (typeof Opal.modules[#{module_path.inspect}] === 'undefined') {\n"
              import_lines << "  if (typeof #{i_name} === 'function') { #{i_name}(); }\n"
              import_lines << "}\n"
              import_lines
            end
          end
        end
      end
    end
  end
end
