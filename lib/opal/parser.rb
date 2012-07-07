require 'opal/lexer'
require 'opal/grammar'
require 'opal/scope'

class Array
  attr_accessor :line
  attr_accessor :end_line
end

module Opal
  class OpalParseError < Exception; end

  class Parser
    INDENT = '  '

    LEVEL = [:stmt, :stmt_closure, :list, :expr, :recv]

    COMPARE = %w[< > <= >=]

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

    STATEMENTS = [:xstr, :dxstr]

    attr_reader :grammar

    def self.parse(str)
      self.new.parse str
    end

    def initialize(opts = {})
    end

    def parse(source, file = '(file)')
      @file     = file
      @helpers  = {
        :breaker   => true,
        :slice     => true
      }

      @grammar = Grammar.new
      reset
      top @grammar.parse(source, file)
    end

    def warn(msg)
      puts "#{msg} :#{@file}:#{@line}"
    end

    def error(msg)
      raise "#{msg} :#{@file}:#{@line}"
    end

    def parser_indent
      @indent
    end

    def s(*parts)
      sexp = parts
      sexp.line = @line
      sexp
    end

    def reset
      @line   = 1
      @indent = ''
      @unique = 0
    end

    def mid_to_jsid(mid)
      '$' + if name = METHOD_NAMES[mid.to_sym]
        name + '$'
      else
        mid.sub('!', '$b').sub('?', '$p').sub('=', '$e')
      end
    end

    # guaranteed unique id per file..
    def unique_temp
      "TMP_#{@unique += 1}"
    end

    def top(sexp, options = {})
      code = nil
      vars = []

      in_scope(:top) do
        indent {
          code = @indent + process(s(:scope, sexp), :stmt)
        }

        vars << "__opal = Opal"
        vars << "self = __opal.top"
        vars << "__scope = __opal"
        vars << "nil = __opal.nil"
        vars << "def = #{current_self}._klass.prototype" if @scope.defines_defn
        vars.concat @helpers.keys.map { |h| "__#{h} = __opal.#{h}" }

        code = "#{INDENT}var #{vars.join ', '};\n" + INDENT + @scope.to_vars + "\n" + code
      end

      "function() {\n#{ code }\n}"
    end

    def in_scope(type)
      return unless block_given?

      parent = @scope
      @scope = Scope.new(type, self).tap { |s| s.parent = parent }
      yield @scope

      @scope = parent
    end

    def indent(&block)
      indent = @indent
      @indent += INDENT
      @space = "\n#@indent"
      res = yield
      @indent = indent
      @space = "\n#@indent"
      res
    end

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

    def in_while?
      @scope.in_while?
    end

    def process(sexp, level)
      type = sexp.shift
      meth = "process_#{type}"
      raise "Unsupported sexp: #{type}" unless respond_to? meth

      @line = sexp.line

      __send__ meth, sexp, level
    end

    def returns(sexp)
      return returns s(:nil) unless sexp

      case sexp.first
      when :break, :next
        sexp
      when :yield
        sexp[0] = :returnable_yield
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

    def expression?(sexp)
      !STATEMENTS.include?(sexp.first)
    end

    def process_block(sexp, level)
      result = []
      sexp << s(:nil) if sexp.empty?

      until sexp.empty?
        stmt = sexp.shift
        expr = expression?(stmt) and LEVEL.index(level) < LEVEL.index(:list)
        code = process(stmt, level)
        result << (expr ? "#{code};" : code)
      end

      result.join(@scope.class_scope? ? "\n\n#@indent" : "\n#@indent")
    end

    def process_scope(sexp, level)
      stmt = sexp.shift
      if stmt
        stmt = returns stmt unless @scope.donates_methods
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

      with_temp do |a|
        with_temp do |b|
          l = process recv, :expr
          r = process arg, :expr

          "(%s = %s, %s = %s, typeof(%s) === 'number' ? %s %s %s : %s.%s(%s))" %
            [a, l, b, r, a, a, meth.to_s, b, a, mid, b]
        end
      end
    end

    def js_block_given(sexp, level)
      @scope.uses_block!
      "(#{@scope.block_name} !== nil)"
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
        "'FILE'"
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
        "(#{recv}.#{mid} ? 'method' : nil)"
      when :xstr
        "(typeof(#{process part, :expression}) !== 'undefined')"
      else
        raise "bad defined? part: #{part[0]}"
      end
    end

    # s(:not, sexp)
    def process_not(sexp, level)
      code = "!#{process sexp.shift, :expr}"
      code
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

      args = nil if Fixnum === args # argh
      args ||= s(:masgn, s(:array))
      args = args.first == :lasgn ? s(:array, args) : args[1]

      if args.last[0] == :block_pass
        block_arg = args.pop
        block_arg = block_arg[1][1].to_sym
      end

      if args.last[0] == :splat
        splat = args.last[1][1]
        args.pop
        len = args.length
      end

      indent do
        in_scope(:iter) do
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
            @scope.add_temp 'def = (this._isObject ? this._klass.prototype : this.prototype)'
          end

          code = "\n#@indent#{@scope.to_vars}\n#@indent#{code}"

          scope_name = @scope.identity
        end
      end

      with_temp do |tmp|
        itercode = "function(#{params.join ', '}) {\n#{code}\n#@indent}"
        itercode = "#{scope_name} = #{itercode}" if scope_name

        call << ("(%s = %s, %s._s = %s, %s)" % [tmp, itercode, tmp, current_self, tmp])

        process call, level
      end
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
    def attr_optimize(meth, attrs)
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

      out.join ", \n#@indent"
    end

    def handle_alias_native(sexp)
      args = sexp[2]
      meth = mid_to_jsid args[1][1].to_s
      func = args[2][1]

      @scope.methods << meth
      "%s.%s = %s.%s" % [@scope.proto, meth, @scope.proto, func]
    end

    # s(:call, recv, :mid, s(:arglist))
    # s(:call, nil, :mid, s(:arglist))
    def process_call(sexp, level)
      recv, meth, arglist, iter = sexp
      mid = mid_to_jsid meth.to_s

      case meth
      when :attr_reader, :attr_writer, :attr_accessor
        attrs = arglist[1..-1]
        if @scope.class_scope? && attrs.all? { |a| [:lit, :str].include? a.first }
          return attr_optimize meth, attrs
        end
      when :block_given?
        return js_block_given(sexp, level)
      when :alias_native
        return handle_alias_native(sexp) if @scope.class_scope?
      end

      splat = arglist[1..-1].any? { |a| a.first == :splat }

      if Array === arglist.last and arglist.last.first == :block_pass
        block   = process s(:js_tmp, process(arglist.pop, :expr)), :expr
      elsif iter
        block   = iter
      end

      recv ||= [:self]

      if block
        tmprecv = @scope.new_temp
      elsif splat and recv != [:self] and recv[0] != :lvar
        tmprecv = @scope.new_temp
      end
      
      recv_code = process recv, :recv
      args      = ""

      @scope.queue_temp tmprecv if tmprecv

      args = process arglist, :expr

      if block
        dispatch = "(%s = %s, %s.%s._p = %s, %s.%s" %
          [tmprecv, recv_code, tmprecv, mid, block, tmprecv, mid]

        if splat
          "%s.apply(%s, %s))" % [dispatch, tmprecv, args]
        else
          "%s(%s))" % [dispatch, args]
        end
      else
        dispatch = tmprecv ? "(#{tmprecv} = #{recv_code}).#{mid}" : "#{recv_code}.#{mid}"
        splat ? "#{dispatch}.apply(#{tmprecv || recv_code}, #{args})" : "#{dispatch}(#{args})"
      end
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
        code += (code.empty? ? join : ".concat([#{work}])")
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
          @scope.donates_methods = true
          body = process body, :stmt
          code = @indent + @scope.to_vars + "\n\n#@indent" + body
          code += "\n#{@scope.to_donate_methods}"
        end
      end

      spacer  = "\n#{@indent}#{INDENT}"
      cls     = "function #{name}() {};"
      boot    = "#{name} = __klass(__base, __super, #{name.inspect}, #{name});"
      comment = "#{spacer}// line #{ sexp.line }, #{ @file }, class #{ name }#{spacer}"

      "(function(__base, __super){#{comment}#{cls}#{spacer}#{boot}\n#{code}\n#{@indent}})(#{base}, #{sup})"
    end

    # s(:sclass, recv, body)
    def process_sclass(sexp, level)
      recv = sexp[0]
      body = sexp[1]
      code = nil
      base = process recv, :expr

      in_scope(:sclass) do
        @scope.add_temp '__scope = this._scope'
        code = @scope.to_vars + process(body, :stmt)
      end

      "(function(){#{ code }}).call(#{ base }.$singleton_class())"
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
          @scope.donates_methods = true
          body = process body, :stmt
          code = @indent + @scope.to_vars + "\n\n#@indent" + body + "\n#@indent" + @scope.to_donate_methods
        end
      end

      spacer  = "\n#{@indent}#{INDENT}"
      cls     = "function #{name}() {};"
      boot    = "#{name} = __module(__base, #{name.inspect}, #{name});"
      comment = "#{spacer}// line #{ sexp.line }, #{ @file }, module #{ name }#{spacer}"

      "(function(__base){#{comment}#{cls}#{spacer}#{boot}\n#{code}\n#{@indent}})(#{base})"
    end

    def process_undef(exp, level)
      @helpers[:undef] = true
      jsid = mid_to_jsid exp[0][1].to_s

      # "__undef(this, #{jsid.inspect})"
      # FIXME: maybe add this to donate(). it will be undefined, so
      # when added to includees it will actually undefine methods there
      # too.
      "delete #{ @scope.proto }.#{jsid}"
    end

    # s(:defn, mid, s(:args), s(:scope))
    def process_defn(sexp, level)
      mid = sexp[0]
      args = sexp[1]
      stmts = sexp[2]
      js_def nil, mid, args, stmts, sexp.line, sexp.end_line
    end

    # s(:defs, recv, mid, s(:args), s(:scope))
    def process_defs(sexp, level)
      recv = sexp[0]
      mid  = sexp[1]
      args = sexp[2]
      stmts = sexp[3]
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

      # opt args if last arg is sexp
      opt = args.pop if Array === args.last

      # block name &block
      if args.last.to_s[0] == '&'
        block_name = args.pop[1..-1].to_sym
      end

      # splat args *splat
      if args.last.to_s[0] == '*'
        if args.last == :*
          args.pop
        else
          splat = args[-1].to_s[1..-1].to_sym
          args[-1] = splat
          len = args.length - 2
        end
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

          opt[1..-1].each do |o|
            next if o[2][2] == :undefined
            id = process s(:lvar, o[1]), :expr
            code += ("if (%s == null) {\n%s%s\n%s}" %
                      [id, @indent + INDENT, process(o, :expre), @indent])
          end if opt

          code += "#{splat} = __slice.call(arguments, #{len});" if splat
          code += "\n#@indent" + process(stmts, :stmt)

          # Returns the identity name if identified, nil otherwise
          scope_name = @scope.identity

          if @scope.uses_block?
            @scope.add_temp '__context'
            @scope.add_temp yielder

            blk = "\n%s%s = %s._p || nil, __context = %s._s, %s._p = null;\n%s" %
              [@indent, yielder, scope_name, yielder, scope_name, @indent]

            code = blk + code
          end

          uses_super = @scope.uses_super

          code = "#@indent#{@scope.to_vars}" + code
        end
      end

      defcode = "#{"#{scope_name} = " if scope_name}function(#{params}) {\n#{code}\n#@indent}"

      comment = "// line #{line}, #{@file}"

      if @scope.class_scope? 
        comment += ", #{ @scope.name }#{ recvr ? '.' : '#' }#{ mid }"
      end

      comment += "\n#{@indent}"

      if recvr
        if smethod
          @scope.smethods << jsid
          "#{ comment }#{ @scope.name }.#{jsid} = #{defcode}"
        else
          "#{ recv }.#{ jsid } = #{ defcode }"
        end
      elsif @scope.class_scope?
        @scope.methods << jsid
        if uses_super
          @scope.add_temp uses_super
          uses_super = "#{uses_super} = #{@scope.proto}.#{jsid};\n#@indent"
        end
        "#{ comment }#{uses_super}#{ @scope.proto }.#{jsid} = #{defcode}"
      elsif @scope.type == :iter
        "def.#{jsid} = #{defcode}"
      elsif @scope.type == :top
        "#{ current_self }.#{ jsid } = #{ defcode }"
      else
        "def.#{jsid} = #{defcode}"
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
        aritycode + "if ($arity < #{-(arity + 1)}) { opal.arg_error($arity, #{arity}); }"
      else
        aritycode + "if ($arity !== #{arity}) { opal.arg_error($arity, #{arity}); }"
      end
    end

    def process_args(exp, level)
      args = []

      until exp.empty?
        a = exp.shift.to_sym
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
      elsif @scope.top?
        'self'
      else
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
      @helpers[:hash] = true
      "__hash(#{sexp.map { |p| process p, :expr }.join ', '})"
    end

    # s(:while, exp, block, true)
    def process_while(sexp, level)
      expr = sexp[0]
      stmt = sexp[1]
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
        @scope.methods << new
        "%s.%s = %s.%s" % [@scope.proto, new, @scope.proto, old]
      else
        current = current_self
        "%s.prototype.%s = %s.prototype.%s" % [current, new, current, old]
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
        code = ["#{tmp} = [#{process rhs[1], :expr}]"]
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
      "__scope.#{sexp.shift}"
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

      raise "Cannot return as an expression" unless level == :stmt
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
        return "(#{tmp} = #{t} ? #{process rhs, :expr} : #{tmp})".tap {
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
      tmp = @scope.new_temp

      if t = js_truthy_optimize(lhs)
        return "(#{tmp} = #{t} ? #{tmp} : #{process rhs, :expr})".tap {
          @scope.queue_temp tmp
        }
      end

      @scope.queue_temp tmp

      "(%s = %s, %s !== false && %s !== nil ? %s : %s)" %
      [tmp, process(lhs, :expr), tmp, tmp, tmp, process(rhs, :expr)]
    end

    # s(:yield, arg1, arg2)
    def process_yield(sexp, level)
      call = handle_yield_call sexp, level

      if level == :stmt
        "if (#{call} === __breaker) return __breaker.$v"
      else
        call
      end
    end

    # Created by `#returns()` for when a yield statement should return
    # it's value (its last in a block etc).
    def process_returnable_yield(sexp, level)
      call = handle_yield_call sexp, level

      with_temp do |tmp|
        "return %s = #{call}, %s === __breaker ? %s : %s" %
          [tmp, tmp, tmp, tmp]
      end
    end

    def handle_yield_call(sexp, level)
      @scope.uses_block!

      splat = sexp.any? { |s| s.first == :splat }
      sexp.unshift s(:js_tmp, '__context') unless splat
      args = process_arglist sexp, level

      y = @scope.block_name || '__yield'

      splat ? "#{y}.apply(__context, #{args})" : "#{y}.call(#{args})"
    end

    def process_break(exp, level)
      val = exp.empty? ? 'nil' : process(exp.shift, :expr)
      if in_while?
        @while_loop[:closure] ? "return #{ val };" : "break;"
      elsif @scope.iter?
        error "break must be used as a statement" unless level == :stmt
        "return (__breaker.$v = #{ val }, __breaker)"
      else
        error "cannot use break outside of iter/while"
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

        if a.first == :when # when inside another when means a splat of values
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
      name = sexp[1]
      "(%s)._scope.%s" % [process(base, :expr), name.to_s]
    end

    def process_colon3(exp, level)
      "__opal.Object._scope.#{exp.shift.to_s}"
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
        jsid = mid_to_jsid @scope.mid.to_s
        @scope.uses_super = "super_#{jsid}"
        "super_#{jsid}.apply(this, #{ args })"

      elsif @scope.type == :def
        identity = @scope.identify!
        cls_name = @scope.parent.name
        jsid     = mid_to_jsid @scope.mid.to_s
        base     = @scope.defs ? '' : ".prototype"

        "%s._super%s.%s.apply(this, %s)" % [cls_name, base, jsid, args]

      elsif @scope.type == :iter
        chain, defn, mid = @scope.get_super_chain
        trys = chain.map { |c| "#{c}._sup" }.join ' || '
        "(#{trys} || this._klass._super._proto[#{mid}]).apply(this, #{args})"

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

    def process_op_asgn1(sexp, level)
      "'FIXME(op_asgn1)'"
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
        raise "op_asgn2 for ||"
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
      body = process body, level

      parts = []
      until exp.empty?
        part = process exp.shift, level
        part = "else " + part unless parts.empty?
        parts << part
      end
      # if no rescue statement captures our error, we should rethrow
      parts << "else { throw $err; }"

      code = "try {#@space#{body}#@space} catch ($err) {#@space#{parts.join @space}#{@space}}"
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
        #puts a
        a
      }.join ', '
      err = "true" if err.empty?

      if Array === args.last and [:lasgn, :iasgn].include? args.last.first
        val = args.last
        val[2] = s(:js_tmp, "$err")
        val = process(val, :expr) + ";"
      end

      "if (#{err}) {#{@space}#{val}#{body}}"
      # raise exp.inspect
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