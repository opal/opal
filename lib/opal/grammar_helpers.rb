module Opal
  class Grammar < Racc::Parser

    def new_block(stmt = nil)
      s = s(:block)
      s << stmt if stmt
      s
    end

    def new_compstmt(block)
      if block.size == 1
        nil
      elsif block.size == 2
        block[1]
      else
        block.line = block[1].line
        block
      end
    end

    def new_body(compstmt, res, els, ens)
      s = compstmt || s(:block)
      s.line = compstmt.line if compstmt

      if res
        s = s(:rescue, s)
        res.each { |r| s << r }
        s << els if els
      end

      ens ? s(:ensure, s, ens) : s
    end

    def new_defn(line, name, args, body)
      body = s(:block, body) if body[0] != :block
      scope = s(:scope, body)
      body << s(:nil) if body.size == 1
      scope.line = body.line
      args.line = line
      s = s(:defn, name.to_sym, args, scope)
      s.line = line
      s.end_line = @line
      s
    end

    def new_defs(line, recv, name, args, body)
      scope = s(:scope, body)
      scope.line = body.line
      s = s(:defs, recv, name.to_sym, args, scope)
      s.line = line
      s.end_line = @line
      s
    end

    def new_class(path, sup, body)
      scope = s(:scope)
      scope << body unless body.size == 1
      scope.line = body.line
      s = s(:class, path, sup, scope)
      s
    end

    def new_sclass(expr, body)
      scope = s(:scope)
      scope << body #unless body.size == 1
      scope.line = body.line
      s = s(:sclass, expr, scope)
      s
    end

    def new_module(path, body)
      scope = s(:scope)
      scope << body unless body.size == 1
      scope.line = body.line
      s = s(:module, path, scope)
      s
    end

    def new_iter(args, body)
      s = s(:iter, args)
      s << body if body
      s.end_line = @line
      s
    end

    def new_if(expr, stmt, tail)
      s = s(:if, expr, stmt, tail)
      s.line = expr.line
      s.end_line = @line
      s
    end

    def new_args(norm, opt, rest, block)
      res = s(:args)

      if norm
        norm.each do |arg|
          @scope.add_local arg
          res << arg
        end
      end

      if opt
        opt[1..-1].each do |_opt|
          res << _opt[1]
        end
      end

      if rest
        res << rest
        rest_str = rest.to_s[1..-1]
        @scope.add_local rest_str.to_sym unless rest_str.empty?
      end

      if block
        res << block
        @scope.add_local block.to_s[1..-1].to_sym
      end

      res << opt if opt

      res
    end

    def new_block_args(norm, opt, rest, block)
      res = s(:array)

      if norm
        norm.each do |arg|
          if arg.is_a? Symbol
            @scope.add_local arg
            res << s(:lasgn, arg)
          else
            res << arg
          end
        end
      end

      if opt
        opt[1..-1].each do |_opt|
          res << s(:lasgn, _opt[1])
        end
      end

      if rest
        r = rest.to_s[1..-1].to_sym
        res << s(:splat, s(:lasgn, r))
        @scope.add_local r
      end

      if block
        b = block.to_s[1..-1].to_sym
        res << s(:block_pass, s(:lasgn, b))
        @scope.add_local b
      end

      res << opt if opt

      args = res.size == 2 && norm ? res[1] : s(:masgn, res)

      if args[0] == :array
        s(:masgn, args)
      else
        args
      end
    end

    def new_call(recv, meth, args = nil)
      call = s(:call, recv, meth)
      args = s(:arglist) unless args
      args[0] = :arglist if args[0] == :array
      call << args

      if recv
        call.line = recv.line
      elsif args[1]
        call.line = args[1].line
      end

      # fix arglist spilling over into next line if no args
      if args.length == 1
        args.line = call.line
      else
        args.line = args[1].line
      end

      call
    end

    def add_block_pass(arglist, block)
      arglist << block if block
      arglist
    end

    def new_op_asgn(op, lhs, rhs)
      case op
      when :"||"
        result = s(:op_asgn_or, new_gettable(lhs))
        result << (lhs << rhs)
      when :"&&"
        result = s(:op_asgn_and, new_gettable(lhs))
        result << (lhs << rhs)
      else
        result = lhs
        result << new_call(new_gettable(lhs), op, s(:arglist, rhs))

      end

      result.line = lhs.line
      result
    end

    def new_assign(lhs, rhs)
      case lhs[0]
      when :iasgn, :cdecl, :lasgn, :gasgn, :cvdecl, :nth_ref
        lhs << rhs
        lhs
      when :call, :attrasgn
        lhs.last << rhs
        lhs
      when :colon2
        lhs << rhs
        lhs[0] = :casgn
        lhs
      when :colon3
        lhs << rhs
        lhs[0] = :casgn3
        lhs
      else
        raise "Bad lhs for new_assign: #{lhs[0]}"
      end
    end

    def new_assignable(ref)
      case ref[0]
      when :ivar
        ref[0] = :iasgn
      when :const
        ref[0] = :cdecl
      when :identifier
        @scope.add_local ref[1] unless @scope.has_local? ref[1]
        ref[0] = :lasgn
      when :gvar
        ref[0] = :gasgn
      when :cvar
        ref[0] = :cvdecl
      else
        raise "Bad new_assignable type: #{ref[0]}"
      end

      ref
    end

    def new_gettable(ref)
      res = case ref[0]
            when :lasgn
              s(:lvar, ref[1])
            when :iasgn
              s(:ivar, ref[1])
            when :gasgn
              s(:gvar, ref[1])
            when :cvdecl
              s(:cvar, ref[1])
            else
              raise "Bad new_gettable ref: #{ref[0]}"
            end

      res.line = ref.line
      res
    end

    def new_var_ref(ref)
      case ref[0]
      when :self, :nil, :true, :false, :line, :file
        ref
      when :const
        ref
      when :ivar, :gvar, :cvar
        ref
      when :int
        # this is when we passed __LINE__ which is converted into :int
        ref
      when :str
        # returns for __FILE__ as it is converted into str
        ref
      when :identifier
        if @scope.has_local? ref[1]
          s(:lvar, ref[1])
        else
          s(:call, nil, ref[1], s(:arglist))
        end
      else
        raise "Bad var_ref type: #{ref[0]}"
      end
    end

    def new_super(args)
      args = (args || s(:arglist))

      if args[0] == :array
        args[0] = :arglist
      end

      s(:super, args)
    end

    def new_yield(args)
      args = (args || s(:arglist))[1..-1]
      s(:yield, *args)
    end

    def new_xstr(str)
      return s(:xstr, '') unless str
      case str[0]
      when :str   then str[0] = :xstr
      when :dstr  then str[0] = :dxstr
      when :evstr then str = s(:dxstr, '', str)
      end

      str
    end

    def new_dsym(str)
      return s(:nil) unless str
      case str[0]
      when :str
        str[0] = :sym
        str[1] = str[1].to_sym
      when :dstr
        str[0] = :dsym
      end

      str
    end

    def new_str(str)
      # cover empty strings
      return s(:str, "") unless str
      # catch s(:str, "", other_str)
      if str.size == 3 and str[1] == "" and str[0] == :str
        return str[2]
      # catch s(:str, "content", more_content)
      elsif str[0] == :str && str.size > 3
        str[0] = :dstr
        str
      # top level evstr should be a dstr
      elsif str[0] == :evstr
        s(:dstr, "", str)
      else
        str
      end
    end

    def new_regexp(reg, ending)
      return s(:regexp, //) unless reg
      case reg[0]
      when :str
        s(:regexp, Regexp.new(reg[1], ending))
      when :evstr
        s(:dregx, "", reg)
      when :dstr
        reg[0] = :dregx
        reg
      end
    end

    def str_append(str, str2)
      return str2 unless str
      return str unless str2

      if str.first == :evstr
        str = s(:dstr, "", str)
      elsif str.first == :str
        str = s(:dstr, str[1])
      else
        #puts str.first
      end
      str << str2
      str
    end
  end
end

