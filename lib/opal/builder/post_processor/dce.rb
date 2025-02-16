# frozen_string_literal: true

module Opal
  class Builder
    class PostProcessor
      class DCE < PostProcessor
        def self.enabled?(builder)
          builder.dce?
        end

        def initialize(_, _)
          super
          @call_tree = Hash.new { |a, b| a[b] = Set.new }
          @needed = nil
        end

        def call
          # Return if DCE is not enabled.
          return processed unless DCE.enabled? builder

          # First, process what we have generated
          processed.each do |file|
            if file.respond_to? :compiled
              read_ruby(file.compiled)
            else
              read_js(file.source)
            end
          end

          # Then, do processing of the data we got
          process_data

          # Finally, rebuild Ruby files
          processed.each do |file|
            if file.respond_to? :compiled
              rebuild_ruby(file.compiled)
            end
          end
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
          [a-zA-Z0-9_]+
        /x

        # This is needed for runtime. But we could strip some of those
        # and move more into `dce_use` and friends helper calls.
        METHOD_CALL_RE = /
          \.\$(#{METHOD_NAME_RE})      |
          \['\$(#{METHOD_NAME_RE})'\]  |
          \["\$(#{METHOD_NAME_RE})"\]  |
          Opal\.(#{OPAL_IDENT_RE})     |
          \$(#{OPAL_IDENT_RE})
        /x

        def extract_names_from(str)
          str.scan(METHOD_CALL_RE).map(&:compact).map(&:first).map(&:to_sym)
        end

        def read_js(str)
          @call_tree[nil] += extract_names_from(str)
        end

        def read_ruby(compiler)
          current_function = []

          compiler.fragments.each do |frag|
            if frag.is_a? Directive
              case frag.name
              when :dce_def_begin
                current_function << frag.params[:name]
              when :dce_use
                @call_tree[current_function.last] << frag.params[:name]
              when :dce_def_end
                current_function.pop
              end
            end
            @call_tree[current_function.last] += extract_names_from(frag.code)
          end
        end

        # Dynamic calls for opal-parser. Those functions shouldn't
        # happen in typical code you want to DCE, but if your code
        # needs parser, this is required.
        def add_dynamic_calls
          @call_tree[nil] +=
            (1..800).map { |i| :"_reduce_#{i}" } +
            %i[_reduce_none _racc_do_parse_rb]
        end

        def process_data
          @needed = Set.new
          add_dynamic_calls
          add_requirement
        end

        def add_requirement(item = nil)
          return if @needed.include? item
          @needed << item
          @call_tree[item].each do |i|
            add_requirement(i)
          end
        end

        CurrentFunction = Struct.new(:name, :handled, :no_nil)

        def rebuild_ruby(compiler)
          new_fragments = []
          current_function = []

          compiler.fragments.each do |frag|
            if frag.is_a? Directive
              case frag.name
              when :dce_def_begin
                current_function << CurrentFunction.new(
                  frag.params[:name], false, frag.params[:no_nil]
                )
              when :dce_def_end
                current_function.pop
              when :dce_use
              else
                new_fragments << frag
              end
            elsif current_function.all? { |func| @needed.include?(func.name) }
              new_fragments << frag
            elsif current_function.none?(&:handled)
              func = current_function.last
              new_fragments << Opal::Fragment.new(
                "#{func.no_nil ? '' : 'nil '}/* Removed by DCE: #{func.name} */",
                frag.scope,
                frag.sexp
              )
              func.handled = true
            end
          end

          compiler.fragments = new_fragments
        end

        module NodeSupport
          def dce_def_begin(name, no_nil: false)
            post_processor_directive(
              :dce_def_begin, name: name, no_nil: no_nil
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
