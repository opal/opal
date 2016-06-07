require 'opal/regexp_anchors'

module Opal
  module Nodes
    module Helpers

      # Reserved javascript keywords - we cannot create variables with the
      # same name (ref: http://stackoverflow.com/a/9337272/601782)
      ES51_RESERVED_WORD = /#{REGEXP_START}(?:do|if|in|for|let|new|try|var|case|else|enum|eval|false|null|this|true|void|with|break|catch|class|const|super|throw|while|yield|delete|export|import|public|return|static|switch|typeof|default|extends|finally|package|private|continue|debugger|function|arguments|interface|protected|implements|instanceof)#{REGEXP_END}/

      # ES3 reserved words that aren’t ES5.1 reserved words
      ES3_RESERVED_WORD_EXCLUSIVE = /#{REGEXP_START}(?:int|byte|char|goto|long|final|float|short|double|native|throws|boolean|abstract|volatile|transient|synchronized)#{REGEXP_END}/

      # Prototype special properties.
      PROTO_SPECIAL_PROPS = /#{REGEXP_START}(?:constructor|displayName|__proto__|__parent__|__noSuchMethod__|__count__)#{REGEXP_END}/

      # Prototype special methods.
      PROTO_SPECIAL_METHODS = /#{REGEXP_START}(?:hasOwnProperty|valueOf)#{REGEXP_END}/

      # Immutable properties of the global object
      IMMUTABLE_PROPS = /#{REGEXP_START}(?:NaN|Infinity|undefined)#{REGEXP_END}/

      # Doesn't take in account utf8
      BASIC_IDENTIFIER_RULES = /#{REGEXP_START}[$_a-z][$_a-z\d]*#{REGEXP_END}/i

      # Defining a local function like Array may break everything
      RESERVED_FUNCTION_NAMES = /#{REGEXP_START}(?:Array)#{REGEXP_END}/


      def property(name)
        valid_name?(name) ? ".#{name}" : "[#{name.inspect}]"
      end

      def valid_name?(name)
        BASIC_IDENTIFIER_RULES =~ name and not(
          ES51_RESERVED_WORD          =~ name or
          ES3_RESERVED_WORD_EXCLUSIVE =~ name or
          IMMUTABLE_PROPS             =~ name
        )
      end

      def variable(name)
        valid_name?(name.to_s) ? name : "#{name}$"
      end

      def valid_ivar_name?(name)
        not (PROTO_SPECIAL_PROPS =~ name or PROTO_SPECIAL_METHODS =~ name)
      end

      def ivar(name)
        valid_ivar_name?(name.to_s) ? name : "#{name}$"
      end

      # Converts a ruby method name into its javascript equivalent for
      # a method/function call. All ruby method names get prefixed with
      # a '$', and if the name is a valid javascript identifier, it will
      # have a '.' prefix (for dot-calling), otherwise it will be
      # wrapped in brackets to use reference notation calling.
      def mid_to_jsid(mid)
        if /\=|\+|\-|\*|\/|\!|\?|<|\>|\&|\||\^|\%|\~|\[/ =~ mid.to_s
          "['$#{mid}']"
        else
          '.$' + mid
        end
      end

      def indent(&block)
        compiler.indent(&block)
      end

      def current_indent
        compiler.parser_indent
      end

      def line(*strs)
        push "\n#{current_indent}"
        push(*strs)
      end

      def empty_line
        push "\n"
      end

      def js_truthy(sexp)
        if optimize = js_truthy_optimize(sexp)
          return optimize
        end

        with_temp do |tmp|
          [fragment("((#{tmp} = "), expr(sexp), fragment(") !== nil && #{tmp} != null && (!#{tmp}.$$is_boolean || #{tmp} == true))")]
        end
      end

      def js_falsy(sexp)
        if sexp.type == :send
          mid = sexp.children[1]
          if mid == :block_given?
            scope.uses_block!
            return "#{scope.block_name} === nil"
          end
        end

        with_temp do |tmp|
          [fragment("((#{tmp} = "), expr(sexp), fragment(") === nil || #{tmp} == null || (#{tmp}.$$is_boolean && #{tmp} == false))")]
        end
      end

      def js_truthy_optimize(sexp)
        if sexp.type == :send
          mid = sexp.children[1]
          receiver_handler_class = (receiver = sexp.children[0]) && compiler.handlers[receiver.type]

          # Only operator calls on the truthy_optimize? node classes should be optimized.
          # Monkey patch method calls might return 'self'/aka a bridged instance and need
          # the nil check - see discussion at https://github.com/opal/opal/pull/1097
          allow_optimization_on_type = Compiler::COMPARE.include?(mid.to_s) &&
            receiver_handler_class &&
            receiver_handler_class.truthy_optimize?

          if allow_optimization_on_type ||
            mid == :block_given? ||
            mid == :"=="
            expr(sexp)
          end
        elsif [:lvar, :self].include? sexp.type
          [expr(sexp.dup), fragment(" !== false && "), expr(sexp.dup), fragment(" !== nil && "), expr(sexp.dup), fragment(" != null")]
        end
      end
    end
  end
end
