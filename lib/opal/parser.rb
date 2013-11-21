require 'opal/parser/sexp'
require 'opal/parser/lexer'
require 'opal/parser/grammar'
require 'opal/parser/parser_scope'

module Opal
  class Parser < Racc::Parser

    attr_reader :lexer, :file, :scope

    def parse(source, file = '(string)')
      @lexer = Lexer.new(source, file)
      @file = file
      @scopes = []

      self.parse_to_sexp
    end

    def parse_to_sexp
      push_scope
      result = do_parse
      pop_scope

      result
    end

    def next_token
      @lexer.next_token
    end

    def s(type, children = [], source = [])
      sexp = Sexp.new([type].concat(children))
      sexp.loc = source
      sexp
    end

    def push_scope(type = nil)
      top = @scopes.last
      scope = ParserScope.new type
      scope.parent = top
      @scopes << scope
      @scope = scope
    end

    def pop_scope
      @scopes.pop
      @scope = @scopes.last
    end

    def on_error(t, val, vstack)
      raise "parse error on value #{val.inspect} (#{token_to_str(t) || '?'}) :#{@file}:#{lexer.line}"
    end

    def value(tok)
      tok[0]
    end

    def source(tok)
      tok[1]
    end

    def new_nil(tok)
      s(:nil, [], source(tok))
    end

    def new_self(tok)
      s(:self, [], source(tok))
    end

    def new_true(tok)
      s(:true, [], source(tok))
    end

    def new_false(tok)
      s(:false, [], source(tok))
    end

    def new___FILE__(tok)
      s(:str, [self.file], source(tok))
    end

    def new___LINE__(tok)
      s(:int, [lexer.line], source(tok))
    end

    def new_ident(tok)
      s(:identifier, [value(tok).to_sym], source(tok))
    end

    def new_int(tok)
      s(:int, [value(tok)], source(tok))
    end

    def new_float(tok)
      s(:float, [value(tok)], source(tok))
    end

    def new_ivar(tok)
      s(:ivar, [value(tok).to_sym], source(tok))
    end

    def new_gvar(tok)
      s(:gvar, [value(tok).to_sym], source(tok))
    end

    def new_cvar(tok)
      s(:cvar, [value(tok).to_sym], source(tok))
    end

    def new_const(tok)
      s(:const, [value(tok).to_sym], source(tok))
    end

    def new_colon2(lhs, tok, name)
      s(:colon2, [lhs, value(name).to_sym], source(tok))
    end

    def new_colon3(tok, name)
      s(:colon3, [value(name).to_sym], source(name))
    end

    def new_sym(tok)
      s(:sym, [value(tok).to_sym], source(tok))
    end

    def new_alias(kw, new, old)
      s(:alias, [new, old], source(kw))
    end

    def new_break(kw, args=[])
      s(:break, args, source(kw))
    end

    def new_return(kw, args=[])
      s(:return, args, source(kw))
    end

    def new_block(stmt = nil)
      s = s(:block, [], nil)
      s << stmt if stmt
      s
    end

    def new_compstmt(block)
      if block.size == 1
        nil
      elsif block.size == 2
        block[1]
      else
        block
      end
      block
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

    def new_def(kw, recv, name, args, body, end_tok)
      body = s(:block, body) if body.type != :block
      body << s(:nil) if body.size == 1

      s(:def, [recv, value(name).to_sym, args, body], source(kw))
    end

    def new_class(start, path, sup, body, endt)
      s(:class, [path, sup, body], source(start))
    end

    def new_sclass(kw, expr, body, end_tok)
      s(:sclass, [expr, body], source(kw))
    end

    def new_module(kw, path, body, end_tok)
      s(:module, [path, body], source(kw))
    end

    def new_iter(args, body)
      args ||= [nil]
      s = s(:iter, args)
      s << body if body
      s
    end

    def new_if(if_tok, expr, stmt, tail)
      s(:if, [expr, stmt, tail], source(if_tok))
    end

    def new_while(kw, test, body)
      s(:while, [test, body], source(kw))
    end

    def new_until(kw, test, body)
      s(:until, [test, body], source(kw))
    end

    def new_rescue_mod(kw, expr, resc)
      s(:rescue_mod, [expr, resc], source(kw))
    end

    def new_array(start, args, finish)
      args ||= []
      s(:array, args, source(start))
    end

    def new_hash(open, assocs, close)
      s(:hash, [*assocs], source(open))
    end

    def new_not(kw, expr)
      s(:not, [expr], source(kw))
    end

    def new_paren(open, expr, close)
      if expr.nil?
        s(:paren, [s(:nil, [], source(open))], source(open))
      else
        s(:paren, [expr], source(open))
      end
    end

    def new_args(norm, opt, rest, block)
      res = s(:args, [])

      if norm
        norm.each do |arg|
          scope.add_local arg
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
        scope.add_local rest_str.to_sym unless rest_str.empty?
      end

      if block
        res << block
        scope.add_local block.to_s[1..-1].to_sym
      end

      res << opt if opt

      res
    end

    def new_block_args(norm, opt, rest, block)
      res = []

      if norm
        norm.each do |arg|
          if arg.is_a? Symbol
            scope.add_local arg
            res << s(:lasgn, [arg])
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
        scope.add_local r
      end

      if block
        b = block.to_s[1..-1].to_sym
        res << s(:block_pass, s(:lasgn, b))
        scope.add_local b
      end

      res << opt if opt

      res.size == 1 && norm ? [res[0]] : [s(:masgn, [s(:array, res)])]
    end

    def new_call(recv, meth, args = [])
      s(:call, [recv, value(meth).to_sym, s(:arglist, args)], source(meth))
    end

    def new_binary_call(recv, meth, arg)
      new_call(recv, meth, [arg])
    end

    def new_unary_call(op, recv)
      new_call(recv, op, [])
    end

    def new_and(lhs, tok, rhs)
      s(:and, [lhs, rhs], source(tok))
    end

    def new_or(lhs, tok, rhs)
      s(:or, [lhs, rhs], source(tok))
    end

    def new_irange(beg, op, finish)
      s(:irange, [beg, finish], source(op))
    end

    def new_erange(beg, op, finish)
      s(:erange, [beg, finish], source(op))
    end

    def add_block_pass(arglist, block)
      arglist << block if block
      arglist
    end

    def new_splat(tok, value)
      s(:splat, [value], source(tok))
    end

    def new_op_asgn(op, lhs, rhs)
      case value(op).to_sym
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

    def new_op_asgn1(lhs, args, op, rhs)
      s(:op_asgn1, [lhs, args, op, rhs], source(op))
    end

    def new_assign(lhs, tok, rhs)
      case lhs.type
      when :iasgn, :cdecl, :lasgn, :gasgn, :cvdecl, :nth_ref
        lhs << rhs
        lhs
      when :call, :attrasgn
        lhs.last << rhs
        lhs
      when :colon2
        lhs << rhs
        lhs.type = :casgn
        lhs
      when :colon3
        lhs << rhs
        lhs.type = :casgn3
        lhs
      else
        raise "Bad lhs for new_assign: #{lhs.type}"
      end
    end

    def new_assignable(ref)
      case ref.type
      when :ivar
        ref.type = :iasgn
      when :const
        ref.type = :cdecl
      when :identifier
        scope.add_local ref[1] unless scope.has_local? ref[1]
        ref.type = :lasgn
      when :gvar
        ref.type = :gasgn
      when :cvar
        ref.type = :cvdecl
      else
        raise "Bad new_assignable type: #{ref.type}"
      end

      ref
    end

    def new_gettable(ref)
      res = case ref.type
            when :lasgn
              s(:lvar, [ref[1]])
            when :iasgn
              s(:ivar, [ref[1]])
            when :gasgn
              s(:gvar, [ref[1]])
            when :cvdecl
              s(:cvar, [ref[1]])
            else
              raise "Bad new_gettable ref: #{ref.type}"
            end

      res.line = ref.line
      res
    end

    def new_var_ref(ref)
      case ref.type
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
        if scope.has_local? ref[1]
          s(:lvar, [ref[1]])
        else
          s(:call, [nil, ref[1], s(:arglist)])
        end
      else
        raise "Bad var_ref type: #{ref.type}"
      end
    end

    def new_super(kw, args)
      args ||= []
      s(:super, args, source(kw))
    end

    def new_yield(args)
      args = (args || s(:arglist))[1..-1]
      s(:yield, *args)
    end

    def new_xstr(str)
      return s(:xstr, '') unless str
      case str.type
      when :str   then str.type = :xstr
      when :dstr  then str.type = :dxstr
      when :evstr then str = s(:dxstr, '', str)
      end

      str
    end

    def new_dsym(str)
      return s(:nil) unless str
      case str.type
      when :str
        str.type = :sym
        str[1] = str[1].to_sym
      when :dstr
        str.type = :dsym
      end

      str
    end

    def new_evstr(str)
      s(:evstr, [str])
    end

    def new_str(str)
      # cover empty strings
      return s(:str, [""]) unless str
      # catch s(:str, "", other_str)
      if str.size == 3 and str[1] == "" and str.type == :str
        return str[2]
      # catch s(:str, "content", more_content)
      elsif str.type == :str && str.size > 3
        str.type = :dstr
        str
      # top level evstr should be a dstr
      elsif str.type == :evstr
        s(:dstr, ["", str])
      else
        str
      end
    end

    def new_regexp(reg, ending)
      return s(:regexp, //) unless reg
      case reg.type
      when :str
        s(:regexp, Regexp.new(reg[1], ending))
      when :evstr
        s(:dregx, "", reg)
      when :dstr
        reg.type = :dregx
        reg
      end
    end

    def str_append(str, str2)
      return str2 unless str
      return str unless str2

      if str.type == :evstr
        str = s(:dstr, ["", str])
      elsif str.type == :str
        str = s(:dstr, [str[1]])
      else
        #puts str.type
      end
      str << str2
      str
    end

    def new_str_content(tok)
      s(:str, [value(tok)], source(tok))
    end
  end
end
