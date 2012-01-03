require 'opal/parser/lexer'
require 'opal/parser/grammar'
require 'opal/parser/scope'

module Opal
  class OpalParseError < Exception; end

  class Parser
    def self.to_syms(ary)
      ary.map &:to_sym
    end

    INDENT = '  '

    LEVEL = to_syms(%w[statement statement_closure list expression receiver])

    # Maths operators
    MATH = %w(+ - / * %)

    # Comparison operators
    COMPARE = %w(< <= > >=)

    # All operators that can be optimized in method calls
    CALL_OPERATORS = MATH + COMPARE

    # Reserved javascript keywords - we cannot create variables with the
    # same name
    RESERVED = %w(
      break case catch continue debugger default delete do else finally for
      function if in instanceof new return switch this throw try typeof var let
      void while with class enum export extends import super true false native
      const
    )

    METHOD_NAMES = {
      :==  => 'eq',
      :=== => 'eqq',
      :[]  => 'aref',
      :[]= => 'aset',
      :~   => 'tild',
      :<=> => 'cmp',
      :=~  => 'match',
      :+   => 'plus',
      :-   => 'minus',
      :/   => 'div',
      :*   => 'mul',
      :<   => 'lt',
      :<=  => 'le',
      :>   => 'gt',
      :>=  => 'ge',
      :<<  => 'lshft',
      :>>  => 'rshft',
      :|   => 'or',
      :&   => 'and',
      :^   => 'xor',
      :+@  => 'uplus',
      :-@  => 'uminus',
      :%   => 'mod',
      :**  => 'pow'
    }

    RUNTIME_HELPERS = %w[zuper breaker no_proc klass defn defs const_get range hash slice send arg_error mm alias gvars]

    # Type info for flags of objects. This helps identify the type of object
    # being dealt with
    TYPES = {
      class:     0x0001,
      module:    0x0002,
      object:    0x0004,
      boolean:   0x0008,
      string:    0x0010,
      array:     0x0020,
      number:    0x0040,
      proc:      0x0080,
      hash:      0x0100,
      range:     0x0200,
      iclass:    0x0400,
      singleton: 0x0800
    }

    STATEMENTS = to_syms(%w[xstr dxstr])

    def initialize(opts = {})
      @debug = opts[:debug] or false
    end

    def parse(source, file = '(file)')
      @file = file
      parser = Grammar.new
      reset

      begin
        top parser.parse(source, file)
      rescue Exception => e
        raise OpalParseError.new("#{e.message}\nfrom parsing #{file}:#{parser.line}")
      end
    end

    def s(*parts)
      sexp = Sexp.new *parts
      sexp.line = @line
      sexp
    end

    ##
    # Wrap with runtime helpers etc as well

    def wrap_with_runtime_helpers(js)
      code  = "(function($opal) { var nil = $opal.nil, $const = $opal.constants, "
      code += RUNTIME_HELPERS.map { |name| "$#{name} = $opal.#{name}" }.join ', '
      code += ";\n#{js};\n})(opal)"
    end

    ##
    # Special wrap for core

    def wrap_core_with_runtime_helpers(js)
      code  = "function(FILE) { var $opal = opal, nil = $opal.nil, $const = $opal.constants, "
      code += RUNTIME_HELPERS.map { |name| "$#{name} = $opal.#{name}" }.join ', '
      code += ";\nvar code = #{js};\nreturn code.call(top_self, FILE);}"
    end

    def reset
      @line = 1
      @indent = ''
      @unique = 0
    end

    def mid_to_jsid(mid)
      'm$' + if name = METHOD_NAMES[mid.to_sym]
        name + '$'
      else
        mid.sub('!', '$b').sub('?', '$p').sub('=', '$e')
      end
    end

    # guaranteed unique id per file..
    def unique_temp
      "$TMP_#{@unique += 1}"
    end

    def top(sexp, options = {})
      code = nil
      vars = []

      in_scope(:top) do
        code = process s(:scope, sexp), :statement

        vars.concat @scope.locals.map { |t| "#{t}" }
        vars.concat @scope.temps.map { |t| t }

        code = "var #{vars.join ', '};" + code unless vars.empty?
      end

      pre  = "function(FILE) {"
      post = ""

      uniques = []

      @unique.times { |i| uniques << "$TMP_#{i+1}" }

      unless uniques.empty?
        post += ";var #{uniques.join ', '};"
      end

      post += "\n}"

      pre + code + post
    end

    def in_scope(type)
      return unless block_given?

      parent = @scope
      @scope = Scope.new(type).tap { |s| s.parent = parent }
      yield @scope

      @scope = parent
    end
    
    def indent(&block)
      indent = @indent
      @indent += INDENT
      res = yield
      @indent = indent
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

    def in_while?
      @scope.in_while?
    end

    def process(sexp, level)
      type = sexp.shift

      raise "Unsupported sexp: #{type}" unless respond_to? type

      line = fix_line sexp.line
      code = __send__ type, sexp, level
      line + code
    end
    
    def fix_line(line)
      res = ""
      
      if @line < line
        res = "\n" * (line - @line)
        res += @indent
        @line = line
      end
      res
    end

    def returns(sexp)
      return returns s(:nil) unless sexp

      case sexp.first
      when :break, :next
        sexp
      when :scope
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
      when :ensure
        sexp[1] = returns sexp[1]
        sexp
      when :while
        sexp[2] = returns(sexp[2])
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

    def expression?(sexp)
      !STATEMENTS.include?(sexp.first)
    end

    def block(sexp, level)
      result = []
      sexp << s(:nil) if sexp.empty?

      until sexp.empty?
        stmt = sexp.shift
        expr = expression?(stmt) and LEVEL.index(level) < LEVEL.index(:list)
        result << process(stmt, level)
        result << ";" if expr
      end

      result.join
    end

    def scope(sexp, level)
      stmt = sexp.shift
      stmt = returns stmt unless @scope.type == :module
      code = process stmt, :statement

      code
    end

    # s(:js_return, sexp)
    def js_return(sexp, level)
      "return #{process sexp.shift, :expression}"
    end

    # s(:js_tmp, str)
    def js_tmp(sexp, level)
      sexp.shift.to_s
    end

    # s(:js_block_given)
    def js_block_given(sexp, level)
      @scope.uses_block!
      "$block_given"
    end

    def js_operator_call(sexp, level)
      recv = sexp[0]
      meth = sexp[1]
      arglist = sexp[2]
      mid = mid_to_jsid meth.to_s

      a = @scope.new_temp
      b = @scope.new_temp
      l  = process recv, :expression
      r  = process arglist[1], :expression

      res = "(#{a} = #{l}, #{b} = #{r}, typeof(#{a}) === "
      res += "'number' ? #{a} #{meth} #{b} : #{a}.#{mid}"
      res += "(null, #{b}))"

      @scope.queue_temp a
      @scope.queue_temp b

      res
    end

    def js_compile_time_helpers(exp, level)
      recv = exp[0]
      meth = exp[1]
      args = exp[2]

      arg = args[1] || raise("No argument given to compile helper: #{meth}")
      arg = process arg, :expression
      tmp = @scope.new_temp

      res = case meth
      when :object?
        "(!!(#{tmp} = #{arg}, #{tmp} != null && #{tmp}.$klass))"
      when :native?
        "(!!(#{tmp} = #{arg}, #{tmp} == null || !#{tmp}.$klass))"
      when :string?
        "(typeof #{arg} === 'string')"
      when :number?
        "(typeof #{arg} === 'number')"
      when :function?
        "(typeof #{arg} === 'function')"
      when :defined?
        "((#{tmp} = typeof(#{arg})) === 'undefined' ? nil : #{tmp})"
      when :undefined?
        "(typeof(#{arg}) === 'undefined')"
      when :null?
        "(#{arg} === null)"
      when :typeof
        "(typeof(#{arg}))"
      else
        raise "Bad compile time helper: #{meth}"
      end

      @scope.queue_temp tmp

      res
    end

    # s(:lit, 1)
    # s(:lit, :foo)
    def lit(sexp, level)
      val = sexp.shift
      case val
      when Numeric
        level == :receiver ? "(#{val.inspect})" : val.inspect
      when Symbol
        val.to_s.inspect
      when Regexp
        val == // ? /^/.inspect : val.inspect
      when Range
        "$range(#{val.begin}, #{val.end}, #{val.exclude_end?})"
      else
        raise "Bad lit: #{val.inspect}"
      end
    end

    def dregx(sexp, level)
      parts = sexp.map do |part|
        if String === part
          part.inspect
        elsif part[0] == :str
          process part, :expression
        else
          process part[1], :expression
        end
      end

      "(new RegExp(#{parts.join ' + '}))"
    end

    def dot2 exp, level
      "$range(#{process exp[0], :expression}, #{process exp[1], :expression}, false)"
    end

    # s(:str, "string")
    def str(sexp, level)
      str = sexp.shift
      str == @file ? "FILE" : str.inspect
    end

    def defined(sexp, level)
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
        recv = part[1] ? process(part[1], :expression) : 'this'
        "(#{recv}.#{mid} ? 'method' : nil)"
      else
        raise "bad defined? part: #{part[0]}"
      end
    end

    # s(:not, sexp)
    def not(sexp, level)
      tmp = @scope.new_temp
      code = "((#{tmp} = #{process sexp.shift, :expression}) === false || #{tmp} === nil)"
      @scope.queue_temp tmp
      code
    end

    def block_pass(exp, level)
      pass = process exp.shift, level

      tmp = @scope.new_temp

      to_proc = process(s(:call, s(:js_tmp, tmp), :to_proc, s(:arglist)), :expression)

      code = "(#{tmp} = #{pass}, (typeof(#{tmp}) === 'function' || #{tmp} == nil ? #{tmp} : #{to_proc}))"

      @scope.queue_temp tmp

      code
    end

    # s(:iter, call, block_args [, body)
    def iter(sexp, level)
      call = sexp[0]
      args = sexp[1]
      body = sexp[2]

      body ||= s(:nil)
      body = returns body
      code = ""
      params = nil

      args = nil if Fixnum === args # argh
      args ||= s(:masgn, s(:array))
      args = args.first == :lasgn ? s(:array, args) : args[1]

      if args.last[0] == :splat
        splat = args[-1][1][1]
        args[-1] = s(:lasgn, splat)
        len = args.length
      end

      indent do
        in_scope(:iter) do
          args[1..-1].each do |arg|
            arg = arg[1]
            arg = "#{arg}$" if RESERVED.include? arg.to_s
            code += "if (#{arg} === undefined) {#{arg} = nil; }"
          end

          params = js_block_args(args[1..-1])
          params.unshift '_$'
          code += "#{splat} = $slice.call(arguments, #{len - 1});" if splat
          code += process body, :statement

          code = @scope.to_vars + code
        end
      end

      call << "function(#{params.join ', '}) {#{code}#{fix_line sexp.end_line}}"
      process call, level
    end

    def js_block_args(sexp)
      sexp.map do |arg|
        a = arg[1].intern
        a = "#{a}$".intern if RESERVED.include? a.to_s
        @scope.add_arg a
        a
      end
    end

    ##
    # recv.mid = rhs
    #
    # s(recv, :mid=, s(:arglist, rhs))

    def attrasgn(exp, level)
      recv = exp[0]
      mid = exp[1]
      arglist = exp[2]

      return process(s(:call, recv, mid, arglist), level)
    end

    # s(:call, recv, :mid, s(:arglist))
    # s(:call, nil, :mid, s(:arglist))
    def call(sexp, level)
      recv = sexp[0]
      meth = sexp[1]
      arglist = sexp[2]
      iter = sexp[3]

      mid = mid_to_jsid meth.to_s

      return js_operator_call(sexp, level) if CALL_OPERATORS.include? meth.to_s
      return js_compile_time_helpers(sexp, level) if recv && recv == [:const, :Opal]
      return js_block_given(sexp, level) if meth == :block_given?
      return "undefined" if meth == :undefined

      splat = arglist[1..-1].any? { |a| a.first == :splat }

      if Sexp === arglist.last and arglist.last.first == :block_pass
        tmpproc = @scope.new_temp
        arglist.insert 1, s(:js_tmp, process(arglist.pop, :expression))
      elsif iter
        tmpproc = @scope.new_temp
        arglist.insert 1, s(:js_tmp, "(#{tmpproc}=#{iter},#{tmpproc}.$S=this,#{tmpproc})")
      else
        arglist.insert 1, s(:js_tmp, 'null') unless arglist.length == 1
      end

      tmprecv = @scope.new_temp if splat or @debug
      args = ""

      recv_code = recv.nil? ? 'this' : process(recv, :receiver)

      args = process arglist, :expression

      @scope.queue_temp tmprecv if tmprecv
      @scope.queue_temp tmpproc if tmpproc

      if @debug
        pre = "((#{tmprecv}=#{recv_code}).#{mid} || $mm('#{mid}'))."
        splat ? "#{pre}apply(#{tmprecv}, #{args})" : "#{pre}call(#{tmprecv}#{args == '' ? '' : ", #{args}"})"
      else
        splat ? "(#{tmprecv}=#{recv_code}).#{mid}.apply(#{tmprecv}, #{args})" : "#{recv_code}.#{mid}(#{args})"
      end
    end

    # s(:arglist, [arg [, arg ..]])
    def arglist(sexp, level)
      code = ''
      work = []

      until sexp.empty?
        splat = sexp.first.first == :splat
        arg   = process sexp.shift, :expression

        if splat
          if work.empty?
            if code.empty?
              code += arg
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
        code += (code.empty? ? join : ".concat([#{work}])")
      end

      code
    end

    # s(:splat, sexp)
    def splat(sexp, level)
      return "[]" if sexp.first == [:nil]
      return "[#{process sexp.first, :expression}]" if sexp.first.first == :lit
      process sexp.first, :receiver
    end

    # s(:class, cid, super, body)
    def class(sexp, level)
      cid = sexp[0]
      sup = sexp[1]
      body = sexp[2]
      code = nil

      if Symbol === cid or String === cid
        object_class = (cid === :Object || cid === :BasicObject)
        base = 'this'
        name = cid.to_s.inspect
      elsif cid[0] == :colon2
        base = process(cid[1], :expression)
        name = cid[2].to_s.inspect
      elsif cid[0] == :colon3
        object_class = (cid[1] === :Object || cid[1] === :BasicObject)
        base = '$opal.Object'
        name = cid[1].to_s.inspect
      else
        raise "Bad receiver in class"
      end

      sup = sup ? process(sup, :expression) : 'nil'

      indent do
        in_scope(:class) do
          @scope.object_class = object_class
          code = @scope.to_vars + process(body, :statement)
        end
      end

      "$klass(#{base}, #{sup}, #{name}, function() {#{code}#{fix_line sexp.end_line}}, 0)"
    end

    # s(:sclass, recv, body)
    def sclass(sexp, level)
      recv = sexp[0]
      body = sexp[1]
      code = nil
      base = process recv, :expression

      in_scope(:sclass) do
        code = @scope.to_vars + process(body, :statement)
      end

      "$klass(#{base}, nil, nil, function() {#{code}}, 2)"
    end

    # s(:module, cid, body)
    def module(sexp, level)
      cid = sexp[0]
      body = sexp[1]
      code = nil

      if Symbol === cid or String === cid
        base = 'this'
        name = cid.to_s.inspect
      elsif cid[0] == :colon2
        base = process(cid[1], :expression)
        name = cid[2].to_s.inspect
      elsif cid[0] == :colon3
        base = '$opal.Object'
        name = cid[1].to_s.inspect
      else
        raise "Bad receiver in class"
      end

      indent do
        in_scope(:module) do
          code = @scope.to_vars + process(body, :statement) + @scope.to_donate_methods
        end
      end

      "$klass(#{base}, nil, #{name}, function() {#{code}#{fix_line sexp.end_line}}, 1)"
    end

    def undef(exp, level)
      "$opal.undef(this, #{process exp.shift, :expression})"
    end

    # s(:defn, mid, s(:args), s(:scope))
    def defn(sexp, level)
      mid = sexp[0]
      args = sexp[1]
      stmts = sexp[2]
      js_def nil, mid, args, stmts, sexp.line, sexp.end_line
    end

    # s(:defs, recv, mid, s(:args), s(:scope))
    def defs(sexp, level)
      recv = sexp[0]
      mid  = sexp[1]
      args = sexp[2]
      stmts = sexp[3]
      js_def recv, mid, args, stmts, sexp.line, sexp.end_line
    end

    def js_def(recvr, mid, args, stmts, line, end_line)
      mid = mid_to_jsid mid.to_s

      if recvr
        type = '$defs'
        recv = process(recvr, :expression)
      else
        type = '$defn'
        recv = 'this'
      end

      code = ''
      params = nil
      scope_name = @scope.name

      # opt args if last arg is sexp
      opt = args.pop if Sexp === args.last

      # block name &block
      if args.last.to_s[0] == '&'
        block_name = args.pop[1..-1].intern
      end

      # splat args *splat
      if args.last.to_s[0] == '*'
        if args.last == :*
          args.pop
        else
          splat = args[-1].to_s[1..-1].intern
          args[-1] = splat
          len = args.length - 2
        end
      end

      aritycode = arity_check(args, opt, splat) if @debug

      indent do
      in_scope(:def) do
        args.insert 1, '$yield'
        params = process args, :expression

        if block_name
          @scope.add_arg block_name
          @scope.uses_block!
        end

        opt[1..-1].each do |o|
          id = process s(:lvar, o[1]), :expression
          code += "if (#{id} === undefined) { #{process o, :expression}; }"
        end if opt

        code += "#{splat} = $slice.call(arguments, #{len + 1});" if splat
        code += process(stmts, :statement)

        if @scope.uses_block?
          blk = "$yield || ($yield = $no_proc);"
          blk = "var #{block_name} = $yield || ($yield = $no_proc, nil);" if block_name
          blk += "var $context = $yield.$S;"
          blk = "var $block_given = ($yield != null); #{blk}"
          code = blk + code
        end

        code = aritycode.to_s + code

        if @scope.catches_break?
          code = "try {#{code}} catch (e) { if (e === $breaker) { return e.$v; }; throw e;}"
        end

        code = @scope.to_vars + code
      end
      end

      defcode = "#{"#{scope_name} = " if scope_name}function(#{params}) {#{code}#{fix_line end_line}}"

      if recvr or @scope.object_class
        "#{type}(#{recv}, '#{mid}', #{defcode})"
      elsif @scope.type == :class
        "$proto.#{mid} = #{defcode}"
      elsif @scope.type == :module
        @scope.methods << mid
        "$proto.#{mid} = #{defcode}"
      else
        "#{type}(#{recv}, '#{mid}', #{defcode})"
      end
    end

    ##
    # Returns code used in debug mode to check arity of method call
    def arity_check(args, opt, splat)
      arity = args.size - 1
      arity -= (opt.size - 1) if opt
      arity -= 1 if splat
      arity = -arity - 1 if opt or splat

      aritycode = "var $arity = arguments.length; if ($arity !== 0) { $arity -= 1; }"
      if arity < 0 # splat or opt args
        aritycode + "if ($arity < #{-(arity + 1)}) { $arg_error($arity, #{arity}); }"
      else
        aritycode + "if ($arity !== #{arity}) { $arg_error($arity, #{arity}); }"
      end
    end

    def args(exp, level)
      args = []

      until exp.empty?
        a = exp.shift.intern
        a = "#{a}$".intern if RESERVED.include? a.to_s
        @scope.add_arg a
        args << a
      end

      args.join ', '
    end

    # s(:self)  # => this
    def self(sexp, level)
      'this'
    end

    # s(:true)  # => true
    # s(:false) # => false
    # s(:nil)   # => nil
    %w(true false nil).each do |name|
      define_method name do |exp, level|
        name
      end
    end

    # s(:array [, sexp [, sexp]])
    def array(sexp, level)
      return '[]' if sexp.empty?

      code = ''
      work = []

      until sexp.empty?
        splat = sexp.first.first == :splat
        part  = process sexp.shift, :expression

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
    def hash(sexp, level)
      "(new $hash(#{sexp.map { |p| process p, :expression }.join ', '}))"
    end

    # s(:while, exp, block, true)
    def while(sexp, level)
      expr = sexp[0]
      stmt = sexp[1]
      redo_var = @scope.new_temp
      stmt_level = if level == :expression or level == :receiver
                     :statement_closure
                    else
                      :statement
                    end
      pre = "while ("
      code = "#{js_truthy expr}){"

      in_while do
        @while_loop[:closure] = true if stmt_level == :statement_closure
        @while_loop[:redo_var] = redo_var
        body = process(stmt, :statement)

        if @while_loop[:use_redo]
          pre = "#{redo_var}=false;" + pre + "#{redo_var} || "
          code += "#{redo_var}=false;"
        end

        code += body
      end

      code += "}"
      code = pre + code
      @scope.queue_temp redo_var

      if stmt_level == :statement_closure
        code = "(function() {#{code}; return nil;}).call(this)"
      end

      code
    end

    def until(exp, level)
      expr = exp[0]
      stmt = exp[1]
      redo_var   = @scope.new_temp
      stmt_level = if level == :expression or level == :receiver
                     :statement_closure
                   else
                     :statement
                   end
      pre = "while (!("
      code = "#{js_truthy expr})) {"

      in_while do
        @while_loop[:closure] = true if stmt_level == :statement_closure
        @while_loop[:redo_var] = redo_var
        body = process(stmt, :statement)

        if @while_loop[:use_redo]
          pre = "#{redo_var}=false;" + pre + "#{redo_var} || "
          code += "#{redo_var}=false;"
        end

        code += body
      end

      code += "}"
      code = pre + code
      @scope.queue_temp redo_var

      if stmt_level == :statement_closure
        code = "(function() {#{code}; return nil;}).call(this)"
      end

      code
    end

    ##
    # alias foo bar
    #
    # s(:alias, s(:lit, :foo), s(:lit, :bar))
    def alias(exp, level)
      new = exp[0]
      old = exp[1]
      "$alias(this, #{process new, :expression}, #{process old, :expression})"
    end

    def svalue(sexp, level)
      process sexp.shift, level
    end

    # s(:lasgn, :lvar, rhs)
    def lasgn(sexp, level)
      lvar = sexp[0]
      rhs  = sexp[1]
      lvar = "#{lvar}$".intern if RESERVED.include? lvar.to_s
      @scope.add_local lvar
      "#{lvar} = #{process rhs, :expression}"
    end

    # s(:lvar, :lvar)
    def lvar(exp, level)
      lvar = exp.shift.to_s
      lvar = "#{lvar}$" if RESERVED.include? lvar
      lvar
    end

    # s(:iasgn, :ivar, rhs)
    def iasgn(exp, level)
      ivar = exp[0]
      rhs = exp[1]
      ivar = ivar.to_s[1..-1]
      lhs = RESERVED.include?(ivar) ? "this['#{ivar}']" : "this.#{ivar}"
      "#{lhs} = #{process rhs, :expression}"
    end

    # s(:ivar, :ivar)
    def ivar(exp, level)
      ivar = exp.shift.to_s[1..-1]
      part = RESERVED.include?(ivar) ? "['#{ivar}']" : ".#{ivar}"
      @scope.add_ivar part
      "this#{part}"
    end

    # s(:gvar, gvar)
    def gvar(sexp, level)
      gvar = sexp.shift.to_s
      tmp = @scope.new_temp
      code = "((#{tmp} = $gvars[#{gvar.inspect}]) == null ? nil : #{tmp})"
      @scope.queue_temp tmp
      code
    end

    # s(:gasgn, :gvar, rhs)
    def gasgn(sexp, level)
      gvar = sexp[0]
      rhs  = sexp[1]
      "($gvars[#{gvar.to_s.inspect}] = #{process rhs, :expression})"
    end

    # s(:const, :const)
    def const(sexp, level)
      if @debug
        "$opal.const_get($const, #{sexp.shift.to_s.inspect})"
      else
        "$const.#{sexp.shift}"
      end
    end

    # s(:cdecl, :const, rhs)
    def cdecl(sexp, level)
      const = sexp[0]
      rhs   = sexp[1]
      "$const.#{const} = #{process rhs, :expression}"
    end

    # s(:return [val])
    def return(sexp, level)
      val = process(sexp.shift || s(:nil), :expression)

      if level == :statement
        "return #{val}"
      else
        "$return(#{val})"
      end
    end

    # s(:xstr, content)
    def xstr(sexp, level)
      code = sexp.first.to_s
      code += ";" if level == :statement and !code.include?(';')
      code = "(#{code})" if level == :receiver

      code
    end

    # s(:dxstr, parts...)
    def dxstr(sexp, level)
      code = sexp.map do |p|
        if String === p
          p.to_s
        elsif p.first == :evstr
          process p.last, :expression
        elsif p.first == :str
          p.last.to_s
        else
          raise "Bad dxstr part"
        end
      end.join

      code += ";" if level == :statement and !code.include?(';')
      code = "(#{code})" if level == :receiver
      code
    end

    # s(:dstr, parts..)
    def dstr(sexp, level)
      parts = sexp.map do |p|
        if String === p
          p.inspect
        elsif p.first == :evstr
          process(s(:call, p.last, :to_s, s(:arglist)), :expression)
        elsif p.first == :str
          p.last.inspect
        else
          raise "Bad dstr part"
        end
      end

      "(#{parts.join ' + '})"
    end

    def dsym(sexp, level)
      parts = sexp.map do |p|
        if String === p
          p.inspect
        elsif p.first == :evstr
          process(s(:call, p.last, :to_s, s(:arglist)), :expression)
        elsif p.first == :str
          p.last.inspect
        else
          raise "Bad dsym part"
        end
      end

      "(#{parts.join '+'})"
    end

    # s(:if, test, truthy, falsy)
    def if(sexp, level)
      test = sexp[0]
      truthy = sexp[1]
      falsy = sexp[2]

      if level == :expression or level == :receiver
        truthy = returns(truthy || s(:nil))
        falsy = returns(falsy || s(:nil))
      end

      code = "if (#{js_truthy test}) {"
      indent { code += process(truthy, :statement) } if truthy
      indent { code += "} else {#{process falsy, :statement}" } if falsy
      code += "#{fix_line sexp.end_line}}"

      code = "(function() { #{code}; return nil; }).call(this)" if level == :expression or level == :receiver

      code
    end

    def js_truthy_optimize(sexp)
      if sexp.first == :call
        mid = sexp[2]
        if mid == :block_given?
          return process sexp, :expression
        elsif COMPARE.include? mid.to_s
          return process sexp, :expression
        end
      end
    end

    def js_truthy(sexp)
      if optimized = js_truthy_optimize(sexp)
        return optimized
      end

      tmp = @scope.new_temp
      code = "(#{tmp} = #{process sexp, :expression}) !== false && #{tmp} !== nil"
      @scope.queue_temp tmp

      code
    end

    # s(:and, lhs, rhs)
    def and(sexp, level)
      lhs = sexp[0]
      rhs = sexp[1]
      t = nil
      tmp = @scope.new_temp

      if t = js_truthy_optimize(lhs)
        return "(#{tmp} = #{t} ? #{process rhs, :expression} : #{tmp})".tap {
          @scope.queue_temp tmp
        }
      end

      code = "(#{tmp} = #{process lhs, :expression}, #{tmp} !== false && "
      code += "#{tmp} != nil ? #{process rhs, :expression} : #{tmp})"
      @scope.queue_temp tmp

      code
    end

    # s(:or, lhs, rhs)
    def or(sexp, level)
      lhs = sexp[0]
      rhs = sexp[1]
      t = nil
      tmp = @scope.new_temp

      if t = js_truthy_optimize(lhs)
        return "(#{tmp} = #{t} ? #{tmp} : #{process rhs, :expression})".tap {
          @scope.queue_temp tmp
        }
      end

      code = "(#{tmp} = #{process lhs, :expression}, #{tmp} !== false && "
      code += "#{tmp} != nil ? #{tmp} : #{process rhs, :expression})"
      @scope.queue_temp tmp

      code
    end

    # s(:yield, arg1, arg2)
    def yield(sexp, level)
      @scope.uses_block!
      splat = sexp.any? { |s| s.first == :splat }
      sexp.unshift s(:js_tmp, 'null')
      sexp.unshift s(:js_tmp, '$context') unless splat
      args = arglist(sexp, level)

      call =  if splat
                "$yield.apply($context, #{args})"
              else
                "$yield.call(#{args})"
              end

      if level == :receiver or level == :expression
        tmp = @scope.new_temp
        @scope.catches_break!
        code = "((#{tmp} = #{call}) === $breaker ? #{tmp}.$t() : #{tmp})"
        @scope.queue_temp tmp
      else
        code = call
      end

      code
    end

    def break(exp, level)
      val = exp.empty? ? 'nil' : process(exp.shift, :expression)
      if in_while?
        if @while_loop[:closure]
          "return #{val};"
        else
          "break;"
        end
      else
        "return ($breaker.$v = #{val}, $breaker)"
      end
    end

    # s(:case, expr, when1, when2, ..)
    def case(exp, level)
      code = []
      @scope.add_local "$case"
      expr = process exp.shift, :expression
      # are we inside a statement_closure
      returnable = level != :statement
      done_else = false

      until exp.empty?
        wen = exp.shift
        if wen and wen.first == :when
          returns(wen) if returnable
          wen = process(wen, :statement)
          wen = "else #{wen}" unless code.empty?
          code << wen
        elsif wen # s(:else)
          done_else = true
          wen = returns(wen) if returnable
          code << "else {#{process wen, :statement}}"
        end
      end

      code << "else {return nil}" if returnable and !done_else

      code = "$case = #{expr};#{code.join "\n"}"
      code = "(function() { #{code} }).call(this)" if returnable
      code
    end

    # when foo
    #   bar
    #
    # s(:when, s(:array, foo), bar)
    def when(exp, level)
      arg = exp.shift[1..-1]
      body = exp.shift
      body = process body, level if body

      test = []
      until arg.empty?
        a = arg.shift

        if a.first == :when # when inside another when means a splat of values
          call  = s(:call, s(:js_tmp, "$splt[i]"), :===, s(:arglist, s(:js_tmp, "$case")))
          splt  = "(function($splt) {for(var i = 0; i < $splt.length; i++) {"
          splt += "if (#{process call, :expression}) { return true; }"
          splt += "} return false; }).call(this, #{process a[1], :expression})"

          test << splt
        else
          call = s(:call, a, :===, s(:arglist, s(:js_tmp, "$case")))
          call = process call, :expression
          # call = "else " unless test.empty?

          test << call
        end
      end

      "if (#{test.join " || "}) {\n#{body}\n}"
    end

    # lhs =~ rhs
    #
    # s(:match3, lhs, rhs)
    def match3(sexp, level)
      lhs = sexp[0]
      rhs = sexp[1]
      call = s(:call, lhs, :=~, s(:arglist, rhs))
      process call, level
    end

    # @@class_variable
    #
    # s(:cvar, name)
    def cvar(exp, level)
      tmp = @scope.new_temp
      code = "((#{tmp} = $opal.cvars[#{exp.shift.to_s.inspect}]) == null ? nil : #{tmp})"
      @scope.queue_temp tmp
      code
    end

    # @@name = rhs
    #
    # s(:cvasgn, :@@name, rhs)
    def cvasgn(exp, level)
      "($opal.cvars[#{exp.shift.to_s.inspect}] = #{process exp.shift, :expression})"
    end

    def cvdecl(exp, level)
      "($opal.cvars[#{exp.shift.to_s.inspect}] = #{process exp.shift, :expression})"
    end

    # BASE::NAME
    #
    # s(:colon2, base, :NAME)
    def colon2(sexp, level)
      base = sexp[0]
      name = sexp[1]
      "$opal.const_get((#{process base, :expression}).$const, #{name.to_s.inspect})"
    end

    def colon3(exp, level)
      "$opal.const_get($opal.Object, #{exp.shift.to_s.inspect})"
    end

    # super a, b, c
    #
    # s(:super, arg1, arg2, ...)
    def super(sexp, level)
      args = []
      until sexp.empty?
        args << process(sexp.shift, :expression)
      end
      "$zuper(arguments.callee, this, [#{args.join ', '}])"
    end

    # super
    #
    # s(:zsuper)
    def zsuper(exp, level)
      "$zuper(arguments.callee, this, [])"
    end

    # a ||= rhs
    #
    # s(:op_asgn_or, s(:lvar, :a), s(:lasgn, :a, rhs))
    def op_asgn_or(exp, level)
      process s(:or, exp.shift, exp.shift), :expression
    end

    def op_asgn1(sexp, level)
      "'FIXME(op_asgn1)'"
    end

    # lhs.b += rhs
    #
    # s(:op_asgn2, lhs, :b=, :+, rhs)
    def op_asgn2(exp, level)
      lhs = process exp.shift, :expression
      mid = exp.shift.to_s[0..-2]
      op  = exp.shift
      rhs = exp.shift

      if op.to_s == "||"
        raise "op_asgn2 for ||"
      else
        temp = @scope.new_temp
        getr = s(:call, s(:js_tmp, temp), mid, s(:arglist))
        oper = s(:call, getr, op, s(:arglist, rhs))
        asgn = s(:call, s(:js_tmp, temp), "#{mid}=", s(:arglist, oper))

        "(#{temp} = #{lhs}, #{process asgn, :expression})".tap {
          @scope.queue_temp temp
        }
      end
    end

    # s(:ensure, body, ensure)
    def ensure(exp, level)
      begn = exp.shift
      if level == :receiver || level == :expression
        retn = true
        begn = returns begn
      end

      body = process begn, level
      ensr = exp.shift || s(:nil)
      ensr = process ensr, level
      body = "try {\n#{body}}" unless body =~ /^try \{/

      res = "#{body}\n finally {\n#{ensr}}"
      res = "(function() { #{res}; }).call(this)" if retn
      res
    end

    def rescue(exp, level)
      body = exp.first.first == :resbody ? s(:nil) : exp.shift
      body = process body, level

      parts = []
      until exp.empty?
        part = process exp.shift, level
        part = "else " + part unless parts.empty?
        parts << part
      end
      # if no rescue statement captures our error, we should rethrow
      parts << "else { throw $err; }"

      code = "try {\n#{body}\n} catch ($err) {\n#{parts.join "\n"}\n}"
      code = "(function() { #{code} }).call(this)" if level == :expression

      code
    end

    def resbody(exp, level)
      args = exp[0]
      body = exp[1]
      body = process(body || s(:nil), level)
      types = args[1..-2]

      err = types.map { |t|
        call = s(:call, t, :===, s(:arglist, s(:js_tmp, "$err")))
        a = process call, :expression
        #puts a
        a
      }.join ', '
      err = "true" if err.empty?

      if Sexp === args.last and [:lasgn, :iasgn].include? args.last.first
        val = args.last
        val[2] = s(:js_tmp, "$err")
        val = process(val, :expression) + ";"
      end

      "if (#{err}) {\n#{val}#{body}}"
      # raise exp.inspect
    end

    # FIXME: Hack.. grammar should remove top level begin.
    def begin(exp, level)
      process exp[0], level
    end

    def next(exp, level)
      val = exp.empty? ? 'nil' : process(exp.shift, :expression)
      if in_while?
        "continue;"
      else
        "return #{val};"
      end
    end

    def redo(exp, level)
      if in_while?
        @while_loop[:use_redo] = true
        "#{@while_loop[:redo_var]} = true"
      else
        "REDO()"
      end
    end
  end
end