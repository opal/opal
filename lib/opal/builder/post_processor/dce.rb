# frozen_string_literal: true

# rubocop:disable Style/CaseEquality

module Opal
  class Builder
    class PostProcessor
      class DCE < PostProcessor
        def self.enabled?(builder)
          builder.dce?
        end

        def initialize(_, _)
          super
          # We build two hashes. One is keyed by Symbols,
          # another is keyed by matchers (eg. regexps).
          # They have the same purpose, except that the
          # first one is faster to use.
          @call_tree = Hash.new { |a, b| a[b] = Set.new }
          @call_tree_matcher = Hash.new { |a, b| a[b] = Set.new }

          # Similarly, at a later step, we build two sets.
          # The second set contains matchers.
          @needed = nil
          @needed_matcher = nil
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

        OPERATOR_RE = /
          # Operator method names:
          (?:
            \*\*    |
            <<      |
            >>      |
            <=      |
            >=      |
            <=>     |
            ===     |
            ==      |
            !=      |
            =~      |
            !~      |
            \+@     |
            -@      |
            \[\]=   |
            \[\]    |
            [!+\-*\/%&|\^~<>]
          )
        /x

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

        OPAL_IDENT_RE = /
          [a-zA-Z_][a-zA-Z0-9_]*
        /x

        # This is needed for runtime. But we could strip some of those
        # and move more into `dce_use` and friends helper calls.
        METHOD_CALL_RE = /
          \.\$(#{METHOD_NAME_RE})      |
          \['\$(#{METHOD_NAME_RE})'\]  |
          \["\$(#{METHOD_NAME_RE})"\]  |
          Opal\.(#{OPAL_IDENT_RE})     |
          (?<![\w$])\$(#{OPAL_IDENT_RE})
        /x

        def extract_names_from(str)
          str.scan(METHOD_CALL_RE).map(&:compact).map(&:first).map(&:to_sym)
        end

        def read_js(str)
          append_call_tree(nil, extract_names_from(str))
        end

        def read_ruby(compiler)
          function_stack = []

          compiler.fragments.each do |frag|
            current_function = function_stack.last
            if frag.is_a? Directive
              case frag.name
              when :dce_def_begin
                function_stack << frag.params[:name]
              when :dce_use
                append_call_tree(current_function, frag.params[:name])
              when :dce_def_end
                function_stack.pop
              end
            elsif !ignore_incoming?(frag)
              append_call_tree(current_function, extract_names_from(frag.code))
            end
          end
        end

        def matcher?(function)
          case function
          when nil, Symbol
            false
          else
            true
          end
        end

        def append_call_tree(function, names)
          if matcher? function
            @call_tree_matcher[function] += Array(names)
          else
            @call_tree[function] += Array(names)
          end
        end

        # Apply some heuristics to skip regexp matching for certain
        # parts of the code.
        def ignore_incoming?(frag)
          if frag.respond_to?(:sexp) && frag.sexp
            case frag.sexp.type
            when :top
              true
            else
              false
            end
          else
            false
          end
        end

        # Dynamic calls for opal-parser. Those functions shouldn't
        # happen in typical code you want to DCE, but if your code
        # needs parser, this is required.
        def add_dynamic_calls
          append_call_tree nil,
                           [/\A_reduce_\d+\z/, :_reduce_none, :_racc_do_parse_rb]
        end

        def process_data
          @needed = Set.new
          @needed_matcher = Set.new
          add_dynamic_calls
          add_requirement
        end

        # Adds an item to the @needed array so that we know
        # which functions we need to keep. In addition, we recurse
        # this function over all requirements of said item.
        def add_requirement(item = nil)
          return if @needed.include?(item) || @needed_matcher.include?(item)

          matched_additional = Set.new

          if matcher? item
            @needed_matcher << item
            matched_additional += @call_tree.keys.select { |key| item === key }
          else
            @needed << item
          end

          @call_tree[item].each do |i|
            add_requirement(i)
          end
          @call_tree_matcher.each do |matcher, array|
            if matcher === item
              add_requirement(matcher)
              array.each do |i|
                add_requirement(i)
              end
            end
          end
          matched_additional.each do |i|
            add_requirement(i)
          end
        end

        CurrentFunction = Struct.new(:name, :handled, :placeholder)

        def rebuild_ruby(compiler)
          new_fragments = []
          current_function = []

          compiler.fragments.each do |frag|
            if frag.is_a? Directive
              case frag.name
              when :dce_def_begin
                current_function << CurrentFunction.new(
                  frag.params[:name], false, frag.params[:placeholder]
                )
              when :dce_def_end
                current_function.pop
              when :dce_use
              else
                new_fragments << frag
              end
            elsif keep_function?(current_function)
              new_fragments << frag
            elsif current_function.none?(&:handled)
              func = current_function.last
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

        def keep_function?(function_stack)
          function_stack.empty? ||
            function_stack.any? do |func|
              if matcher? func.name
                @needed_matcher.include?(func.name) ||
                  @needed.any? { |i| func.name === i }
              else
                @needed.include?(func.name) ||
                  @needed_matcher.any? { |matcher| matcher === func.name }
              end
            end
        end

        module NodeSupport
          def dce_def_begin(name, placeholder: nil)
            placeholder ||= 'nil'
            placeholder += ' ' unless placeholder == ''
            post_processor_directive(
              :dce_def_begin, name: name, placeholder: placeholder
            )
          end

          def dce_def_end(name)
            post_processor_directive(:dce_def_end, name: name)
          end

          def dce_use(name)
            post_processor_directive(:dce_use, name: name)
          end
        end
      end

      register DCE
    end
  end
end

# rubocop:enable Style/CaseEquality
