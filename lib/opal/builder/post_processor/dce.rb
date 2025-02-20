# frozen_string_literal: true

require 'opal/builder/post_processor/dce/call_tree'

module Opal
  class Builder
    class PostProcessor
      class DCE < PostProcessor
        def self.enabled?(builder)
          builder.dce?
        end

        def initialize(_, _)
          super
          reset
        end

        def reset
          @call_tree = CallTree.new
          @sct = nil
        end

        def dce_status(message, idx = nil, len = nil)
          if $stderr.tty?
            if message == :finished
              $stderr.print "\r\e[K\r"
            else
              if idx && len
                message = "(#{(100.0 * idx / len).round(1)}%) " + message
              end
              $stderr.print "\r\e[K[opal/dce] #{message}\r"
            end
          end
        end

        def call
          # Return if DCE is not enabled.
          return processed unless DCE.enabled? builder

          process
        end

        def process
          len = processed.length

          # First, process what we have generated
          processed.each_with_index do |file, idx|
            dce_status "Processing #{file.filename}...", idx, len
            if file.respond_to? :compiled
              read_ruby(file.compiled)
            else
              read_js(file.source)
            end
          end

          # Then, do processing of the data we got
          dce_status 'Computing...'
          process_data

          # Finally, rebuild Ruby files
          processed.each_with_index do |file, idx|
            dce_status "Rebuilding #{file.filename}...", idx, len
            if file.respond_to? :compiled
              rebuild_ruby(file.compiled)
            end
          end

          dce_status :finished

          processed
        end

        OPERATOR_RE = Regexp.union(
          %i[
            ** << >> <= >= <=> === == !=
            =~ !~ +@ -@ []= [] ! + - * /
            % & | ^ ~ < >
          ].map(&:to_s)
        )

        # FIXME: Regexp issues with Opal
        METHOD_NAME_RE = if RUBY_ENGINE == 'opal'
                           /
                             (?:
                               [[A-Za-z]_][[A-Za-z0-9]_]*
                               (?:[!?=])?
                             |
                               #{OPERATOR_RE}
                             )
                           /x
                         else
                           /
                             (?:
                               [[:alpha:]_][[:alnum:]_]*
                               (?:[!?=])?
                             |
                               #{OPERATOR_RE}
                             )
                           /x
                         end

        # Identifiers defined on Opal, eg. Opal.def
        OPAL_IDENT_RE = /[a-zA-Z_][a-zA-Z0-9_]*/

        # This is needed for runtime. But we could strip some of those
        # and move more into `dce_use` and friends helper calls.
        METHOD_CALL_RE = /
          \.\$(#{METHOD_NAME_RE})                   |
          \['\$(#{METHOD_NAME_RE})'\]               |
          \["\$(#{METHOD_NAME_RE})"\]               |
          (?<!typeof\s)Opal\.(#{OPAL_IDENT_RE})     |
          (?<![\w$.]|function\s)\$(#{OPAL_IDENT_RE})
        /x

        def dce_directive?(frag)
          frag.is_a?(Directive) &&
            %i[dce_def_begin dce_def_end dce_use].include?(frag.name) &&
            (builder.dce + [:*]).include?(frag.params[:type])
        end

        def extract_names_from(str)
          str.scan(METHOD_CALL_RE).map(&:compact).map(&:first).map(&:to_sym)
        end

        def read_js(str)
          @call_tree.add_calls(extract_names_from(str))
        end

        def read_ruby(compiler)
          stack = []

          compiler.fragments.each do |frag|
            if dce_directive?(frag)
              case frag.name
              when :dce_def_begin
                stack << frag.params[:name]
                @call_tree.add_definitions(stack)
              when :dce_use
                @call_tree.add_calls(frag.params[:name], frag.params[:force] ? [] : stack)
              when :dce_def_end
                stack.pop
              end
            elsif !ignore_incoming?(frag)
              @call_tree.add_calls(extract_names_from(frag.code), stack)
            end
          end
        end

        # Apply some heuristics to skip regexp matching for certain
        # parts of the code.
        def ignore_incoming?(frag)
          if frag.respond_to?(:sexp) && frag.sexp
            case frag.sexp.type
            when :xstr, :str, :jscall # :top, :def, :defs
              false
            else
              true
            end
          else
            true
          end
        end

        # Dynamic calls for opal-parser. Those functions shouldn't
        # happen in typical code you want to DCE, but if your code
        # needs parser, this is required.
        def add_dynamic_calls
          begin
            [:_reduce_none, :_racc_do_parse_rb, /\A_reduce_\d+\z/, :Symbol, :Number]
          end.then { |i| @call_tree.add_calls(i) }
        end

        def process_data
          add_dynamic_calls
          @sct = ShadowedCallTree.new(@call_tree)
          @sct.process
        end

        ScopeIdent = Struct.new(:name, :handled, :placeholder)

        def readd_directive(new_fragments, frag, stack)
          new_fragments << frag if keep_definition?(stack)
        end

        def rebuild_ruby(compiler)
          new_fragments = []
          stack = []

          compiler.fragments.each do |frag|
            if dce_directive?(frag)
              case frag.name
              when :dce_def_begin
                stack << ScopeIdent.new(
                  frag.params[:name], false, frag.params[:placeholder]
                )
                readd_directive(new_fragments, frag, stack)
              when :dce_def_end
                readd_directive(new_fragments, frag, stack)
                stack.pop
              else
                readd_directive(new_fragments, frag, stack)
              end
            elsif keep_definition?(stack)
              new_fragments << frag
            elsif stack.none?(&:handled)
              func = stack.last
              new_fragments << Opal::Fragment.new(
                "#{func.placeholder}/* Removed by DCE: #{func.name} */",
                frag.scope,
                frag.sexp
              )
              func.handled = true
            end
          end

          compiler.fragments = new_fragments
        end

        def keep_definition?(stack)
          stack.empty? ||
            stack.all? do |idents|
              Array(idents.name).any? do |ident|
                @sct.keep_definition?(ident)
              end
            end
        end

        module NodeSupport
          def dce_def_begin(name, placeholder: nil, type: :method)
            placeholder ||= 'nil'
            placeholder += ' ' unless placeholder == ''
            post_processor_directive(
              :dce_def_begin, name: name, placeholder: placeholder, type: type
            )
          end

          def dce_def_end(name, type: :method)
            post_processor_directive(:dce_def_end, name: name, type: type)
          end

          def dce_use(name, type: :method, force: false)
            post_processor_directive(:dce_use, name: name, type: type, force: force)
          end
        end
      end

      register DCE
    end
  end
end
