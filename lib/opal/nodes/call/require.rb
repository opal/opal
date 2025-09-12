# frozen_string_literal: true

require 'opal/nodes/base'
require 'opal/nodes/call'

module Opal
  module Nodes
    class CallNode
      add_special :require do |compile_default|
        str = DependencyResolver.new(compiler, arglist.children[0]).resolve
        compiler.track_require str unless str.nil?
        compile_default.call
      end

      add_special :require_relative do
        arg = arglist.children[0]
        file = compiler.file
        if arg.type == :str
          dir = File.dirname(file)
          compiler.track_require Pathname(dir).join(arg.children[0]).cleanpath.to_s
        end
        push fragment("#{scope.self}.$require(#{file.inspect}+ '/../' + ")
        push process(arglist)
        push fragment(')')
      end

      add_special :autoload do |compile_default|
        args = arglist.children
        if args.length == 2 && args[0].type == :sym
          str = DependencyResolver.new(compiler, args[1], :ignore).resolve
          if str.nil?
            compiler.warning "File for autoload of constant '#{args[0].children[0]}' could not be bundled!"
          else
            compiler.track_require str
            compiler.autoloads << str
          end
        end
        compile_default.call
      end

      add_special :require_tree do |compile_default|
        first_arg, *rest = *arglist.children
        if first_arg.type == :str
          relative_path = first_arg.children[0]
          compiler.required_trees << relative_path

          dir = File.dirname(compiler.file)
          full_path = Pathname(dir).join(relative_path).cleanpath.to_s
          full_path.force_encoding(relative_path.encoding)
          first_arg = first_arg.updated(nil, [full_path])
        end
        @arglist = arglist.updated(nil, [first_arg] + rest)
        compile_default.call
      end

      class DependencyResolver
        def initialize(compiler, sexp, missing_dynamic_require = nil)
          @compiler = compiler
          @sexp = sexp
          @missing_dynamic_require = missing_dynamic_require || @compiler.dynamic_require_severity
        end

        def resolve
          handle_part @sexp
        end

        def handle_part(sexp, missing_dynamic_require = @missing_dynamic_require)
          if sexp
            case sexp.type
            when :str
              return sexp.children[0]
            when :dstr
              return sexp.children.map { |i| handle_part i }.join
            when :begin
              return handle_part sexp.children[0] if sexp.children.length == 1
            when :send
              recv, meth, *args = sexp.children

              parts = args.map { |s| handle_part(s, :ignore) }

              return nil if parts.include? nil

              if recv.is_a?(::Opal::AST::Node) && recv.type == :const && recv.children.last == :File
                case meth
                when :expand_path
                  return expand_path(*parts)
                when :join
                  return expand_path parts.join('/')
                when :dirname
                  return expand_path parts[0].split('/')[0...-1].join('/')
                end
              # elsif meth == :__dir__
              #   return File.dirname(Opal::Compiler.module_name(@compiler.file))
              end
            end
          end

          case missing_dynamic_require
          when :error
            @compiler.error 'Cannot handle dynamic require', @sexp.line
          when :warning
            @compiler.warning 'Cannot handle dynamic require', @sexp.line
          end
        end

        def expand_path(path, base = '')
          "#{base}/#{path}".split('/').each_with_object([]) do |part, p|
            if part == ''
              # we had '//', so ignore
            elsif part == '..'
              p.pop
            else
              p << part
            end
          end.join '/'
        end
      end
    end
  end
end
