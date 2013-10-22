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

    # rescue/ensure
    add_handler EnsureNode, :ensure
    add_handler RescueNode, :rescue
    add_handler ResBodyNode, :resbody

    # case
    add_handler CaseNode, :case
    add_handler WhenNode, :when

    # super
    add_handler SuperNode, :super
    add_handler DefinedSuperNode, :defined_super

    # Final generated javascript for this parser
    attr_reader :result

    # generated fragments as an array
    attr_reader :fragments

    attr_reader :scope

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

      @fragments = self.top(@sexp).flatten

      @fragments.unshift f(version_comment)

      @result = @fragments.map(&:code).join('')
    end

    # Always at top of generated file to show current opal version
    def version_comment
      "/* Generated by Opal #{Opal::VERSION} */\n"
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
    def f(code, sexp = nil)
      Fragment.new(code, sexp)
    end

    alias_method :fragment, :f

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

    # Generate the code for the top level sexp, i.e. the root sexp
    # for a file. This is used directly by `#parse`. It pushes a
    # ":top" scope onto the stack and handles the passed in sexp.
    # The result is a string of javascript representing the sexp.
    #
    # @param [Array] sexp the sexp to process
    # @return [String]
    def top(sexp, options = {})
      code, vars = nil, nil

      # empty file = nil as our top sexp
      sexp ||= s(:nil)

      in_scope(:top) do
        indent {
          scope = s(:scope, sexp)
          scope.line = sexp.line

          code = process(scope, :stmt)
          code = [code] unless code.is_a? Array
          code.unshift f(@indent, sexp)
        }

        @scope.add_temp "self = $opal.top",
                        "$scope = $opal",
                        "nil = $opal.nil"

        @helpers.to_a.each { |h| @scope.add_temp "$#{h} = $opal.#{h}" }

        vars = [f(INDENT, sexp), @scope.to_vars, f("\n", sexp)]

        if @irb_vars
          code.unshift f("if (!$opal.irb_vars) { $opal.irb_vars = {}; }\n", sexp)
        end
      end

      if @method_missing
        stubs = f("\n#{INDENT}$opal.add_stubs([" + @method_calls.to_a.map { |k| "'$#{k}'" }.join(", ") + "]);\n", sexp)
      else
        stubs = []
      end

      [f("(function($opal) {\n", sexp), vars, stubs, code, f("\n})(Opal);\n", sexp)]
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

    # Processes a given sexp. This will send a method to the receiver
    # of the format "process_<sexp_name>". Any sexp handler should
    # return a string of content.
    #
    # For example, calling `process` with `s(:sym, 42)` will call the
    # method `#process_lit`. If a method with that name cannot be
    # found, then an error is raised.
    #
    #     process(s(:int, 42), :stmt)
    #     # => "42"
    #
    # @param [Array] sexp the sexp to process
    # @param [Symbol] level the level to process (see `LEVEL`)
    # @return [String]
    def process(sexp, level = :expr)
      if handler = Parser.handlers[sexp.type]
        @line = sexp.line
        return handler.new(sexp, level, self).compile_to_fragments
      end

      type = sexp.type
      sexp.shift
      meth = "process_#{type}"
      raise "Unsupported sexp: #{type}" unless respond_to? meth

      @line = sexp.line

      __send__(meth, sexp, level)
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
        f("(#{@scope.block_name} !== nil)", sexp)
      elsif scope = @scope.find_parent_def and scope.block_name
        f("(#{scope.block_name} !== nil)", sexp)
      else
        f("false", sexp)
      end
    end

    def handle_block_given(sexp, reverse = false)
      @scope.uses_block!
      name = @scope.block_name

      f((reverse ? "#{ name } === nil" : "#{ name } !== nil"), sexp)
    end

    # A block/iter with embeded call. Compiles into function
    # s(:iter, block_args [, body) => (function() { ... })
    def process_iter(sexp, level)
      args, body = sexp

      body ||= s(:nil)
      body = returns body
      code = []
      params = nil
      scope_name = nil
      identity = nil
      to_vars = nil

      args = nil if Fixnum === args # argh
      args ||= s(:masgn, s(:array))
      args = args.first == :lasgn ? s(:array, args) : args[1]

      # opt args are last, if present, and are a [:block]
      if args.last.is_a?(Sexp) and args.last[0] == :block
        opt_args = args.pop
        opt_args.shift
      end

      if args.last.is_a?(Sexp) and args.last[0] == :block_pass
        block_arg = args.pop
        block_arg = block_arg[1][1].to_sym
      end

      if args.last.is_a?(Sexp) and args.last[0] == :splat
        splat = args.last[1][1]
        args.pop
        len = args.length
      end

      indent do
        in_scope(:iter) do
          identity = @scope.identify!
          @scope.add_temp "self = #{identity}._s || this"

          params = js_block_args(args[1..-1])

          args[1..-1].each_with_index do |arg, idx|
            if arg[0] == :lasgn
              arg = arg[1]
              arg = "#{arg}$" if RESERVED.include? arg.to_s

              if opt_args and current_opt = opt_args.find { |s| s[1] == arg.to_sym }
                code << [f("if (#{arg} == null) #{arg} = ", sexp), process(current_opt[2]), f(";\n#{@indent}", sexp)]
              else
                code << f("if (#{arg} == null) #{arg} = nil;\n#{@indent}", sexp)
              end
            elsif arg[0] == :array
              arg[1..-1].each_with_index do |_arg, midx|
                _arg = _arg[1]
                _arg = "#{_arg}$" if RESERVED.include? _arg.to_s
                code << f("#{_arg} = #{params[idx]}[#{midx}];\n#{@indent}")
              end
            else
              raise "Bad block_arg type: #{arg[0]}"
            end
          end

          if splat
            @scope.add_arg splat
            params << splat
            code << f("#{splat} = $slice.call(arguments, #{len - 1});", sexp)
          end

          if block_arg
            @scope.block_name = block_arg
            @scope.add_temp block_arg
            scope_name = @scope.identify!

            blk = []
            blk << f("\n#@indent#{block_arg} = #{scope_name}._p || nil, #{scope_name}._p = null;\n#@indent", sexp)

            code.unshift blk
          end

          code << f("\n#@indent", sexp)
          code << process(body, :stmt)

          to_vars = [f("\n#@indent", sexp), @scope.to_vars, f("\n#@indent", sexp)]
        end
      end

      itercode = [f("function(#{params.join ', '}) {\n", sexp), to_vars, code, f("\n#@indent}", sexp)]

      itercode.unshift f("(#{identity} = ", sexp)
      itercode << f(", #{identity}._s = self, #{identity})", sexp)

      itercode
    end

    # Maps block args into array of jsid. Adds $ suffix to invalid js
    # identifiers.
    #
    # s(:args, parts...) => ["a", "b", "break$"]
    def js_block_args(sexp)
      result = []
      sexp.each do |arg|
        if arg[0] == :lasgn
          ref = lvar_to_js(arg[1])
          @scope.add_arg ref
          result << ref
        elsif arg[0] == :array
          result << @scope.next_temp
        else
          raise "Bad js_block_arg: #{arg[0]}"
        end
      end

      result
    end

    # s(:call, recv, :mid, s(:arglist))
    # s(:call, nil, :mid, s(:arglist))
    def process_call(sexp, level)
      recv, meth, arglist, iter = sexp
      mid = mid_to_jsid meth.to_s

      @method_calls << meth.to_sym

      # we are trying to access a lvar in irb mode
      if @irb_vars and @scope.top? and arglist == s(:arglist) and recv == nil and iter == nil
        return with_temp { |t|
          lvar = meth.intern
          lvar = "#{lvar}$" if RESERVED.include? lvar
          call = s(:call, s(:self), meth.intern, s(:arglist))
          [f("((#{t} = $opal.irb_vars.#{lvar}) == null ? ", sexp), process(call), f(" : #{t})", sexp)]
        }
      end

      case meth
      when :block_given?
        return js_block_given(sexp, level)
      when :__method__, :__callee__
        if @scope.def?
          return f(@scope.mid.to_s.inspect)
        else
          return f("nil")
        end
      end

      splat = arglist[1..-1].any? { |a| a.first == :splat }

      if Sexp === arglist.last and arglist.last.first == :block_pass
        block = process(arglist.pop)
      elsif iter
        block = process(iter)
      end

      recv ||= s(:self)

      if block
        tmpfunc = @scope.new_temp
      end

      tmprecv = @scope.new_temp if splat || tmpfunc
      args      = ""

      recv_code = process recv, :recv

      call_recv = s(:js_tmp, tmprecv || recv_code)
      arglist.insert 1, call_recv if tmpfunc and !splat
      args = process arglist

      dispatch = if tmprecv
        [f("(#{tmprecv} = "), recv_code, f(")#{mid}")]
      else
        [recv_code, f(mid)]
      end

      if tmpfunc
        dispatch.unshift f("(#{tmpfunc} = ")
        dispatch << f(", #{tmpfunc}._p = ")
        dispatch << block
        dispatch << f(", #{tmpfunc})")
      end

      result = if splat
        [dispatch, f(".apply("), (tmprecv ? f(tmprecv) : recv_code),
         f(", "), args, f(")")]
      elsif tmpfunc
        [dispatch, f(".call("), args, f(")")]
      else
        [dispatch, f("("), args, f(")")]
      end

      @scope.queue_temp tmpfunc if tmpfunc
      result
    end

    # s(:arglist, [arg [, arg ..]])
    def process_arglist(sexp, level)
      code, work = [], []

      sexp.each do |current|
        splat = current.first == :splat
        arg   = process current

        if splat
          if work.empty?
            if code.empty?
              code << f("[].concat(", sexp)
              code << arg
              code << f(")")
            else
              code += ".concat(#{arg})"
            end
          else
            if code.empty?
              code << [f("["), work, f("]")]
            else
              code << [f(".concat(["), work, f("])")]
            end

            code << [f(".concat("), arg, f(")")]
          end

          work = []
        else
          work << f(", ") unless work.empty?
          work << arg
        end
      end

      unless work.empty?
        join = work

        if code.empty?
          code = join
        else
          code << f(".concat(") << join << f(")")
        end
      end

      code
    end

    # s(:def, recv, mid, s(:args), s(:scope))
    def process_def(sexp, level)
      recvr, mid, args, stmts = sexp
      jsid = mid_to_jsid mid.to_s

      recvr = process(recvr) if recvr

      code = []
      params = nil
      scope_name = nil
      uses_super = nil
      uses_splat = nil

      # opt args if last arg is sexp
      opt = args.pop if Sexp === args.last

      argc = args.length - 1

      # block name &block
      if args.last.to_s.start_with? '&'
        block_name = args.pop.to_s[1..-1].to_sym
        argc -= 1
      end

      # splat args *splat
      if args.last.to_s.start_with? '*'
        uses_splat = true
        if args.last == :*
          argc -= 1
        else
          splat = args[-1].to_s[1..-1].to_sym
          args[-1] = splat
          argc -= 1
        end
      end

      if @arity_check
        arity_code = arity_check(args, opt, uses_splat, block_name, mid) + "\n#{INDENT}"
      end

      indent do
        in_scope(:def) do
          @scope.add_temp "self = this"
          @scope.mid  = mid
          @scope.defs = true if recvr

          if block_name
            @scope.uses_block!
            @scope.add_arg block_name
          end

          yielder = block_name || '$yield'
          @scope.block_name = yielder

          params = process args
          stmt_code = [f("\n#@indent"), process(stmts, :stmt)]

          opt[1..-1].each do |o|
            next if o[2][2] == :undefined
            code << f("if (#{lvar_to_js o[1]} == null) {\n#{@indent + INDENT}", o)
            code << process(o)
            code << f("\n#{@indent}}", o)
          end if opt

          code << f("#{splat} = $slice.call(arguments, #{argc});", sexp) if splat

          scope_name = @scope.identity

          if @scope.uses_block?
            @scope.add_temp "$iter = #{scope_name}._p",
                            "#{yielder} = $iter || nil"

            code.unshift f("#{scope_name}._p = null;", sexp)
          end

          code.push(*stmt_code)

          uses_super = @scope.uses_super

          code = [f("#{arity_code}#@indent", sexp), @scope.to_vars, code]

          if @scope.uses_zuper
            code.unshift f("var $zuper = $slice.call(arguments, 0);", sexp)
          end

          if @scope.catch_return
            code.unshift f("try {\n", sexp)
            code.push f("\n} catch($returner) { if ($returner === $opal.returner) { return $returner.$v; } throw $returner; }", sexp)
          end
        end
      end

      result = [f("#{"#{scope_name} = " if scope_name}function(", sexp)]
      result.push(*params)
      result << f(") {\n", sexp)
      result.push(*code)
      result << f("\n#@indent}", sexp)

      def_code = if recvr
        [f("$opal.defs("), recvr, f(", '$#{mid}', "), result, f(")")]
      elsif @scope.class? and %w(Object BasicObject).include?(@scope.name)
        [f("$opal.defn(self, '$#{mid}', "), result, f(")")]
      elsif @scope.class_scope?
        @scope.methods << "$#{mid}"
        [f("#{@scope.proto}#{jsid} = ", sexp), result]
      elsif @scope.iter?
        [f("$opal.defn(self, '$#{mid}', "), result, f(")")]
      elsif @scope.type == :sclass
        [f("self._proto#{jsid} = ", sexp), result]
      elsif @scope.type == :top
        [f("$opal.Object._proto#{jsid} = ", sexp), result]
      else
        [f("def#{jsid} = ", sexp), result]
      end

      level == :expr ? [f('('), def_code, f(', nil)')] : def_code
    end

    ##
    # Returns code used in debug mode to check arity of method call
    def arity_check(args, opt, splat, block_name, mid)
      meth = mid.to_s.inspect

      arity = args.size - 1
      arity -= (opt.size - 1) if opt
      arity -= 1 if splat
      arity = -arity - 1 if opt or splat

      # $arity will point to our received arguments count
      aritycode = "var $arity = arguments.length;"

      if arity < 0 # splat or opt args
        aritycode + "if ($arity < #{-(arity + 1)}) { $opal.ac($arity, #{arity}, this, #{meth}); }"
      else
        aritycode + "if ($arity !== #{arity}) { $opal.ac($arity, #{arity}, this, #{meth}); }"
      end
    end

    def process_args(exp, level)
      args = []

      exp.each do |a|
        a = a.to_sym
        next if a.to_s == '*'
        a = lvar_to_js a
        @scope.add_arg a
        args << a
      end

      f(args.join(', '), exp)
    end

    # s(:array [, sexp [, sexp]]) => [...]
    def process_array(sexp, level)
      return [f("[]", sexp)] if sexp.empty?

      code, work = [], []

      sexp.each do |current|
        splat = current.first == :splat
        part  = process current

        if splat
          if work.empty?
            if code.empty?
              code << f("[].concat(", sexp) << part << f(")", sexp)
            else
              code << f(".concat(", sexp) << part << f(")", sexp)
            end
          else
            if code.empty?
              code << f("[", sexp) << work << f("]", sexp)
            else
              code << f(".concat([", sexp) << work << f("])", sexp)
            end

            code << f(".concat(", sexp) << part << f(")", sexp)
          end
          work = []
        else
          work << f(", ", current) unless work.empty?
          work << part
        end
      end

      unless work.empty?
        join = [f("[", sexp), work, f("]", sexp)]

        if code.empty?
          code = join
        else
          code.push([f(".concat(", sexp), join, f(")", sexp)])
        end
      end

      code
    end

    def process_masgn(sexp, level)
      lhs, rhs = sexp
      tmp = @scope.new_temp
      len = 0
      code = []

      if rhs[0] == :array
        len = rhs.length - 1 # we are guaranteed an array of this length
        code << f("#{tmp} = ", sexp) << process(rhs)
      elsif rhs[0] == :to_ary
        code << [f("#{tmp} = $opal.to_ary("), process(rhs[1]), f(")")]
      elsif rhs[0] == :splat
        code << f("(#{tmp} = ", sexp) << process(rhs[1])
        code << f(")['$to_a'] ? (#{tmp} = #{tmp}['$to_a']()) : (#{tmp})._isArray ?  #{tmp} : (#{tmp} = [#{tmp}])", sexp)
      else
        raise "Unsupported mlhs type"
      end

      lhs[1..-1].each_with_index do |l, idx|
        code << f(", ", sexp) unless code.empty?

        if l.first == :splat
          if s = l[1]
            s << s(:js_tmp, "$slice.call(#{tmp}, #{idx})")
            code << process(s)
          end
        else
          if idx >= len
            assign = s(:js_tmp, "(#{tmp}[#{idx}] == null ? nil : #{tmp}[#{idx}])")
          else
            assign = s(:js_tmp, "#{tmp}[#{idx}]")
          end

          if l[0] == :lasgn or l[0] == :iasgn or l[0] == :lvar
            l << assign
          elsif l[0] == :call
            l[2] = "#{l[2]}=".to_sym
            l.last << assign
          elsif l[0] == :attrasgn
            l.last << assign
          else
            raise "bad lhs for masgn: #{l.inspect}"
          end

          code << process(l)
        end
      end

      @scope.queue_temp tmp
      code
    end

    def js_truthy_optimize(sexp)
      if sexp.first == :call
        mid = sexp[2]
        if mid == :block_given?
          return process sexp
        elsif COMPARE.include? mid.to_s
          return process sexp
        elsif mid == :"=="
          return process sexp
        end
      elsif [:lvar, :self].include? sexp.first
        [process(sexp.dup), f(" !== false && ", sexp), process(sexp.dup), f(" !== nil", sexp)]
      end
    end

    def js_truthy(sexp)
      if optimized = js_truthy_optimize(sexp)
        return optimized
      end

      with_temp do |tmp|
        [f("(#{tmp} = ", sexp), process(sexp), f(") !== false && #{tmp} !== nil", sexp)]
      end
    end

    def js_falsy(sexp)
      if sexp.first == :call
        mid = sexp[2]
        if mid == :block_given?
          return handle_block_given(sexp, true)
        end
      end

      with_temp do |tmp|
        result = []
        result << f("(#{tmp} = ", sexp)
        result << process(sexp)
        result << f(") === false || #{tmp} === nil", sexp)
        result
      end
    end
  end
end
