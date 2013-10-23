require 'opal/lexer'
require 'opal/grammar'
require 'opal/target_scope'
require 'opal/version'
require 'opal/fragment'
require 'opal/nodes'
require 'set'

module Opal
  class Parser
    # Generated code gets indented with two spaces on each scope
    INDENT = '  '

    # All compare method nodes - used to optimize performance of
    # math comparisons
    COMPARE = %w[< > <= >=]

    # Reserved javascript keywords - we cannot create variables with the
    # same name
    RESERVED = %w(
      break case catch continue debugger default delete do else finally for
      function if in instanceof new return switch this throw try typeof var let
      void while with class enum export extends import super true false native
      const static
    )

    class << self
      def handlers
        @handlers ||= {}
      end

      def add_handler(klass, *types)
        types.each do |type|
          handlers[type] = klass
        end
      end
    end

    # literals and primitives
    add_handler ValueNode, :true, :false, :nil, :self
    add_handler NumericNode, :int, :float
    add_handler StringNode, :str
    add_handler SymbolNode, :sym
    add_handler RegexpNode, :regexp
    add_handler XStringNode, :xstr
    add_handler DynamicStringNode, :dstr
    add_handler DynamicSymbolNode, :dsym
    add_handler DynamicXStringNode, :dxstr
    add_handler DynamicRegexpNode, :dregx
    add_handler ExclusiveRangeNode, :dot2
    add_handler InclusiveRangeNode, :dot3
    add_handler HashNode, :hash
    add_handler ArrayNode, :array
    add_handler ArgsNode, :args

    # variables
    add_handler LocalVariableNode, :lvar
    add_handler LocalAssignNode, :lasgn
    add_handler InstanceVariableNode, :ivar
    add_handler InstanceAssignNode, :iasgn
    add_handler GlobalVariableNode, :gvar
    add_handler GlobalAssignNode, :gasgn
    add_handler BackrefNode, :nth_ref
    add_handler ClassVariableNode, :cvar
    add_handler ClassVarAssignNode, :cvasgn
    add_handler ClassVarDeclNode, :cvdecl
    add_handler MassAssignNode, :masgn

    # constants
    add_handler ConstDeclarationNode, :cdecl
    add_handler ConstAssignNode, :casgn
    add_handler ConstNode, :const
    add_handler ConstGetNode, :colon2
    add_handler TopConstNode, :colon3
    add_handler TopConstAssignNode, :casgn3

    # control flow
    add_handler NextNode, :next
    add_handler BreakNode, :break
    add_handler RedoNode, :redo
    add_handler NotNode, :not
    add_handler SplatNode, :splat
    add_handler OrNode, :or
    add_handler AndNode, :and
    add_handler ReturnNode, :return
    add_handler JSReturnNode, :js_return
    add_handler JSTempNode, :js_tmp
    add_handler BlockPassNode, :block_pass
    add_handler DefinedNode, :defined

    # call special
    add_handler AttrAssignNode, :attrasgn
    add_handler Match3Node, :match3
    add_handler OpAsgnOrNode, :op_asgn_or
    add_handler OpAsgnAndNode, :op_asgn_and
    add_handler OpAsgn1Node, :op_asgn1
    add_handler OpAsgn2Node, :op_asgn2

    # yield
    add_handler YieldNode, :yield
    add_handler YasgnNode, :yasgn
    add_handler ReturnableYieldNode, :returnable_yield

    # class
    add_handler SingletonClassNode, :sclass
    add_handler ModuleNode, :module
    add_handler ClassNode, :class

    # definitions
    add_handler SvalueNode, :svalue
    add_handler UndefNode, :undef
    add_handler AliasNode, :alias
    add_handler BeginNode, :begin
    add_handler ParenNode, :paren
    add_handler RescueModNode, :rescue_mod
    add_handler BlockNode, :block
    add_handler ScopeNode, :scope
    add_handler WhileNode, :while
    add_handler UntilNode, :until

    # if
    add_handler IfNode, :if

    add_handler IterNode, :iter
    add_handler DefNode, :def
    add_handler ArglistNode, :arglist

    # rescue/ensure
    add_handler EnsureNode, :ensure
    add_handler RescueNode, :rescue
    add_handler ResBodyNode, :resbody

    # case
    add_handler CaseNode, :case
    add_handler WhenNode, :when

    # call
    add_handler CallNode, :call

    # super
    add_handler SuperNode, :super
    add_handler DefinedSuperNode, :defined_super

    # Final generated javascript for this parser
    attr_reader :result

    # generated fragments as an array
    attr_reader :fragments

    # Current scope
    attr_reader :scope

    # Any helpers required by this file
    attr_reader :helpers

    # Method calls made in this file
    attr_reader :method_calls

    # Current case_stmt
    attr_reader :case_stmt

    # Parse some ruby code to a string.
    #
    #     Opal::Parser.new.parse("1 + 2")
    #     # => "(function() {....})()"
    def parse(str, options = {})
      @sexp = Grammar.new.parse(str, options[:file])
      @line     = 1
      @indent   = ''
      @unique   = 0

      # options
      @file                     =  options[:file] || '(file)'
      @source_file              =  options[:source_file] || @file
      @method_missing           = (options[:method_missing] != false)
      @arity_check              =  options[:arity_check]
      @const_missing            = (options[:const_missing] == true)
      @irb_vars                 = (options[:irb] == true)

      @method_calls = Set.new
      @helpers      = Set.new([:breaker, :slice])

      top_node = TopNode.new(@sexp, :expr, self)
      @fragments = top_node.compile_to_fragments.flatten

      @result = @fragments.map(&:code).join('')
    end

    # Is method_missing enabled for this file
    def method_missing?
      @method_missing
    end

    # const_missing enabled or not
    def const_missing?
      @const_missing
    end

    def arity_check?
      @arity_check
    end

    # Are top level irb style vars enabled
    def irb_vars?
      @irb_vars
    end

    def source_map
      Opal::SourceMap.new(@fragments, '(file)')
    end

    # This is called when a parsing/processing error occurs. This
    # method simply appends the filename and curent line number onto
    # the message and raises it.
    #
    #     parser.error "bad variable name"
    #     # => raise "bad variable name :foo.rb:26"
    #
    # @param [String] msg error message to raise
    def error(msg)
      raise SyntaxError, "#{msg} :#{@file}:#{@line}"
    end

    # This is called when a parsing/processing warning occurs. This
    # method simply appends the filename and curent line number onto
    # the message and issues a warning.
    #
    # @param [String] msg warning message to raise
    def warning(msg)
      warn "#{msg} :#{@file}:#{@line}"
    end

    # Instances of `Scope` can use this to determine the current
    # scope indent. The indent is used to keep generated code easily
    # readable.
    #
    # @return [String]
    def parser_indent
      @indent
    end

    # Create a new sexp using the given parts. Even though this just
    # returns an array, it must be used incase the internal structure
    # of sexps does change.
    #
    #     s(:str, "hello there")
    #     # => [:str, "hello there"]
    #
    # @result [Array]
    def s(*parts)
      sexp = Sexp.new(parts)
      sexp.line = @line
      sexp
    end

    # @param [String] code the string of code
    # @return [Fragment]
    def fragment(code, sexp = nil)
      Fragment.new(code, sexp)
    end

    # Converts a ruby method name into its javascript equivalent for
    # a method/function call. All ruby method names get prefixed with
    # a '$', and if the name is a valid javascript identifier, it will
    # have a '.' prefix (for dot-calling), otherwise it will be
    # wrapped in brackets to use reference notation calling.
    #
    #     mid_to_jsid('foo')      # => ".$foo"
    #     mid_to_jsid('class')    # => ".$class"
    #     mid_to_jsid('==')       # => "['$==']"
    #     mid_to_jsid('name=')    # => "['$name=']"
    #
    # @param [String] mid ruby method id
    # @return [String]
    def mid_to_jsid(mid)
      if /\=|\+|\-|\*|\/|\!|\?|\<|\>|\&|\||\^|\%|\~|\[/ =~ mid.to_s
        "['$#{mid}']"
      else
        '.$' + mid
      end
    end

    # Converts a ruby lvar/arg name to a js identifier. Not all ruby names
    # are valid in javascript. A $ suffix is added to non-valid names.
    def lvar_to_js(var)
      var = "#{var}$" if RESERVED.include? var.to_s
      var.to_sym
    end

    # Used to generate a unique id name per file. These are used
    # mainly to name method bodies for methods that use blocks.
    #
    # @return [String]
    def unique_temp
      "TMP_#{@unique += 1}"
    end

    # Use the given helper
    def helper(name)
      @helpers << name
    end

    # Every time the parser enters a new scope, this is called with
    # the scope type as an argument. Valid types are `:top` for the
    # top level/file scope; `:class`, `:module` and `:sclass` for the
    # obvious ruby classes/modules; `:def` and `:iter` for methods
    # and blocks respectively.
    #
    # This method just pushes a new instance of `Opal::Scope` onto the
    # stack, sets the new scope as the `@scope` variable, and yields
    # the given block. Once the block returns, the old scope is put
    # back on top of the stack.
    #
    #     in_scope(:class) do
    #       # generate class body in here
    #       body = "..."
    #     end
    #
    #     # use body result..
    #
    # @param [Symbol] type the type of scope
    # @return [nil]
    def in_scope(type)
      return unless block_given?

      parent = @scope
      @scope = TargetScope.new(type, self).tap { |s| s.parent = parent }
      yield @scope

      @scope = parent
    end

    # To keep code blocks nicely indented, this will yield a block after
    # adding an extra layer of indent, and then returning the resulting
    # code after reverting the indent.
    #
    #   indented_code = indent do
    #     "foo"
    #   end
    #
    # @result [String]
    def indent(&block)
      indent = @indent
      @indent += INDENT
      @space = "\n#@indent"
      res = yield
      @indent = indent
      @space = "\n#@indent"
      res
    end

    # Temporary varibales will be needed from time to time in the
    # generated code, and this method will assign (or reuse) on
    # while the block is yielding, and queue it back up once it is
    # finished. Variables are queued once finished with to save the
    # numbers of variables needed at runtime.
    #
    #     with_temp do |tmp|
    #       "tmp = 'value';"
    #     end
    #
    # @return [String] generated code withing block
    def with_temp(&block)
      tmp = @scope.new_temp
      res = yield tmp
      @scope.queue_temp tmp
      res
    end

    # Used when we enter a while statement. This pushes onto the current
    # scope's while stack so we know how to handle break, next etc.
    #
    # Usage:
    #
    #     in_while do
    #       # generate while body here.
    #     end
    def in_while
      return unless block_given?
      @while_loop = @scope.push_while
      result = yield
      @scope.pop_while

      result
    end

    def in_case
      return unless block_given?
      old = @case_stmt
      @case_stmt = {}
      yield
      @case_stmt = old
    end

    # Returns true if the parser is curently handling a while sexp,
    # false otherwise.
    #
    # @return [Boolean]
    def in_while?
      @scope.in_while?
    end

    # Process the given sexp by creating a node instance, based on its type,
    # and compiling it to fragments.
    def process(sexp, level = :expr)
      if handler = Parser.handlers[sexp.type]
        @line = sexp.line
        return handler.new(sexp, level, self).compile_to_fragments
      else
        raise "Unsupported sexp: #{sexp.type}"
      end
    end

    # Handle "special" method calls, e.g. require(). Subclasses can override
    # this method. If this method returns nil, then the method will continue
    # to be generated by CallNode.
    def handle_call(sexp)
      nil
    end

    # The last sexps in method bodies, for example, need to be returned
    # in the compiled javascript. Due to syntax differences between
    # javascript any ruby, some sexps need to be handled specially. For
    # example, `if` statemented cannot be returned in javascript, so
    # instead the "truthy" and "falsy" parts of the if statement both
    # need to be returned instead.
    #
    # Sexps that need to be returned are passed to this method, and the
    # alterned/new sexps are returned and should be used instead. Most
    # sexps can just be added into a s(:return) sexp, so that is the
    # default action if no special case is required.
    #
    #     sexp = s(:str, "hey")
    #     parser.returns(sexp)
    #     # => s(:js_return, s(:str, "hey"))
    #
    # `s(:js_return)` is just a special sexp used to return the result
    # of processing its arguments.
    #
    # @param [Array] sexp the sexp to alter
    # @return [Array] altered sexp
    def returns(sexp)
      return returns s(:nil) unless sexp

      case sexp.type
      when :break, :next, :redo
        sexp
      when :yield
        sexp[0] = :returnable_yield
        sexp
      when :scope
        sexp[1] = returns sexp[1]
        sexp
      when :block
        if sexp.length > 1
          sexp[-1] = returns sexp[-1]
        else
          sexp << returns(s(:nil))
        end
        sexp
      when :when
        sexp[2] = returns(sexp[2])
        sexp
      when :rescue
        sexp[1] = returns sexp[1]

        if sexp[2] and sexp[2][0] == :resbody
          if sexp[2][2]
            sexp[2][2] = returns sexp[2][2]
          else
            sexp[2][2] = returns s(:nil)
          end
        end
        sexp
      when :ensure
        sexp[1] = returns sexp[1]
        sexp
      when :begin
        sexp[1] = returns sexp[1]
        sexp
      when :rescue_mod
        sexp[1] = returns sexp[1]
        sexp[2] = returns sexp[2]
        sexp
      when :while
        # sexp[2] = returns(sexp[2])
        sexp
      when :return, :js_return
        sexp
      when :xstr
        sexp[1] = "return #{sexp[1]};" unless /return|;/ =~ sexp[1]
        sexp
      when :dxstr
        sexp[1] = "return #{sexp[1]}" unless /return|;|\n/ =~ sexp[1]
        sexp
      when :if
        sexp[2] = returns(sexp[2] || s(:nil))
        sexp[3] = returns(sexp[3] || s(:nil))
        sexp
      else
        s(:js_return, sexp).tap { |s|
          s.line = sexp.line
        }
      end
    end

    def js_block_given(sexp, level)
      @scope.uses_block!
      if @scope.block_name
        fragment("(#{@scope.block_name} !== nil)", sexp)
      elsif scope = @scope.find_parent_def and scope.block_name
        fragment("(#{scope.block_name} !== nil)", sexp)
      else
        fragment("false", sexp)
      end
    end
  end
end
