require 'opal/lexer'
require 'opal/grammar'
require 'opal/scope'

module Opal
  # This class is used to generate the javascript code from the given
  # ruby code. First, this class will use an instance of `Opal::Grammar`
  # to lex and then build up a tree of sexp statements. Once done, the
  # top level sexp is passed into `#top` which recursively generates
  # javascript for each sexp inside, and the result is returned as a
  # string.
  #
  #     p = Opal::Parser.new
  #     p.parse "puts 42"
  #     # => "(function() { ... })()"
  #
  # ## Sexps
  #
  # A sexp, in opal, is an array where the first value is a symbol
  # identifying the type of sexp. A simple ruby string "hello" would
  # be represented by the sexp:
  #
  #     s(:str, "hello")
  #
  # Once that sexp is encounterd by the parser, it is handled by
  # `#process` which removes the sexp type from the array, and checks
  # for a method "process_str", which is used to handle specific sexps.
  # Once found, that method is called with the sexp and level as
  # arguments, and the returned string is the javascript to be used in
  # the resulting file.
  #
  # ## Levels
  #
  # A level inside the parser is just a symbol representing what type
  # of destination the code to be generated is for. For example, the
  # main two levels are `:stmt` and `:expr`. Most sexps generate the
  # same code for every level, but an `if` statement for example
  # will change when written as an expression. Javascript cannot have
  # if statements as expressions, so that sexp would wrap its result
  # inside an anonymous function so the if statement can compile as
  # expected.
  class Parser
    # Generated code gets indented with two spaces on each scope
    INDENT = '  '

    # Expressions are handled at diffferent levels. Some sexps
    # need to know the js expression they are generating into.
    LEVEL = [:stmt, :stmt_closure, :list, :expr, :recv]

    # All compare method nodes - used to optimize performance of
    # math comparisons
    COMPARE = %w[< > <= >=]

    # Reserved javascript keywords - we cannot create variables with the
    # same name
    RESERVED = %w(
      break case catch continue debugger default delete do else finally for
      function if in instanceof new return switch this throw try typeof var let
      void while with class enum export extends import super true false native
      const
    )

    # Statements which should not have ';' added to them.
    STATEMENTS = [:xstr, :dxstr]

    # The grammar (tree of sexps) representing this compiled code
    # @return [Opal::Grammar]
    attr_reader :grammar

    # Holds an array of paths which this file "requires".
    # @return [Array<String>]
    attr_reader :requires

    # This does the actual parsing. The ruby code given is first
    # run through a `Grammar` instance which returns a sexp to
    # process. This is then handled recursively, resulting in a
    # string of javascript being returned.
    #
    #     p = Opal::Parser.new
    #     p.parse "puts 'hey'"
    #     # => "(function() { .... })()"
    #
    # @param [String] source the ruby code to parse
    # @param [String] file the filename representing this code
    # @return [String] string of javascript code
    def parse(source, options = {})
      @grammar  = Grammar.new
      @requires = []
      @line     = 1
      @indent   = ''
      @unique   = 0

      @helpers  = {
        :breaker  => true,
        :slice    => true
      }

      # options
      @file     = options[:file] || '(file)'
      @method_missing = (options[:method_missing] != false)
      @optimized_operators = (options[:optimized_operators] != false)
      @arity_check = options[:arity_check]
      @const_missing = (options[:const_missing] != false)

      top @grammar.parse(source, @file)
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
      sexp = Array.new(parts)
      sexp.line = @line
      sexp
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

    # Used to generate a unique id name per file. These are used
    # mainly to name method bodies for methods that use blocks.
    #
    # @return [String]
    def unique_temp
      "TMP_#{@unique += 1}"
    end

    # Generate the code for the top level sexp, i.e. the root sexp
    # for a file. This is used directly by `#parse`. It pushes a
    # ":top" scope onto the stack and handles the passed in sexp.
    # The result is a string of javascript representing the sexp.
    #
    # @param [Array] sexp the sexp to process
    # @return [String]
    def top(sexp, options = {})
      code = nil
      vars = []

      in_scope(:top) do
        indent {
          code = @indent + process(s(:scope, sexp), :stmt)
        }

        @scope.add_temp "self = __opal.top"
        @scope.add_temp "__scope = __opal"
        @scope.add_temp "nil = __opal.nil"
        @scope.add_temp "$mm = __opal.mm"
        @scope.add_temp "def = #{current_self}._klass.prototype" if @scope.defines_defn
        @helpers.keys.each { |h| @scope.add_temp "__#{h} = __opal.#{h}" }

        code = INDENT + @scope.to_vars + "\n" + code
      end

      "(function(__opal) {\n#{ code }\n})(Opal);\n"
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
      @scope = Scope.new(type, self).tap { |s| s.parent = parent }
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
    # For example, calling `process` with `s(:lit, 42)` will call the
    # method `#process_lit`. If a method with that name cannot be
    # found, then an error is raised.
    #
    #     process(s(:lit, 42), :stmt)
    #     # => "42"
    #
    # @param [Array] sexp the sexp to process
    # @param [Symbol] level the level to process (see `LEVEL`)
    # @return [String]
    def process(sexp, level)
      type = sexp.shift
      meth = "process_#{type}"
      raise "Unsupported sexp: #{type}" unless respond_to? meth

      @line = sexp.line

      __send__ meth, sexp, level
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

      case sexp.first
      when :break, :next
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
        sexp
      when :ensure
        sexp[1] = returns sexp[1]
        sexp
      when :while
        # sexp[2] = returns(sexp[2])
        sexp
      when :return
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

    # Returns true if the given sexp is an expression. All expressions
    # will get ';' appended to their result, except for the statement
    # sexps. See `STATEMENTS` for a list of sexp names that are
    # statements.
    #
    # @param [Array] sexp the sexp to check
    # @return [Boolean]
    def expression?(sexp)
      !STATEMENTS.include?(sexp.first)
    end

    # More than one expression in a row will be grouped by the grammar
    # into a block sexp. A block sexp just holds any number of other
    # sexps.
    #
    #     s(:block, s(:str, "hey"), s(:lit, 42))
    #
    # A block can actually be empty. As opal requires real values to
    # be returned (to appease javascript values), a nil sexp
    # s(:nil) will be generated if the block is empty.
    #
    # @return [String]
    def process_block(sexp, level)
      result = []
      sexp << s(:nil) if sexp.empty?

      until sexp.empty?
        stmt = sexp.shift
        type = stmt.first

        # find any inline yield statements
        if yasgn = find_inline_yield(stmt)
          result << "#{process(yasgn, level)};"
        end

        expr = expression?(stmt) and LEVEL.index(level) < LEVEL.index(:list)
        code = process(stmt, level)
        result << (expr ? "#{code};" : code) unless code == ""
      end

      result.join(@scope.class_scope? ? "\n\n#@indent" : "\n#@indent")
    end

    # When a block sexp gets generated, any inline yields (i.e. yield
    # statements that are not direct members of the block) need to be
    # generated as a top level member. This is because if a yield
    # is returned by a break statement, then the method must return.
    #
    # As inline expressions in javascript cannot return, the block
    # must be rewritten.
    #
    # For example, a yield inside an array:
    #
    #     [1, 2, 3, yield(4)]
    #
    # Must be rewitten into:
    #
    #     tmp = yield 4
    #     [1, 2, 3, tmp]
    #
    # This rewriting happens on sexps directly.
    #
    # @param [Sexp] stmt sexps to (maybe) rewrite
    # @return [Sexp]
    def find_inline_yield(stmt)
      found = nil
      case stmt.first
      when :js_return
        found = find_inline_yield stmt[1]
      when :array
        stmt[1..-1].each_with_index do |el, idx|
          if el.first == :yield
            found = el
            stmt[idx+1] = s(:js_tmp, '__yielded')
          end
        end
      when :call
        arglist = stmt[3]
        arglist[1..-1].each_with_index do |el, idx|
          if el.first == :yield
            found = el
            arglist[idx+1] = s(:js_tmp, '__yielded')
          end
        end
      end

      if found
        @scope.add_temp '__yielded' unless @scope.has_temp? '__yielded'
        s(:yasgn, '__yielded', found)
      end
    end

    def process_scope(sexp, level)
      stmt = sexp.shift
      if stmt
        stmt = returns stmt unless @scope.class_scope?
        code = process stmt, :stmt
      else
        code = "nil"
      end

      code
    end

    # s(:js_return, sexp)
    def process_js_return(sexp, level)
      "return #{process sexp.shift, :expr}"
    end

    # s(:js_tmp, str)
    def process_js_tmp(sexp, level)
      sexp.shift.to_s
    end

    def process_operator(sexp, level)
      meth, recv, arg = sexp
      mid = mid_to_jsid meth.to_s

      if @optimized_operators
        with_temp do |a|
          with_temp do |b|
            l = process recv, :expr
            r = process arg, :expr

            "(%s = %s, %s = %s, typeof(%s) === 'number' ? %s %s %s : %s%s(%s))" %
              [a, l, b, r, a, a, meth.to_s, b, a, mid, b]
          end
        end
      else
        "#{process recv, :recv}#{mid}(#{process arg, :expr})"
      end
    end

    def js_block_given(sexp, level)
      @scope.uses_block!
      if @scope.block_name
        "(#{@scope.block_name} !== nil)"
      else
        "false"
      end
    end

    def handle_block_given(sexp, reverse = false)
      @scope.uses_block!
      name = @scope.block_name

      reverse ? "#{ name } === nil" : "#{ name } !== nil"
    end

    # s(:lit, 1)
    # s(:lit, :foo)
    def process_lit(sexp, level)
      val = sexp.shift
      case val
      when Numeric
        level == :recv ? "(#{val.inspect})" : val.inspect
      when Symbol
        val.to_s.inspect
      when Regexp
        val == // ? /^/.inspect : val.inspect
      when Range
        @helpers[:range] = true
        "__range(#{val.begin}, #{val.end}, #{val.exclude_end?})"
      else
        raise "Bad lit: #{val.inspect}"
      end
    end

    def process_dregx(sexp, level)
      parts = sexp.map do |part|
        if String === part
          part.inspect
        elsif part[0] == :str
          process part, :expr
        else
          process part[1], :expr
        end
      end

      "(new RegExp(#{parts.join ' + '}))"
    end

    def process_dot2(sexp, level)
      lhs = process sexp[0], :expr
      rhs = process sexp[1], :expr
      @helpers[:range] = true
      "__range(%s, %s, false)" % [lhs, rhs]
    end

    def process_dot3(sexp, level)
      lhs = process sexp[0], :expr
      rhs = process sexp[1], :expr
      @helpers[:range] = true
      "__range(%s, %s, true)" % [lhs, rhs]
    end

    # s(:str, "string")
    def process_str(sexp, level)
      str = sexp.shift
      if str == @file
        @uses_file = true
        @file.inspect
      else
        str.inspect
      end
    end

    def process_defined(sexp, level)
      part = sexp[0]
      case part[0]
      when :self
        "self".inspect
      when :nil
        "nil".inspect
      when :true
        "true".inspect
      when :false
        "false".inspect
      when :call
        mid = mid_to_jsid part[2].to_s
        recv = part[1] ? process(part[1], :expr) : current_self
        "(#{recv}#{mid} ? 'method' : nil)"
      when :xstr
        "(typeof(#{process part, :expression}) !== 'undefined')"
      when :colon2
        "false"
      else
        raise "bad defined? part: #{part[0]}"
      end
    end

    # s(:not, sexp)
    def process_not(sexp, level)
      with_temp do |tmp|
        "(#{tmp} = #{process(sexp.shift, :expr)}, (#{tmp} === nil || #{tmp} === false))"
      end
    end

    def process_block_pass(exp, level)
      process(s(:call, exp.shift, :to_proc, s(:arglist)), :expr)
    end

    # s(:iter, call, block_args [, body)
    def process_iter(sexp, level)
      call, args, body = sexp

      body ||= s(:nil)
      body = returns body
      code = ""
      params = nil
      scope_name = nil
      identity = nil

      args = nil if Fixnum === args # argh
      args ||= s(:masgn, s(:array))
      args = args.first == :lasgn ? s(:array, args) : args[1]

      if args.last.is_a?(Array) and args.last[0] == :block_pass
        block_arg = args.pop
        block_arg = block_arg[1][1].to_sym
      end

      if args.last.is_a?(Array) and args.last[0] == :splat
        splat = args.last[1][1]
        args.pop
        len = args.length
      end

      indent do
        in_scope(:iter) do
          identity = @scope.identify!
          @scope.add_temp "self = #{identity}._s || this"

          args[1..-1].each do |arg|
           arg = arg[1]
           arg = "#{arg}$" if RESERVED.include? arg.to_s
            code += "if (#{arg} == null) #{arg} = nil;\n"
          end

          params = js_block_args(args[1..-1])
          # params.unshift '_$'

          if splat
            params << splat
            code += "#{splat} = __slice.call(arguments, #{len - 1});"
          end

          if block_arg
            @scope.block_name = block_arg
            @scope.add_temp block_arg
            @scope.add_temp '__context'
            scope_name = @scope.identify!
            # @scope.add_arg block_arg
            # code += "var #{block_arg} = _$ || nil, $context = #{block_arg}.$S;"
            blk = "\n%s%s = %s._p || nil, __context = %s._s, %s.p = null;\n%s" %
              [@indent, block_arg, scope_name, block_arg, scope_name, @indent]

            code = blk + code
          end

          code += "\n#@indent" + process(body, :stmt)

          if @scope.defines_defn
            @scope.add_temp "def = (#{current_self}._isObject ? #{current_self} : #{current_self}.prototype)"
          end

          code = "\n#@indent#{@scope.to_vars}\n#@indent#{code}"
        end
      end

      itercode = "function(#{params.join ', '}) {\n#{code}\n#@indent}"
      call[3] << s(:js_tmp, "(%s = %s, %s._s = %s, %s)" % [identity, itercode, identity, current_self, identity])

      process call, level
    end

    def js_block_args(sexp)
      sexp.map do |arg|
        a = arg[1].to_sym
        a = "#{a}$".to_sym if RESERVED.include? a.to_s
        @scope.add_arg a
        a
      end
    end

    ##
    # recv.mid = rhs
    #
    # s(recv, :mid=, s(:arglist, rhs))
    def process_attrasgn(exp, level)
      recv = exp[0]
      mid = exp[1]
      arglist = exp[2]

      return process(s(:call, recv, mid, arglist), level)
    end

    # Used to generate optimized attr_reader, attr_writer and
    # attr_accessor methods. These are optimized to avoid the added
    # cost of converting the method id's into jsid's at runtime.
    #
    # This method will only be called if all the given ids are strings
    # or symbols. Any dynamic arguments will default to being called
    # using the Module#attr_* methods as expected.
    #
    # @param [Symbol] meth :attr_{reader,writer,accessor}
    # @param [Array<Sexp>] attrs array of s(:lit) or s(:str)
    # @return [String] precompiled attr methods
    def handle_attr_optimize(meth, attrs)
      out = []

      attrs.each do |attr|
        mid  = attr[1]
        ivar = "@#{mid}".to_sym
        pre  = @scope.proto

        unless meth == :attr_writer
          out << process(s(:defn, mid, s(:args), s(:scope, s(:ivar, ivar))), :stmt)
        end

        unless meth == :attr_reader
          mid = "#{mid}=".to_sym
          out << process(s(:defn, mid, s(:args, :val), s(:scope,
                    s(:iasgn, ivar, s(:lvar, :val)))), :stmt)
        end
      end

      out.join(", \n#@indent") + ', nil'
    end

    def handle_alias_native(sexp)
      args = sexp[2]
      meth = mid_to_jsid args[1][1].to_s
      func = args[2][1]

      @scope.methods << meth
      "%s%s = %s.%s" % [@scope.proto, meth, @scope.proto, func]
    end

    def handle_respond_to(sexp, level)
      recv, mid, arglist = sexp
      recv ||= s(:self)
      meth = process(arglist[1], level) if arglist[1]
      "(!!#{process(recv, level)}['$' + #{meth}])"
    end

    # s(:call, recv, :mid, s(:arglist))
    # s(:call, nil, :mid, s(:arglist))
    def process_call(sexp, level)
      recv, meth, arglist, iter = sexp
      mid = mid_to_jsid meth.to_s

      case meth
      when :attr_reader, :attr_writer, :attr_accessor
        return handle_attr_optimize(meth, arglist[1..-1]) if @scope.class_scope?
      when :block_given?
        return js_block_given(sexp, level)
      when :alias_native
        return handle_alias_native(sexp) if @scope.class_scope?
      when :require
        return handle_require arglist[1]
      when :respond_to?
        return handle_respond_to(sexp, level)
      end

      splat = arglist[1..-1].any? { |a| a.first == :splat }

      if Array === arglist.last and arglist.last.first == :block_pass
        arglist << s(:js_tmp, process(arglist.pop, :expr))
      elsif iter
        block   = iter
      end

      recv ||= s(:self)

      if block
        tmprecv = @scope.new_temp
      elsif splat and recv != [:self] and recv[0] != :lvar
        tmprecv = @scope.new_temp
      else # method_missing
       tmprecv = @scope.new_temp
      end

      args      = ""

      recv_code = process recv, :recv

      if @method_missing
        call_recv = s(:js_tmp, tmprecv || recv_code)
        arglist.insert 1, call_recv unless splat
        args = process arglist, :expr

        dispatch = if tmprecv
          "((#{tmprecv} = #{recv_code})#{mid} || $mm('#{ meth.to_s }'))"
        else
          "(#{recv_code}#{mid} || $mm('#{ meth.to_s }'))"
        end

        result = if splat
          "#{dispatch}.apply(#{process call_recv, :expr}, #{args})"
        else
          "#{dispatch}.call(#{args})"
        end
      else
        args = process arglist, :expr
        dispatch = tmprecv ? "(#{tmprecv} = #{recv_code})#{mid}" : "#{recv_code}#{mid}"
        result = splat ? "#{dispatch}.apply(#{tmprecv || recv_code}, #{args})" : "#{dispatch}(#{args})"
      end

      @scope.queue_temp tmprecv if tmprecv
      result
    end

    def handle_require(sexp)
      str = handle_require_sexp sexp
      @requires << str
      ""
    end

    def handle_require_sexp(sexp)
      type = sexp.shift

      if type == :str
        return sexp[0]
      elsif type == :call
        recv, meth, args = sexp
        parts = args[1..-1].map { |s| handle_require_sexp s }

        if recv == [:const, :File]
          if meth == :expand_path
            return handle_expand_path(*parts)
          elsif meth == :join
            return handle_expand_path parts.join("/")
          elsif meth == :dirname
            return handle_expand_path parts[0].split("/")[0...-1].join("/")
          end
        end
      end

      error "Cannot handle dynamic require"
    end

    def handle_expand_path(path, base = '')
      "#{base}/#{path}".split("/").inject([]) do |path, part|
        if part == ''
          # we had '//', so ignore
        elsif part == '..'
          path.pop
        else
          path << part
        end

        path
      end.join "/"
    end

    # s(:arglist, [arg [, arg ..]])
    def process_arglist(sexp, level)
      code = ''
      work = []

      until sexp.empty?
        splat = sexp.first.first == :splat
        arg   = process sexp.shift, :expr

        if splat
          if work.empty?
            if code.empty?
              code += "[].concat(#{arg})"
            else
              code += ".concat(#{arg})"
            end
          else
            join  = "[#{work.join ', '}]"
            code += (code.empty? ? join : ".concat(#{join})")
            code += ".concat(#{arg})"
          end

          work = []
        else
          work.push arg
        end
      end

      unless work.empty?
        join  = work.join ', '
        code += (code.empty? ? join : ".concat([#{join}])")
      end

      code
    end

    # s(:splat, sexp)
    def process_splat(sexp, level)
      return "[]" if sexp.first == [:nil]
      return "[#{process sexp.first, :expr}]" if sexp.first.first == :lit
      process sexp.first, :recv
    end

    # s(:class, cid, super, body)
    def process_class(sexp, level)
      cid, sup, body = sexp

      body[1] = s(:nil) unless body[1]

      code = nil
      @helpers[:klass] = true

      if Symbol === cid or String === cid
        base = current_self
        name = cid.to_s
      elsif cid[0] == :colon2
        base = process(cid[1], :expr)
        name = cid[2].to_s
      elsif cid[0] == :colon3
        base = 'Opal.Object'
        name = cid[1].to_s
      else
        raise "Bad receiver in class"
      end

      sup = sup ? process(sup, :expr) : 'null'

      indent do
        in_scope(:class) do
          @scope.name = name
          @scope.add_temp "#{ @scope.proto } = #{name}.prototype", "__scope = #{name}._scope"

          if Array === body.last
            # A single statement will need a block
            needs_block = body.last.first != :block
            body.last.first == :block
            last_body_statement = needs_block ? body.last : body.last.last

            if last_body_statement and Array === last_body_statement
              if [:defn, :defs].include? last_body_statement.first
                body[-1] = s(:block, body[-1]) if needs_block
                body.last << s(:nil)
              end
            end
          end

          body = returns(body)
          body = process body, :stmt
          code = "\n#{@scope.to_donate_methods}"
          code += @indent + @scope.to_vars + "\n\n#@indent" + body
        end
      end

      spacer  = "\n#{@indent}#{INDENT}"
      cls     = "function #{name}() {};"
      boot    = "#{name} = __klass(__base, __super, #{name.inspect}, #{name});"

      "(function(__base, __super){#{spacer}#{cls}#{spacer}#{boot}\n#{code}\n#{@indent}})(#{base}, #{sup})"
    end

    # s(:sclass, recv, body)
    def process_sclass(sexp, level)
      recv = sexp[0]
      body = sexp[1]
      code = nil

      in_scope(:sclass) do
        @scope.add_temp "__scope = #{current_self}._scope"
        @scope.add_temp "def = #{current_self}.prototype"

        code = @scope.to_vars + process(body, :stmt)
      end

      call = s(:call, recv, :singleton_class, s(:arglist))

      "(function(){#{ code }}).call(#{ process call, :expr })"
    end

    # s(:module, cid, body)
    def process_module(sexp, level)
      cid = sexp[0]
      body = sexp[1]
      code = nil
      @helpers[:module] = true

      if Symbol === cid or String === cid
        base = current_self
        name = cid.to_s
      elsif cid[0] == :colon2
        base = process(cid[1], :expr)
        name = cid[2].to_s
      elsif cid[0] == :colon3
        base = 'Opal.Object'
        name = cid[1].to_s
      else
        raise "Bad receiver in class"
      end

      indent do
        in_scope(:module) do
          @scope.name = name
          @scope.add_temp "#{ @scope.proto } = #{name}.prototype", "__scope = #{name}._scope"
          body = process body, :stmt
          code = @indent + @scope.to_vars + "\n\n#@indent" + body + "\n#@indent" + @scope.to_donate_methods
        end
      end

      spacer  = "\n#{@indent}#{INDENT}"
      cls     = "function #{name}() {};"
      boot    = "#{name} = __module(__base, #{name.inspect}, #{name});"

      "(function(__base){#{spacer}#{cls}#{spacer}#{boot}\n#{code}\n#{@indent}})(#{base})"
    end


    # undef :foo
    # => delete MyClass.prototype.$foo
    def process_undef(sexp, level)
      "delete #{ @scope.proto }#{ mid_to_jsid sexp[0][1].to_s }"
    end

    # s(:defn, mid, s(:args), s(:scope))
    def process_defn(sexp, level)
      mid, args, stmts = sexp

      js_def nil, mid, args, stmts, sexp.line, sexp.end_line
    end

    # s(:defs, recv, mid, s(:args), s(:scope))
    def process_defs(sexp, level)
      recv, mid, args, stmts = sexp

      js_def recv, mid, args, stmts, sexp.line, sexp.end_line
    end

    def js_def(recvr, mid, args, stmts, line, end_line)
      jsid = mid_to_jsid mid.to_s

      if recvr
        @scope.defines_defs = true
        smethod = true if @scope.class_scope? && recvr.first == :self
        recv = process(recvr, :expr)
      else
        @scope.defines_defn = true
        recv = current_self
      end

      code = ''
      params = nil
      scope_name = nil
      uses_super = nil
      uses_splat = nil

      # opt args if last arg is sexp
      opt = args.pop if Array === args.last

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
          #args[-1] = splat
          argc -= 1
        else
          splat = args[-1].to_s[1..-1].to_sym
          args[-1] = splat
          argc -= 1
        end
      end

      args << block_name if block_name # have to re-add incase there was a splat arg

      if @arity_check
        arity_code = arity_check(args, opt, uses_splat, block_name, mid) + "\n#{INDENT}"
      end

      indent do
        in_scope(:def) do
          @scope.mid  = mid
          @scope.defs = true if recvr

          if block_name
            @scope.uses_block!
          end

          yielder = block_name || '__yield'
          @scope.block_name = yielder

          params = process args, :expr
          stmt_code = "\n#@indent" + process(stmts, :stmt)

          if @scope.uses_block?
            # CASE 1: no args - only the block
            if argc == 0 and !splat
              # add param name as a function param, to make it cleaner
              # params = yielder
              code += "if (typeof(#{yielder}) !== 'function') { #{yielder} = nil }"
            # CASE 2: we have a splat - use argc to get splat args, then check last one
            elsif splat
              @scope.add_temp yielder
              code += "#{splat} = __slice.call(arguments, #{argc});\n#{@indent}"
              code += "if (typeof(#{splat}[#{splat}.length - 1]) === 'function') { #{yielder} = #{splat}.pop(); } else { #{yielder} = nil; }\n#{@indent}"
            # CASE 3: we have some opt args
            elsif opt
              code += "var BLOCK_IDX = arguments.length - 1;\n#{@indent}"
              code += "if (typeof(arguments[BLOCK_IDX]) === 'function' && arguments[BLOCK_IDX]._s !== undefined) { #{yielder} = arguments[BLOCK_IDX] } else { #{yielder} = nil }"
              lastopt = opt[-1][1]
              opt[1..-1].each do |o|
                id = process s(:lvar, o[1]), :expr
                if o[2][2] == :undefined
                  code += ("if (%s === %s && typeof(%s) === 'function') { %s = undefined; }" % [id, yielder, id, id])
                else
                  code += ("if (%s == null || %s === %s) {\n%s%s\n%s}" %
                          [id, id, yielder, @indent + INDENT, process(o, :expre), @indent])
                end
              end

            # CASE 4: normal args and block
            else
              code += "if (typeof(#{yielder}) !== 'function') { #{yielder} = nil }"
            end
          else
            opt[1..-1].each do |o|
              next if o[2][2] == :undefined
              id = process s(:lvar, o[1]), :expr
              code += ("if (%s == null) {\n%s%s\n%s}" %
                        [id, @indent + INDENT, process(o, :expre), @indent])
            end if opt

            code += "#{splat} = __slice.call(arguments, #{argc});" if splat          
          end

          code += stmt_code

          if @scope.uses_block? and !block_name
            params = params.empty? ? yielder : "#{params}, #{yielder}"
          end

          # Returns the identity name if identified, nil otherwise
          scope_name = @scope.identity

          uses_super = @scope.uses_super

          code = "#{arity_code}#@indent#{@scope.to_vars}" + code
        end
      end

      defcode = "#{"#{scope_name} = " if scope_name}function(#{params}) {\n#{code}\n#@indent}"

      if recvr
        if smethod
          "#{ @scope.name }._defs('$#{mid}', #{defcode})"
        else
          "#{ recv }#{ jsid } = #{ defcode }"
        end
      elsif @scope.class? and @scope.name == 'Object'
        "#{current_self}._defn('$#{mid}', #{defcode})"
      elsif @scope.class_scope?
        @scope.methods << "$#{mid}"
        if uses_super
          @scope.add_temp uses_super
          uses_super = "#{uses_super} = #{@scope.proto}#{jsid};\n#@indent"
        end
        "#{uses_super}#{ @scope.proto }#{jsid} = #{defcode}"
      # elsif @scope.sclass?
        # "#{ current_self }._defs('$#{mid}', #{defcode})"
      elsif @scope.type == :iter
        "def#{jsid} = #{defcode}"
      elsif @scope.type == :top
        "#{ current_self }#{ jsid } = #{ defcode }"
      else
        "def#{jsid} = #{defcode}"
      end
    end

    ##
    # Returns code used in debug mode to check arity of method call
    def arity_check(args, opt, splat, block_name, mid)
      meth = mid.to_s.inspect

      arity = args.size - 1
      arity -= (opt.size - 1) if opt
      arity -= 1 if splat
      arity -= 1 if block_name
      arity = -arity - 1 if opt or splat

      # $arity will point to our received arguments count
      aritycode = "var $arity = arguments.length;"

      if arity < 0 # splat or opt args
        aritycode + "if ($arity < #{-(arity + 1)}) { __opal.ac($arity, #{arity}, this, #{meth}); }"
      else
        aritycode + "if ($arity !== #{arity} && (typeof(arguments[$arity - 1]) !== 'function' || ($arity - 1) !== #{arity})) { __opal.ac($arity, #{arity}, this, #{meth}); }"
      end
    end

    def process_args(exp, level)
      args = []

      until exp.empty?
        a = exp.shift.to_sym
        next if a.to_s == '*'
        a = "#{a}$".to_sym if RESERVED.include? a.to_s
        @scope.add_arg a
        args << a
      end

      args.join ', '
    end

    # s(:self)  # => this
    def process_self(sexp, level)
      current_self
    end

    # Returns the current value for 'self'. This will be native
    # 'this' for methods and blocks, and the class name for class
    # and module bodies.
    def current_self
      if @scope.class_scope?
        @scope.name
      elsif @scope.top? or @scope.iter?
        'self'
      else # defn, defs
        'this'
      end
    end

    # s(:true)  # => true
    # s(:false) # => false
    # s(:nil)   # => nil
    %w(true false nil).each do |name|
      define_method "process_#{name}" do |exp, level|
        name
      end
    end

    # s(:array [, sexp [, sexp]])
    def process_array(sexp, level)
      return '[]' if sexp.empty?

      code = ''
      work = []

      until sexp.empty?
        splat = sexp.first.first == :splat
        part  = process sexp.shift, :expr

        if splat
          if work.empty?
            code += (code.empty? ? part : ".concat(#{part})")
          else
            join  = "[#{work.join ', '}]"
            code += (code.empty? ? join : ".concat(#{join})")
            code += ".concat(#{part})"
          end
          work = []
        else
          work << part
        end
      end

      unless work.empty?
        join  = "[#{work.join ', '}]"
        code += (code.empty? ? join : ".concat(#{join})")
      end

      code
    end

    # s(:hash, key1, val1, key2, val2...)
    def process_hash(sexp, level)
      keys = []
      vals = []

      sexp.each_with_index do |obj, idx|
        if idx.even?
          keys << obj
        else
          vals << obj
        end
      end

      if keys.all? { |k| [:lit, :str].include? k[0] }
        hash_obj  = {}
        hash_keys = []
        keys.size.times do |i|
          k = process(keys[i], :expr)
          hash_keys << k unless hash_obj.include? k
          hash_obj[k] = process(vals[i], :expr)
        end

        map = hash_keys.map { |k| "#{k}: #{hash_obj[k]}"}

        @helpers[:hash2] = true
        "__hash2([#{hash_keys.join ', '}], {#{map.join(', ')}})"
      else
        @helpers[:hash] = true
        "__hash(#{sexp.map { |p| process p, :expr }.join ', '})"
      end
    end

    # s(:while, exp, block, true)
    def process_while(sexp, level)
      expr, stmt = sexp
      redo_var = @scope.new_temp

      stmt_level = if level == :expr or level == :recv
                     :stmt_closure
                    else
                      :stmt
                    end
      pre = "while ("
      code = "#{js_truthy expr}){"

      in_while do
        @while_loop[:closure] = true if stmt_level == :stmt_closure
        @while_loop[:redo_var] = redo_var
        body = process(stmt, :stmt)

        if @while_loop[:use_redo]
          pre = "#{redo_var}=false;" + pre + "#{redo_var} || "
          code += "#{redo_var}=false;"
        end

        code += body
      end

      code += "}"
      code = pre + code
      @scope.queue_temp redo_var

      if stmt_level == :stmt_closure
        code = "(function() {#{code}; return nil;}).call(#{current_self})"
      end

      code
    end

    def process_until(exp, level)
      expr = exp[0]
      stmt = exp[1]
      redo_var   = @scope.new_temp
      stmt_level = if level == :expr or level == :recv
                     :stmt_closure
                   else
                     :stmt
                   end
      pre = "while (!("
      code = "#{js_truthy expr})) {"

      in_while do
        @while_loop[:closure] = true if stmt_level == :stmt_closure
        @while_loop[:redo_var] = redo_var
        body = process(stmt, :stmt)

        if @while_loop[:use_redo]
          pre = "#{redo_var}=false;" + pre + "#{redo_var} || "
          code += "#{redo_var}=false;"
        end

        code += body
      end

      code += "}"
      code = pre + code
      @scope.queue_temp redo_var

      if stmt_level == :stmt_closure
        code = "(function() {#{code}; return nil;}).call(#{current_self})"
      end

      code
    end

    # alias foo bar
    #
    # s(:alias, s(:lit, :foo), s(:lit, :bar))
    def process_alias(exp, level)
      new = mid_to_jsid exp[0][1].to_s
      old = mid_to_jsid exp[1][1].to_s

      if [:class, :module].include? @scope.type
        @scope.methods << "$#{exp[0][1].to_s}"
        "%s%s = %s%s" % [@scope.proto, new, @scope.proto, old]
      else
        current = current_self
        "%s.prototype%s = %s.prototype%s" % [current, new, current, old]
      end
    end

    def process_masgn(sexp, level)
      lhs = sexp[0]
      rhs = sexp[1]
      tmp = @scope.new_temp
      len = 0

      # remote :array part
      lhs.shift
      if rhs[0] == :array
        len = rhs.length - 1 # we are guaranteed an array of this length
        code  = ["#{tmp} = #{process rhs, :expr}"]
      elsif rhs[0] == :to_ary
        code = ["((#{tmp} = #{process rhs[1], :expr})._isArray ? #{tmp} : (#{tmp} = [#{tmp}]))"]
      elsif rhs[0] == :splat
        code = ["#{tmp} = #{process rhs[1], :expr}"]
      else
        raise "Unsupported mlhs type"
      end

      lhs.each_with_index do |l, idx|

        if l.first == :splat
          s = l[1]
          s << s(:js_tmp, "__slice.call(#{tmp}, #{idx})")
          code << process(s, :expr)
        else
          if idx >= len
            l << s(:js_tmp, "(#{tmp}[#{idx}] == null ? nil : #{tmp}[#{idx}])")
          else
            l << s(:js_tmp, "#{tmp}[#{idx}]")
          end
          code << process(l, :expr)
        end
      end

      @scope.queue_temp tmp
      code.join ', '
    end

    def process_svalue(sexp, level)
      process sexp.shift, level
    end

    # s(:lasgn, :lvar, rhs)
    def process_lasgn(sexp, level)
      lvar = sexp[0]
      rhs  = sexp[1]
      lvar = "#{lvar}$".to_sym if RESERVED.include? lvar.to_s
      @scope.add_local lvar
      res = "#{lvar} = #{process rhs, :expr}"
      level == :recv ? "(#{res})" : res
    end

    # s(:lvar, :lvar)
    def process_lvar(exp, level)
      lvar = exp.shift.to_s
      lvar = "#{lvar}$" if RESERVED.include? lvar
      lvar
    end

    # s(:iasgn, :ivar, rhs)
    def process_iasgn(exp, level)
      ivar = exp[0]
      rhs = exp[1]
      ivar = ivar.to_s[1..-1]
      lhs = RESERVED.include?(ivar) ? "#{current_self}['#{ivar}']" : "#{current_self}.#{ivar}"
      "#{lhs} = #{process rhs, :expr}"
    end

    # s(:ivar, :ivar)
    def process_ivar(exp, level)
      ivar = exp.shift.to_s[1..-1]
      part = RESERVED.include?(ivar) ? "['#{ivar}']" : ".#{ivar}"
      @scope.add_ivar part
      "#{current_self}#{part}"
    end

    # s(:gvar, gvar)
    def process_gvar(sexp, level)
      gvar = sexp.shift.to_s[1..-1]
      @helpers['gvars'] = true
      "__gvars[#{gvar.inspect}]"
    end

    # s(:gasgn, :gvar, rhs)
    def process_gasgn(sexp, level)
      gvar = sexp[0].to_s[1..-1]
      rhs  = sexp[1]
      @helpers['gvars'] = true
      "__gvars[#{gvar.to_s.inspect}] = #{process rhs, :expr}"
    end

    # s(:const, :const)
    def process_const(sexp, level)
      cname = sexp.shift.to_s

      with_temp do |t|
        "((#{t} = __scope.#{cname}) == null ? __opal.cm(#{cname.inspect}) : #{t})"
      end
    end

    # s(:cdecl, :const, rhs)
    def process_cdecl(sexp, level)
      const = sexp[0]
      rhs   = sexp[1]
      "__scope.#{const} = #{process rhs, :expr}"
    end

    # s(:return [val])
    def process_return(sexp, level)
      val = process(sexp.shift || s(:nil), :expr)

      raise SyntaxError, "void value expression: cannot return as an expression" unless level == :stmt
      "return #{val}"
    end

    # s(:xstr, content)
    def process_xstr(sexp, level)
      code = sexp.first.to_s
      code += ";" if level == :stmt and !code.include?(';')
      level == :recv ? "(#{code})" : code
    end

    # s(:dxstr, parts...)
    def process_dxstr(sexp, level)
      code = sexp.map do |p|
        if String === p
          p.to_s
        elsif p.first == :evstr
          process p.last, :stmt
        elsif p.first == :str
          p.last.to_s
        else
          raise "Bad dxstr part"
        end
      end.join

      code += ";" if level == :stmt and !code.include?(';')
      code = "(#{code})" if level == :recv
      code
    end

    # s(:dstr, parts..)
    def process_dstr(sexp, level)
      parts = sexp.map do |p|
        if String === p
          p.inspect
        elsif p.first == :evstr
          "(" + process(p.last, :expr) + ")"
        elsif p.first == :str
          p.last.inspect
        else
          raise "Bad dstr part"
        end
      end

      res = parts.join ' + '
      level == :recv ? "(#{res})" : res
    end

    def process_dsym(sexp, level)
      parts = sexp.map do |p|
        if String === p
          p.inspect
        elsif p.first == :evstr
          process(s(:call, p.last, :to_s, s(:arglist)), :expr)
        elsif p.first == :str
          p.last.inspect
        else
          raise "Bad dsym part"
        end
      end

      "(#{parts.join '+'})"
    end

    # s(:if, test, truthy, falsy)
    def process_if(sexp, level)
      test, truthy, falsy = sexp
      returnable = (level == :expr or level == :recv)

      if returnable
        truthy = returns(truthy || s(:nil))
        falsy = returns(falsy || s(:nil))
      end

      # optimize unless (we don't want else unless we need to)
      if falsy and !truthy
        truthy = falsy
        falsy  = nil
        check  = js_falsy test
      else
        check = js_truthy test
      end

      code = "if (#{check}) {\n"
      indent { code += @indent + process(truthy, :stmt) } if truthy
      indent { code += "\n#@indent} else {\n#@indent#{process falsy, :stmt}" } if falsy
      code += "\n#@indent}"

      code = "(function() { #{code}; return nil; }).call(#{current_self})" if returnable

      code
    end

    def js_truthy_optimize(sexp)
      if sexp.first == :call
        mid = sexp[2]
        if mid == :block_given?
          return process sexp, :expr
        elsif COMPARE.include? mid.to_s
          return process sexp, :expr
        elsif mid == :"=="
          return process sexp, :expr
        end
      elsif [:lvar, :self].include? sexp.first
        name = process sexp, :expr
        "#{name} !== false && #{name} !== nil"
      end
    end

    def js_truthy(sexp)
      if optimized = js_truthy_optimize(sexp)
        return optimized
      end

      with_temp do |tmp|
        "(%s = %s) !== false && %s !== nil" % [tmp, process(sexp, :expr), tmp]
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
        "(%s = %s) === false || %s === nil" % [tmp, process(sexp, :expr), tmp]
      end
    end

    # s(:and, lhs, rhs)
    def process_and(sexp, level)
      lhs = sexp[0]
      rhs = sexp[1]
      t = nil
      tmp = @scope.new_temp

      if t = js_truthy_optimize(lhs)
        return "((#{tmp} = #{t}) ? #{process rhs, :expr} : #{tmp})".tap {
          @scope.queue_temp tmp
        }
      end

      @scope.queue_temp tmp

      "(%s = %s, %s !== false && %s !== nil ? %s : %s)" %
        [tmp, process(lhs, :expr), tmp, tmp, process(rhs, :expr), tmp]
    end

    # s(:or, lhs, rhs)
    def process_or(sexp, level)
      lhs = sexp[0]
      rhs = sexp[1]
      t = nil

      with_temp do |tmp|
        "((%s = %s), %s !== false && %s !== nil ? %s : %s)" %
          [tmp, process(lhs, :expr), tmp, tmp, tmp, process(rhs, :expr)]
      end
    end

    # s(:yield, arg1, arg2)
    def process_yield(sexp, level)
      call = handle_yield_call sexp, level

      if level == :stmt
        "if (#{call} === __breaker) return __breaker.$v"
      else
        with_temp do |tmp|
          "(((#{tmp} = #{call}) === __breaker) ? __breaker.$v : #{tmp})"
        end
      end
    end

    # special opal yield assign, for `a = yield(arg1, arg2)` to assign
    # to a temp value to make yield expr into stmt.
    #
    # level will always be stmt as its the reason for this to exist
    #
    # s(:yasgn, :a, s(:yield, arg1, arg2))
    def process_yasgn(sexp, level)
      call = handle_yield_call s(*sexp[1][1..-1]), :stmt
      "if ((%s = %s) === __breaker) return __breaker.$v" % [sexp[0], call]
    end

    # Created by `#returns()` for when a yield statement should return
    # it's value (its last in a block etc).
    def process_returnable_yield(sexp, level)
      call = handle_yield_call sexp, level

      with_temp do |tmp|
        "return %s = %s, %s === __breaker ? %s : %s" %
          [tmp, call, tmp, tmp, tmp]
      end
    end

    def handle_yield_call(sexp, level)
      @scope.uses_block!

      splat = sexp.any? { |s| s.first == :splat }
      sexp.unshift s(:js_tmp, 'null') unless splat    # self
      args = process_arglist sexp, level

      y = @scope.block_name || '__yield'

      splat ? "#{y}.apply(null, #{args})" : "#{y}.call(#{args})"
    end

    def process_break(exp, level)
      val = exp.empty? ? 'nil' : process(exp.shift, :expr)
      if in_while?
        @while_loop[:closure] ? "return #{ val };" : "break;"
      elsif @scope.iter?
        error "break must be used as a statement" unless level == :stmt
        "return (__breaker.$v = #{ val }, __breaker)"
      else
        error "void value expression: cannot use break outside of iter/while"
      end
    end

    # s(:case, expr, when1, when2, ..)
    def process_case(exp, level)
      code = []
      @scope.add_local "$case"
      expr = process exp.shift, :expr
      # are we inside a statement_closure
      returnable = level != :stmt
      done_else = false

      until exp.empty?
        wen = exp.shift
        if wen and wen.first == :when
          returns(wen) if returnable
          wen = process(wen, :stmt)
          wen = "else #{wen}" unless code.empty?
          code << wen
        elsif wen # s(:else)
          done_else = true
          wen = returns(wen) if returnable
          code << "else {#{process wen, :stmt}}"
        end
      end

      code << "else {return nil}" if returnable and !done_else

      code = "$case = #{expr};#{code.join @space}"
      code = "(function() { #{code} }).call(#{current_self})" if returnable
      code
    end

    # when foo
    #   bar
    #
    # s(:when, s(:array, foo), bar)
    def process_when(exp, level)
      arg = exp.shift[1..-1]
      body = exp.shift
      body = process body, level if body

      test = []
      until arg.empty?
        a = arg.shift

        if a.first == :splat # when inside another when means a splat of values
          call  = s(:call, s(:js_tmp, "$splt[i]"), :===, s(:arglist, s(:js_tmp, "$case")))
          splt  = "(function($splt) {for(var i = 0; i < $splt.length; i++) {"
          splt += "if (#{process call, :expr}) { return true; }"
          splt += "} return false; }).call(#{current_self}, #{process a[1], :expr})"

          test << splt
        else
          call = s(:call, a, :===, s(:arglist, s(:js_tmp, "$case")))
          call = process call, :expr
          # call = "else " unless test.empty?

          test << call
        end
      end

      "if (%s) {%s%s%s}" % [test.join(' || '), @space, body, @space]
    end

    # lhs =~ rhs
    #
    # s(:match3, lhs, rhs)
    def process_match3(sexp, level)
      lhs = sexp[0]
      rhs = sexp[1]
      call = s(:call, lhs, :=~, s(:arglist, rhs))
      process call, level
    end

    # @@class_variable
    #
    # s(:cvar, name)
    def process_cvar(exp, level)
      with_temp do |tmp|
        "((%s = Opal.cvars[%s]) == null ? nil : %s)" %
          [tmp, exp.shift.to_s.inspect, tmp]
      end
    end

    # @@name = rhs
    #
    # s(:cvasgn, :@@name, rhs)
    def process_cvasgn(exp, level)
      "(Opal.cvars[#{exp.shift.to_s.inspect}] = #{process exp.shift, :expr})"
    end

    def process_cvdecl(exp, level)
      "(Opal.cvars[#{exp.shift.to_s.inspect}] = #{process exp.shift, :expr})"
    end

    # BASE::NAME
    #
    # s(:colon2, base, :NAME)
    def process_colon2(sexp, level)
      base = sexp[0]
      cname = sexp[1].to_s

      with_temp do |t|
        base = process base, :expr
        "((#{t} = (#{base})._scope.#{cname}) == null ? __opal.cm(#{cname.inspect}) : #{t})"
      end
    end

    def process_colon3(exp, level)
      with_temp do |t|
        cname = exp.shift.to_s
        "((#{t} = __opal.Object._scope.#{cname}) == null ? __opal.cm(#{cname.inspect}) : #{t})"
      end
    end

    # super a, b, c
    #
    # s(:super, arg1, arg2, ...)
    def process_super(sexp, level)
      args = []
      until sexp.empty?
        args << process(sexp.shift, :expr)
      end

      js_super "[#{ args.join ', ' }]"
    end

    # super
    #
    # s(:zsuper)
    def process_zsuper(exp, level)
      js_super "__slice.call(arguments)"
    end

    def js_super args
      if @scope.def_in_class?
        mid = @scope.mid.to_s
        sid = "super_#{unique_temp}"

        @scope.uses_super = sid
        "#{sid}.apply(#{current_self}, #{ args })"

      elsif @scope.type == :def
        identity = @scope.identify!
        cls_name = @scope.parent.name || "#{current_self}._klass.prototype"
        jsid     = mid_to_jsid @scope.mid.to_s

        if @scope.defs
          "%s._super%s.apply(this, %s)" % [cls_name, jsid, args]
        else
          "#{current_self}._klass._super.prototype%s.apply(#{current_self}, %s)" % [jsid, args]
        end

      elsif @scope.type == :iter
        chain, defn, mid = @scope.get_super_chain
        trys = chain.map { |c| "#{c}._sup" }.join ' || '
        "(#{trys} || #{current_self}._klass._super.prototype[#{mid}]).apply(#{current_self}, #{args})"
      else
        raise "Cannot call super() from outside a method block"
      end
    end

    # a ||= rhs
    #
    # s(:op_asgn_or, s(:lvar, :a), s(:lasgn, :a, rhs))
    def process_op_asgn_or(exp, level)
      process s(:or, exp.shift, exp.shift), :expr
    end

    # a &&= rhs
    #
    # s(:op_asgn_and, s(:lvar, :a), s(:lasgn, :a, rhs))
    def process_op_asgn_and(sexp, level)
      process s(:and, sexp.shift, sexp.shift), :expr
    end

    # lhs[args] ||= rhs
    #
    # s(:op_asgn1, lhs, args, :||, rhs)
    def process_op_asgn1(sexp, level)
      lhs, arglist, op, rhs = sexp

      with_temp do |a| # args
        with_temp do |r| # recv
          args = process arglist[1], :expr
          recv = process lhs, :expr

          aref = s(:call, s(:js_tmp, r), :[], s(:arglist, s(:js_tmp, a)))
          aset = s(:call, s(:js_tmp, r), :[]=, s(:arglist, s(:js_tmp, a), rhs))
          orop = s(:or, aref, aset)

          "(#{a} = #{args}, #{r} = #{recv}, #{process orop, :expr})"
        end
      end
    end

    # lhs.b += rhs
    #
    # s(:op_asgn2, lhs, :b=, :+, rhs)
    def process_op_asgn2(exp, level)
      lhs = process exp.shift, :expr
      mid = exp.shift.to_s[0..-2]
      op  = exp.shift
      rhs = exp.shift

      if op.to_s == "||"
        with_temp do |temp|
          getr = s(:call, s(:js_tmp, temp), mid, s(:arglist))
          asgn = s(:call, s(:js_tmp, temp), "#{mid}=", s(:arglist, rhs))
          orop = s(:or, getr, asgn)

          "(#{temp} = #{lhs}, #{process orop, :expr})"
        end
      elsif op.to_s == '&&'
        with_temp do |temp|
          getr = s(:call, s(:js_tmp, temp), mid, s(:arglist))
          asgn = s(:call, s(:js_tmp, temp), "#{mid}=", s(:arglist, rhs))
          andop = s(:and, getr, asgn)

          "(#{temp} = #{lhs}, #{process andop, :expr})"
        end
      else
        with_temp do |temp|
          getr = s(:call, s(:js_tmp, temp), mid, s(:arglist))
          oper = s(:call, getr, op, s(:arglist, rhs))
          asgn = s(:call, s(:js_tmp, temp), "#{mid}=", s(:arglist, oper))

          "(#{temp} = #{lhs}, #{process asgn, :expr})"
        end
      end
    end

    # s(:ensure, body, ensure)
    def process_ensure(exp, level)
      begn = exp.shift
      if level == :recv || level == :expr
        retn = true
        begn = returns begn
      end

      body = process begn, level
      ensr = exp.shift || s(:nil)
      ensr = process ensr, level
      body = "try {\n#{body}}" unless body =~ /^try \{/

      res = "#{body}#{@space}finally {#{@space}#{ensr}}"
      res = "(function() { #{res}; }).call(#{current_self})" if retn
      res
    end

    def process_rescue(exp, level)
      body = exp.first.first == :resbody ? s(:nil) : exp.shift
      body = indent { process body, level }
      handled_else = false

      parts = []
      until exp.empty?
        handled_else = true unless exp.first.first == :resbody
        part = indent { process exp.shift, level }
        part = "else " + part unless parts.empty?
        parts << part
      end
      # if no rescue statement captures our error, we should rethrow
      parts << indent { "else { throw $err; }" } unless handled_else

      code = "try {#@space#{INDENT}#{body}#@space} catch ($err) {#@space#{parts.join @space}#{@space}}"
      code = "(function() { #{code} }).call(#{current_self})" if level == :expr

      code
    end

    def process_resbody(exp, level)
      args = exp[0]
      body = exp[1]

      body = process(body || s(:nil), level)
      types = args[1..-2]

      err = types.map { |t|
        call = s(:call, t, :===, s(:arglist, s(:js_tmp, "$err")))
        a = process call, :expr
        a
      }.join ', '
      err = "true" if err.empty?

      if Array === args.last and [:lasgn, :iasgn].include? args.last.first
        val = args.last
        val[2] = s(:js_tmp, "$err")
        val = process(val, :expr) + ";"
      end

      "if (#{err}) {#{@space}#{val}#{body}}"
    end

    # FIXME: Hack.. grammar should remove top level begin.
    def process_begin(exp, level)
      process exp[0], level
    end

    def process_next(exp, level)
      val = exp.empty? ? 'nil' : process(exp.shift, :expr)

      if in_while?
        "continue;"
      else
        "return #{val};"
      end
    end

    def process_redo(exp, level)
      if in_while?
        @while_loop[:use_redo] = true
        "#{@while_loop[:redo_var]} = true"
      else
        "REDO()"
      end
    end
  end
end
