module Opal
  class Parser

    INDENT = ' '

    LEVEL = {
      :statement          => 0,
      :statement_closure  => 1,
      :list               => 2,
      :expression         => 3,
      :receiver           => 4
    }

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
      void while with class enum export extends import super true false
    )

    STATEMENTS = [:xstr, :dxstr]

    RUNTIME_HELPERS = {
      "$nilcls" => "NC",    # nil method table (cant store it on null)
      "$super"  => "S",     # function to call super
      "$bjump"  => "B",     # break value literal
      "$noproc" => "P",     # proc to yield when no block (throws error)
      "$symbol" => "Y",     # create a symbol with id
      "$class"  => "dc",    # define a regular class
      "$defn"   => "dm",    # normal define method
      "$defs"   => "ds",    # singleton define method
      "$const"  => "cg",    # const_get
      "$range"  => "G",     # new range instance
      "$hash"   => "H",     # new hash instance
      "$module" => "md",    # creates module
      "$sclass" => "sc",    # class shift (<<)
      "$mm"     => "mm",    # method_missing dispatcher
      "$ms"     => "ms",    # method_missing dispatcher for setters (x.y=)
      "$mn"     => "mn",    # method_missing dispatcher for no arguments
      "$slice"  => "as"     # exposes Array.prototype.slice (for splats)
    }

    ##
    # All method ids. method_id => id

    attr_reader :id_tbl

    ##
    # All ivars. ivar_name => id

    attr_reader :ivar_tbl

    def reset(file = nil)
      @file = file

      @indent   = ''
      @unique   = 0
      @symbols  = {}
      @sym_id   = 0

      @id_tbl   = {}
      @ivar_tbl = {}
      @next_id  = "$a"
    end

    ##
    # Returns id for method name/call

    def name_to_id name
      name = name.to_s

      if id = @id_tbl[name]
        return id
      end

      id = @next_id
      @next_id = @next_id.succ

      @id_tbl[name] = id
    end

    ##
    # Returns id for ivar

    def ivar_to_id name
      name = name.to_s

      if id = @ivar_tbl[name]
        return id
      end

      id = @next_id
      @next_id = @next_id.succ

      @ivar_tbl[name] = id
    end

    # guaranteed unique id per file..
    def unique_temp
      "$TMP_#{@unique += 1}"
    end

    def top(sexp, options = {})
      code, vars = nil, []

      in_scope(:top) do
        code = process s(:scope, sexp), :statement

        vars.concat @scope.locals.map { |t| "#{t}" }
        vars.concat @scope.temps.map { |t| t }

        code = "var #{vars.join ', '};" + code unless vars.empty?
      end

      pre = "function(VM, self, FILE) {\nfunction $$() {\n"

      post = "\n}\n"
      post += "var "
      post += RUNTIME_HELPERS.to_a.map { |a| a.join ' = VM.' }.join ', '
      post += ", nil = null" # incase people put nil inside js code

      @symbols.each { |s, v| post += ", #{v} = $symbol('#{s}')" }
      @unique.times { |i| post += ", $TMP_#{i+1}" }
      post += ";\n"
      post += "\nreturn $$();\n}"

      pre + code + post
    end

    def in_scope(type)
      return unless block_given?

      parent = @scope
      @scope = Scope.new(type).tap { |s| s.parent = parent }
      yield @scope

      @scope = parent
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
      @scope.push_while
      result = yield
      @scope.pop_while

      result
    end

    def process(sexp, level)
      type = sexp.shift

      raise "Unsupported sexp: #{type}" unless respond_to? type

      __send__ type, sexp, level
    end

    def mid_to_jsid (id)
      id = id.to_s
      return ".$m['#{id}']" if /[!=?+\-*\/^&%@|\[\]<>~]/ =~ id

      return ".$m['#{id}']" if RESERVED.include? id
      # default we just do .method_name
      '.$m.' + id
    end

    def returns(sexp)
      return returns s(:nil) unless sexp

      case sexp.first
      when :break
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
        sexp[2] = returns sexp[2] if sexp[2]
        sexp[3] = returns sexp[3] if sexp[3]
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
        expr = expression?(stmt) and LEVEL[level] < LEVEL[:list]
        result << process(stmt, level)
        result << ";" if expr
        result << "\n"
      end

      result.join
    end

    def scope(sexp, level)
      stmt = returns sexp.shift
      code = process stmt, :statement

      code
    end

    # s(:js_return, sexp)
    def js_return(sexp, level)
      "return #{process sexp.shift, :expression}"
    end

    # s(:js_tmp, str)
    def js_tmp(sexp, level)
      sexp.shift
    end

    # s(:js_block_given)
    def js_block_given(sexp, level)
      @scope.uses_block!
      "$yield !== $noproc"
    end

    def js_operator_call(sexp, level)
      recv, meth, arglist = sexp

      a = @scope.new_temp
      b = @scope.new_temp
      l  = process recv, :expression
      r  = process arglist[1], :expression

      res = "(#{a} = #{l}, #{b} = #{r}, typeof(#{a}) === "
      res += "'number' ? #{a} #{meth} #{b} : #{a}.$m['#{meth}']"
      res += "(#{a}, '#{meth}', #{b}))"

      @scope.queue_temp a
      @scope.queue_temp b

      res
    end

    # s(:lit, 1)
    # s(:lit, :foo)
    def lit(sexp, level)
      val = sexp.shift
      case val
      when Numeric
        val.inspect
      when Symbol
        @symbols[val.to_s] ||= "$symbol_#{@sym_id += 1}"
      when Regexp
        val == // ? /^/.inspect : val.inspect
      when Range
        "$range(#{val.begin}, #{val.end}, #{val.exclude_end?})"
      else
        raise "Bad lit: #{val.inspect}"
      end
    end

    # s(:str, "string")
    def str(sexp, level)
      str = sexp.shift
      str == @file ? "FILE" : str.inspect
    end

    # s(:not, sexp)
    def not(sexp, level)
      "!#{process sexp.shift, :expression}"
    end

    def block_pass(exp, level)
      process exp.shift, level
    end

    # s(:iter, call, block_args [, body)
    def iter(sexp, level)
      call, args, body = sexp
      body ||= s(:nil)
      body = returns body
      code, vars, params = "", [], nil

      args ||= s(:masgn, s(:array))
      args = args.first == :lasgn ? s(:array, args) : args[1]
      args.insert 1, 'self', '$mid'

      if args.last[0] == :splat
        splat = args[-1][1][1]
        args[-1] = s(:lasgn, splat)
        len = args.length - 2
      end


      in_scope(:iter) do
        params = js_block_args(args[1..-1])
        code += "#{splat} = $slice.call(arguments, #{len});" if splat
        code += process body, :statement

        @scope.locals.each { |t| vars << "#{t}" }
        @scope.temps.each { |t| vars << t }

        code = "var #{vars.join ', '};" + code unless vars.empty?
      end

      call << "function(#{params}) {\n#{code}}"
      process call, level
    end

    # block args
    # s('self', '$mid', arg1, arg2..)
    def js_block_args(sexp)
      sexp.map do |arg|
        if String === arg
          # self, $mid values
          arg
        else
          # should all be :lasgn from #iter
          if arg.first == :lasgn
            a = arg[1]
            @scope.add_arg a
            a
          else
            raise "Bad js_block_arg type: #{arg.first}"
          end
        end
      end.join ', '
    end

    ##
    # recv.mid = rhs
    #
    # s(recv, :mid=, s(:arglist, rhs))

    def attrasgn(exp, level)
      recv, mid, arglist = exp

      return process(s(:call, recv, mid, arglist), level) if mid == :[]=

      tmprecv = @scope.new_temp
      setr = mid.to_s[0..-2]

      recv_code, recv_arg = if recv.nil?
                              ['self', 'self']
                            else
                              ["(#{tmprecv} = #{process recv, :expression})",
                                tmprecv]
                            end

      arg = process arglist.last, :expression
      dispatch = "(#{recv_code}, (#{recv_code} == nil ? $nilcls : #{recv_arg})"
      dispatch += ".$m['#{mid.to_s}'])"

      @scope.queue_temp tmprecv

      "#{dispatch}(#{recv_arg}, #{setr.to_s.inspect}, #{arg})"
    end


    # s(:call, recv, :mid, s(:arglist))
    # s(:call, nil, :mid, s(:arglist))
    def call(sexp, level)
      recv, meth, arglist, iter = sexp
      mid = name_to_id meth

      return js_operator_call(sexp, level) if CALL_OPERATORS.include? meth.to_s
      return js_block_given(sexp, level) if meth == :block_given?
      return "undefined" if meth == :undefined

      if Sexp === arglist.last and arglist.last.first == :block_pass
        block_pass = process arglist.pop, :expression
      end

      args = ""
      splat = arglist[1..-1].any? { |a| a.first == :splat }
      tmprecv = @scope.new_temp
      tmpproc = @scope.new_temp if iter or block_pass

      if recv.nil?
        recv_code = "self"
      else
        recv_code = process recv, :expression
      end

      recv_arg = "tmp"

      arglist.insert 1, s(:js_tmp, recv_arg), s(:js_tmp, mid.inspect)

      args = process arglist, :expression

      dispatch = "#{recv_code}.#{mid}"

      if iter
        dispatch = "(#{tmpproc} = #{dispatch}, (#{tmpproc}.$B = #{iter}).$S "
        dispatch += "= self, #{tmpproc})"
      elsif block_pass
        dispatch = "(#{tmpproc} = #{dispatch}, #{tmpproc}.$B = #{block_pass}, #{tmpproc})"
      end

      @scope.queue_temp tmprecv
      @scope.queue_temp tmpproc if tmpproc

      if splat
        "#{dispatch}.apply(null, #{args})"
      else
        "#{dispatch}(#{args})"
      end
    end

    # s(:arglist, [arg [, arg ..]])
    def arglist (sexp, level)
      code, work = '', []

      until sexp.empty?
        splat = sexp.first.first == :splat
        arg   = process sexp.shift, :expression

        if splat
          if work.empty?
            if code.empty?
              code += (arg[0] == "[" ? arg : "#{arg}#{mid_to_jsid :to_a}()")
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
      process sexp.first, :receiver
    end

    # s(:class, cid, super, body)
    def class(sexp, level)
      cid, sup, body = sexp
      code, vars = nil, []

      base, name = if Symbol === cid or String === cid
                     ['self', cid.to_s.inspect]
                    elsif cid[0] == :colon2
                      [process(cid[1], :expression), cid[2].to_s.inspect]
                    elsif cid[0] == :colon3
                      ['VM.Object', cid[1].to_s.inspect]
                    else
                      raise "Bad receiver in class"
                   end

      sup = sup ? process(sup, :expression) : 'null'

      in_scope(:class) do
        code = process body, :statement

        @scope.locals.each { |t| vars << "#{t} = nil" }
        @scope.temps.each { |t| vars << t }

        code = "var #{vars.join ', '};" + code unless vars.empty?
      end

      "$class(#{base}, #{sup}, #{name}, function(self) {\n#{code}})"
    end

    # s(:sclass, recv, body)
    def sclass(sexp, level)
      recv, body = sexp
      code, vars = nil, []
      base = process recv, :expression

      in_scope(:class) do
        code = process body, :statement

        @scope.locals.each { |t| vars << t }
        @scope.temps.each { |t| vars << t }

        code = "var #{vars.join ', '};" + code unless vars.empty?
      end

      "$sclass(#{base}, function(self) {\n#{code}})"
    end

    # s(:module, cid, body)
    def module(sexp, level)
      cid, body = sexp
      code, vars = nil, []

      base, name = if Symbol === cid or String === cid
                     ['self', cid.to_s.inspect]
                    elsif cid[0] == :colon2
                      [process(cid[1], :expression), cid[2].to_s.inspect]
                    elsif cid[0] == :colon3
                      ['VM.Object', cid[1].to_s.inspect]
                    else
                      raise "Bad receiver in class"
                   end

      in_scope(:class) do
        code = process body, :statement

        @scope.locals.each { |t| vars << t }
        @scope.temps.each { |t| vars << t }

        code = "var #{vars.join ', '};" + code unless vars.empty?
      end

      "$module(#{base}, #{name}, function(self) {\n#{code}})"
    end

    # s(:defn, mid, s(:args), s(:scope))
    def defn(sexp, level)
      mid, args, stmts = sexp
      js_def nil, mid, args, stmts
    end

    # s(:defs, recv, mid, s(:args), s(:scope))
    def defs(sexp, level)
      recv, mid, args, stmts = sexp
      js_def recv, mid, args, stmts
    end

    def js_def(recvr, mid, args, stmts)
      mid = name_to_id mid

      type, recv = if recvr
                     ["$defs", process(recvr, :expression)]
                   else
                     ["$defn", "self"]
                   end

      code, vars, params = "", [], nil
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

      args.insert 1, 'self', '$mid'

      in_scope(:def) do
        params = process args, :expression

        if block_name
          @scope.add_arg block_name
          @scope.uses_block!
        end

        opt[1..-1].each do |o|
          id = process s(:lvar, o[1]), :expression
          code += "if (#{id} === undefined) { #{process o, :expression}; }"
        end if opt

        code += "#{splat} = $slice.call(arguments, #{len + 2});" if splat
        code += process(stmts, :statement)

        @scope.locals.each { |t| vars << t }
        @scope.temps.each { |t| vars << t }

        code = "var #{vars.join ', '};" + code unless vars.empty?

        if @scope.uses_block?
          scope_name = (@scope.name ||= unique_temp)
          blk = "var $yield = #{scope_name}.$B || $noproc, $yself = $yield.$S, "
          blk += "#{block_name} = #{scope_name}.$B, " if block_name
          blk += "$break = $bjump; #{scope_name}.$B = 0;"

          code = blk + code
        end
      end

      ref = scope_name ? "#{scope_name} = " : ""
      "#{type}(#{recv}, '#{mid}', #{ref}function(#{params}) {\n#{code}})"
    end

    def args (exp, level)
      args = []
      until exp.empty?
        a = exp.shift.intern
        a = "#{a}$".intern if RESERVED.include? a.to_s
        @scope.add_arg a
        args << a
      end
      args.join ', '
    end

    # s(:self)  # => self
    # s(:true)  # => self
    # s(:false) # => self
    %w(self true false).each do |name|
      define_method name do |sexp, level|
        name
      end
    end

    # s(:nil)
    def nil(exp, level)
      "null"
    end

    # s(:array [, sexp [, sexp]])
    def array (sexp, level)
      return '[]' if sexp.empty?

      code, work = "", []

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
      "$hash(#{sexp.map { |p| process p, :expression }.join ', '})"
    end

    # s(:while, exp, block, true)
    def while(sexp, level)
      expr, stmt = sexp
      stmt_level = (level == :expression ? :statement_closure : :statement)

      code = "while (#{process expr, :expression}){"

      in_while { code += process(stmt, :statement) }
      code += "}"

      if stmt_level == :statement_closure
        code = "(function() {\n#{code}})()"
      end

      code
    end

    # s(:lasgn, :lvar, rhs)
    def lasgn(sexp, level)
      lvar, rhs = sexp
      lvar = "#{lvar}$".intern if RESERVED.include? lvar.to_s
      @scope.add_local lvar
      "#{lvar} = #{process rhs, :expression}"
    end

    # s(:lvar, :lvar)
    def lvar exp, level
      lvar = exp.shift.to_s
      lvar = "#{lvar}$" if RESERVED.include? lvar
      lvar
    end

    # s(:iasgn, :ivar, rhs)
    def iasgn(sexp, level)
      ivar, rhs = sexp
      name = ivar_to_id ivar
      "self.#{name} = #{process rhs, :expression}"
    end

    # s(:ivar, :ivar)
    def ivar(sexp, level)
      ivar = sexp.shift
      name = ivar_to_id ivar

      "self.#{name}"
    end

    # s(:gvar, gvar)
    def gvar(sexp, level)
      gvar = sexp.shift.to_s
      jsid = gvar[1..-1]

      if /[!=?+\-*\/^&%@|\[\]<>~]/ =~ gvar
        res = "VM.gg(#{gvar.inspect})"
      else
        tmp = @scope.new_temp
        res = "((#{tmp} = VM.gv[#{gvar.inspect}]) == null && typeof(#{jsid})"
        res += " !== 'undefined' ? #{jsid} : VM.gg(#{gvar.inspect}))"
        @scope.queue_temp tmp
      end

      res
    end

    # s(:gasgn, :gvar, rhs)
    def gasgn(sexp, level)
      gvar, rhs = sexp

      "VM.gs(#{gvar.to_s.inspect}, #{process rhs, :expression})"
    end

    # s(:const, :const)
    def const(sexp, level)
      "$const(self, #{sexp.shift.to_s.inspect})"
    end

    # s(:cdecl, :const, rhs)
    def cdecl(sexp, level)
      const, rhs = sexp
      "VM.cs(self, #{const.to_s.inspect}, #{process rhs, :expression})"
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

    # s(:if, test, truthy, falsy)
    def if(sexp, level)
      test, truthy, falsy = sexp

      if level == :expression
        truthy = returns(truthy) if truthy
        falsy = returns(falsy) if falsy
      end

      code = "if (#{js_truthy test}) {"
      code += process(truthy, :statement) if truthy
      code += "} else {#{process falsy, :statement}" if falsy
      code += "}"

      code
      code = "(function() { #{code} })()" if level == :expression

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
      code = "#{tmp} = #{process sexp, :expression}, #{tmp} !== false"
      code += " && #{tmp} != null"
      @scope.queue_temp tmp

      code
    end

    # s(:and, lhs, rhs)
    def and(sexp, level)
      lhs, rhs = sexp
      t, tmp = nil, @scope.new_temp

      if t = js_truthy_optimize(lhs)
        return "(#{tmp} = #{t} ? #{process rhs, :expression} : #{tmp})".tap {
          @scope.queue_temp tmp
        }
      end

      code = "(#{tmp} = #{process lhs, :expression}, #{tmp} !== false && "
      code += "#{tmp} != null ? #{process rhs, :expression} : #{tmp})"
      @scope.queue_temp tmp

      code
    end

    # s(:or, lhs, rhs)
    def or(sexp, level)
      lhs, rhs = sexp
      t, tmp = nil, @scope.new_temp

      if t = js_truthy_optimize(lhs)
        return "(#{tmp} = #{t} ? #{tmp} : #{process rhs, :expression})".tap {
          @scope.queue_temp tmp
        }
      end

      code = "(#{tmp} = #{process lhs, :expression}, #{tmp} !== false && "
      code += "#{tmp} != null ? #{tmp} : #{process rhs, :expression})"
      @scope.queue_temp tmp

      code
    end

    # s(:yield, arg1, arg2)
    def yield(sexp, level)
      @scope.uses_block!
      splat = sexp.any? { |s| s.first == :splat }
      sexp.unshift s(:js_tmp, '$yself'), s(:js_tmp, 'null')
      args = arglist(sexp, level)

      if splat
        "$yield.apply(null, #{args})"
      else
        "$yield(#{args})"
      end
    end


    def break(sexp, level)
      "return $bjump"
      # "BREAK"
    end

    # s(:case, expr, when1, when2, ..)
    def case(exp, level)
      code = []
      @scope.add_local "$case"
      expr = process exp.shift, :expression
      # are we inside a statement_closure
      returnable = level != :statement

      until exp.empty?
        wen = exp.shift
        if wen and wen.first == :when
          returns(wen) if returnable
          wen = process(wen, :expression)
          wen = "else #{wen}" unless code.empty?
          code << wen
        elsif wen # s(:else)
          wen = returns(wen) if returnable
          code << "else {#{process wen, :expression}}"
        end
      end

      code = "$case = #{expr};#{code.join "\n"}"
      code = "(function() { #{code} })()" if returnable
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
          call = s(:call, s(:js_tmp, "$splt[i]"), :===, s(:arglist, s(:js_tmp, "$case")))
          splt = "(function($splt) {for(var i = 0; i < $splt.length; i++) {"
          splt += "if (#{process call, :expression}) { return true; }"
          splt += "} return false; })(#{process a[1], :expression})"
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
      lhs, rhs = sexp
      call = s(:call, lhs, :=~, s(:arglist, rhs))
      process call, level
    end

    # @@class_variable
    #
    # s(:cvar, name)
    def cvar(sexp, level)
      "VM.cvg(#{sexp.shift.to_s.inspect})"
    end

    # @@name = rhs
    #
    # s(:cvasgn, :@@name, rhs)
    def cvasgn(sexp, level)
      "VM.cvs(#{sexp.shift.to_s.inspect}, #{process sexp.shift, :expression})"
    end

    def cvdecl(exp, level)
      "VM.cvs(#{exp.shift.to_s.inspect}, #{process exp.shift, :expression})"
    end

    # BASE::NAME
    #
    # s(:colon2, base, :NAME)
    def colon2(sexp, level)
      base, name = sexp
      "$const(#{process base, :expression}, #{name.to_s.inspect})"
    end

    def colon3(exp, level)
      "$const(VM.Object, #{exp.shift.to_s.inspect})"
    end

    # super a, b, c
    #
    # s(:super, arg1, arg2, ...)
    def super(sexp, level)
      args = []
      until sexp.empty?
        args << process(sexp.shift, :expression)
      end
      "$super(arguments.callee, self, [#{args.join ', '}])"
    end

    # super
    #
    # s(:zsuper)
    def zsuper(exp, level)
      "$super(arguments.callee, self, [])"
    end

    # a ||= rhs
    #
    # s(:op_asgn_or, s(:lvar, :a), s(:lasgn, :a, rhs))
    def op_asgn_or(exp, level)
      process s(:or, exp.shift, exp.shift), :expression
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
      body = process exp.shift, level
      ensr = exp.shift || s(:nil)
      ensr = process ensr, level
      body = "try {\n#{body}}" unless body =~ /^try \{/

      "#{body}\n finally {\n#{ensr}}"
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
      code = "(function() { #{code} })()" if level == :expression

      code
    end

    def resbody(exp, level)
      args, body = exp
      body = process(body || s(:nil), level)
      types = args[1..-2]

      err = types.map { |t|
        call = s(:call, t, :===, s(:arglist, s(:js_tmp, "$err")))
        a = process call, :expression
        puts a
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

    def next(exp, level)
      "return ;"
    end
  end
end
