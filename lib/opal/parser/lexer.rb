require 'opal/parser/grammar'
require 'opal/parser/sexp'

require 'strscan'

module Opal
  class Grammar < Racc::Parser

  class LexingError < StandardError; end

  attr_reader :line

  def initialize
    @lex_state  = :expr_beg
    @cond       = 0
    @cmdarg     = 0
    @line       = 1
    @scopes     = []

    @string_parse_stack = []
  end

  def s *parts
    sexp = Sexp.new *parts
    sexp.line = @line
    sexp
  end

  def parse source, file = '(string)'
    #puts "============"
    @file = file
    @scanner = StringScanner.new source
    push_scope
    result = do_parse
    pop_scope

    result
  end

  class LexerScope
    attr_reader :locals
    attr_accessor :parent

    def initialize type
      @block  = type == :block
      @locals = []
      @parent = nil
    end

    def add_local local
      @locals << local
    end

    def has_local? local
      return true if @locals.include? local
      return @parent.has_local?(local) if @parent and @block
      false
    end
  end

  def push_scope type = nil
    top = @scopes.last
    scope = LexerScope.new type
    scope.parent = top
    @scopes << scope
    @scope = scope
  end

  def pop_scope
    @scopes.pop
    @scope = @scopes.last
  end

  def new_block stmt = nil
    s = s(:block)
    s << stmt if stmt
    s
  end

  def new_compstmt block
    if block.size == 1
      nil
    elsif block.size == 2
      block[1]
    else
      block.line = block[1].line
      block
    end
  end

  def new_body compstmt, res, els, ens
    s = compstmt || s(:block)

    if compstmt
     # s = s(:block, compstmt) unless compstmt[0] == :block
      s.line = compstmt.line
    end

    if res
      s = s(:rescue, s)
      res.each { |r| s << r }
      s << els if els
    end

    if ens
      s = s(:ensure, s, ens)
    end

    s
  end

  def new_defn line, name, args, body
    body = s(:block, body) if body[0] != :block
    scope = s(:scope, body)
    body << s(:nil) if body.size == 1
    scope.line = body.line
    args.line = line
    s = s(:defn, name.intern, args, scope)
    s.line = line
    s.end_line = @line
    s
  end

  def new_defs line, recv, name, args, body
    scope = s(:scope, body)
    scope.line = body.line
    s = s(:defs, recv, name.intern, args, scope)
    s.line = line
    s.end_line = @line
    s
  end

  def new_class path, sup, body
    scope = s(:scope)
    scope << body unless body.size == 1
    scope.line = body.line
    s = s(:class, path, sup, scope)
    s
  end

  def new_sclass expr, body
    scope = s(:scope)
    scope << body unless body.size == 1
    scope.line = body.line
    s = s(:sclass, expr, scope)
    s
  end

  def new_module path, body
    scope = s(:scope)
    scope << body unless body.size == 1
    scope.line = body.line
    s = s(:module, path, scope)
    s
  end

  def new_iter call, args, body
    s = s(:iter, call, args)
    s << body if body
    s.end_line = @line
    s
  end

  def new_if expr, stmt, tail
    s = s(:if, expr, stmt, tail)
    s.line = expr.line
    s.end_line = @line
    s
  end

  def new_args norm, opt, rest, block
    res = s(:args)

    if norm
      norm.each do |arg|
        @scope.add_local arg
        res << arg
      end
    end

    if opt
      opt[1..-1].each do |opt|
        res << opt[1]
      end
    end

    if rest
      res << rest
      @scope.add_local rest.to_s[1..-1].intern
    end

    if block
      res << block
      @scope.add_local block.to_s[1..-1].intern
    end

    res << opt if opt

    res
  end

  def new_block_args norm, opt, rest, block
    res = s(:array)

    if norm
      norm.each do |arg|
        @scope.add_local arg
        res << s(:lasgn, arg)
      end
    end

    if opt
      opt[1..-1].each do |opt|
        res << s(:lasgn, opt[1])
      end
    end

    if rest
      r = rest.to_s[1..-1].intern
      res << s(:splat, s(:lasgn, r))
      @scope.add_local r
    end

    if block
      b = block.to_s[1..-1].intern
      res << s(:block_pass, s(:lasgn, b))
      @scope.add_local r
    end

    res << opt if opt

    res.size == 2 && norm ? res[1] : s(:masgn, res)
  end

  def new_call recv, meth, args = nil
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

  def add_block_pass arglist, block
    arglist << block if block
    arglist
  end

  def new_op_asgn op, lhs, rhs
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

  def new_assign lhs, rhs
    case lhs[0]
    when :iasgn, :cdecl, :lasgn, :gasgn, :cvdecl
      lhs << rhs
      lhs
    when :call, :attrasgn
      lhs.last << rhs
      lhs
    else
      raise "Bad lhs for new_assign: #{lhs[0]}"
    end
  end

  def new_assignable ref
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

  def new_gettable ref
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

  def new_var_ref ref
    case ref[0]
    when :self, :nil, :true, :false, :line, :file
      ref
    when :const
      ref
    when :ivar, :gvar, :cvar
      ref
    when :lit
      # this is when we passed __LINE__ which is converted into :lit
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

  def new_super args
    args = (args || s(:arglist))[1..-1]
    s(:super, *args)
  end

  def new_yield args
    args = (args || s(:arglist))[1..-1]
    s(:yield, *args)
  end

  def new_xstr str
    return s(:xstr, '') unless str
    case str[0]
    when :str   then str[0] = :xstr
    when :dstr  then str[0] = :dxstr
    when :evstr then str = s(:dxstr, '', str)
    end

    str
  end

  def new_dsym str
    return s(:nil) unless str
    case str[0]
    when :str
      str[0] = :lit
      str[1] = str[1].intern
    when :dstr
      str[0] = :dsym
    end

    str
  end

  def new_str str
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

  def new_regexp reg
    return s(:lit, //) unless reg
    case reg[0]
    when :str
      s(:lit, Regexp.new(reg[1]))
    when :evstr
      res = s(:dregx, "", reg)
    when :dstr
      reg[0] = :dregx
      reg
    end
  end

  def str_append str, str2
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

  def next_token
    t = get_next_token
    #puts "returning token #{t.inspect}"
    #t[1] = { :value => t[1], :line => @line }
    t
  end

  def cond_push(n)
    @cond = (@cond << 1) | (n & 1)
  end

  def cond_pop
    @cond = @cond >> 1
  end

  def cond_lexpop
    @cond = (@cond >> 1) | (@cond & 1)
  end

  def cond?
    (@cond & 1) != 0
  end

  def cmdarg_push(n)
    @cmdarg = (@cmdarg << 1) | (n & 1)
  end

  def cmdarg_pop
    @cmdarg = @cmdarg >> 1
  end

  def cmdarg_lexpop
    @cmdarg = (@cmdarg >> 1) | (@cmdarg & 1)
  end

  def cmdarg?
    (@cmdarg & 1) != 0
  end

  def next_string_token
    # str_parse, scanner = current_string_parse, @scanner
    str_parse = @string_parse
    scanner = @scanner
    space = false

    # everything bar single quote and lower case bare wrds can interpolate
    interpolate = str_parse[:interpolate]

    words = ['w', 'W'].include? str_parse[:beg]

    space = true if ['w', 'W'].include?(str_parse[:beg]) and scanner.scan(/\s+/)

    # if not end of string, so we must be parsing contents
    str_buffer = []

    # see if we can read end of string/xstring/regecp markers
    # if scanner.scan /#{str_parse[:end]}/
    if scanner.scan Regexp.new(Regexp.escape(str_parse[:end]))
      if words && !str_parse[:done_last_space]#&& space
        str_parse[:done_last_space] = true
        scanner.pos -= 1
        return :SPACE, ' '
      end
      @string_parse = nil

      # return :SPACE, ' ' if words && space

      # if in %Q{, we should balance { with } before ending.
      if str_parse[:balance]
        if str_parse[:nesting] == 0
          @lex_state = :expr_end
          return :STRING_END, scanner.matched
        else
          #puts "nesting not 0!"
          #puts str_parse[:nesting]
          str_buffer << scanner.matched
          str_parse[:nesting] -= 1
          # make sure we carry on string parse (its set to nil above)
          @string_parse = str_parse
        end

      elsif ['"', "'"].include? str_parse[:beg]
        @lex_state = :expr_end
        return :STRING_END, scanner.matched

      elsif str_parse[:beg] == '`'
        @lex_state = :expr_end
        return :STRING_END, scanner.matched

      elsif str_parse[:beg] == '/'
        result = scanner.matched if scanner.scan(/\w+/)
        @lex_state = :expr_end
        return :REGEXP_END, result

      else
        @lex_state = :expr_end
        return :STRING_END, scanner.matched
      end
    end

    return :SPACE, ' ' if space

    if str_parse[:balance] and scanner.scan Regexp.new(Regexp.escape(str_parse[:beg]))
      #puts "matced beg balance!"
      str_buffer << scanner.matched
      str_parse[:nesting] += 1
    elsif scanner.check(/#[$@]/)
      scanner.scan(/#/)
      if interpolate
        return :STRING_DVAR, scanner.matched
      else
        str_buffer << scanner.matched
      end

    elsif scanner.scan(/#\{/)
      if interpolate
        # we are into ruby code, so stop parsing content (for now)
        return :STRING_DBEG, scanner.matched
      else
        str_buffer << scanner.matched
      end

    # causes error, so we will just collect it later on with other text
    elsif scanner.scan(/\#/)
      str_buffer << '#'
    end

    add_string_content str_buffer, str_parse
    complete_str = str_buffer.join ''
    return :STRING_CONTENT, complete_str
  end

  def add_string_content(str_buffer, str_parse)
    scanner = @scanner
    # regexp for end of string/regexp
    # end_str_re = /#{str_parse[:end]}/
    end_str_re = Regexp.new(Regexp.escape(str_parse[:end]))
    # can be interpolate
    interpolate = str_parse[:interpolate]

    words = ['W', 'w'].include? str_parse[:beg]

    until scanner.eos?
      c = nil
      handled = true

      if scanner.check end_str_re
        # eos
        # if its just balancing, add it ass normal content..
        if str_parse[:balance] && (str_parse[:nesting] != 0)
          # we only checked above, so actually scan it
          scanner.scan end_str_re
          c = scanner.matched
          str_parse[:nesting] -= 1
        else
          # not balancing, so break (eos!)
          break
        end

      elsif str_parse[:balance] and scanner.scan Regexp.new(Regexp.escape(str_parse[:beg]))
        str_parse[:nesting] += 1
        c = scanner.matched

      elsif words && scanner.scan(/\s/)
        scanner.pos -= 1
        break

      elsif interpolate && scanner.check(/#(?=[\@\{])/)
        break

      #elsif scanner.scan(/\\\\/)
        #c = scanner.matched

      elsif scanner.scan(/\\/)
        if str_parse[:regexp]
          if scanner.scan(/(.)/)
            c = "\\" + scanner.matched
          end
        else
          c = if scanner.scan(/n/)
            "\n"
          else
            # escaped char doesnt need escaping, so just return it
            scanner.scan(/./)
            scanner.matched
          end 
        end
      else
        handled = false
      end

      unless handled
        reg = if words
                Regexp.new("[^#{Regexp.escape str_parse[:end]}\#\0\n\ \\\\]+|.")
              elsif str_parse[:balance]
                #puts "using tis regexp"
                Regexp.new("[^#{Regexp.escape str_parse[:end]}#{Regexp.escape str_parse[:beg]}\#\0\\\\]+|.")
              else
                Regexp.new("[^#{Regexp.escape str_parse[:end]}\#\0\\\\]+|.")
              end

        scanner.scan reg
        #puts scanner.matched
        c = scanner.matched
      end

      c ||= scanner.matched
      str_buffer << c
    end

    raise "reached EOF while in string" if scanner.eos?
  end

  def get_next_token
    if @string_parse
      return next_string_token
    end

    # scanner, space_seen, cmd_start, c = @scanner, false, false, ''
    scanner = @scanner
    space_seen = false
    cmd_start = false
    c = ''

    while true
      if scanner.scan(/\ |\t|\r/)
        space_seen = true
        next

      elsif scanner.scan(/(\n|#)/)
        c = scanner.matched
        if c == '#' then scanner.scan(/(.*)/) else @line += 1; end

        scanner.scan(/(\n+)/)
        @line += scanner.matched.length if scanner.matched

        next if [:expr_beg, :expr_dot].include? @lex_state

        cmd_start = true
        @lex_state = :expr_beg
        return '\\n', '\\n'

      elsif scanner.scan(/\;/)
        @lex_state = :expr_beg
        return ';', ';'

      elsif scanner.scan(/\"/)
        @string_parse = { :beg => '"', :end => '"', :interpolate => true }
        return :STRING_BEG, scanner.matched

      elsif scanner.scan(/\'/)
        @string_parse = { :beg => "'", :end => "'" }
        return :STRING_BEG, scanner.matched

      elsif scanner.scan(/\`/)
        @string_parse = { :beg => "`", :end => "`", :interpolate => true }
        return :XSTRING_BEG, scanner.matched

      elsif scanner.scan(/\%W/)
        start_word  = scanner.scan(/./)
        end_word    = { '(' => ')', '[' => ']', '{' => '}' }[start_word] || start_word
        @string_parse = { :beg => 'W', :end => end_word, :interpolate => true }
        scanner.scan(/\s*/)
        return :WORDS_BEG, scanner.matched

      elsif scanner.scan(/\%w/)
        start_word  = scanner.scan(/./)
        end_word    = { '(' => ')', '[' => ']', '{' => '}' }[start_word] || start_word
        @string_parse = { :beg => 'w', :end => end_word }
        scanner.scan(/\s*/)
        return :AWORDS_BEG, scanner.matched

      elsif scanner.scan(/\%[Qq]/)
        interpolate = scanner.matched.end_with? 'Q'
        start_word  = scanner.scan(/./)
        end_word    = { '(' => ')', '[' => ']', '{' => '}' }[start_word] || start_word
        @string_parse = { :beg => start_word, :end => end_word, :balance => true, :nesting => 0, :interpolate => interpolate }
        return :STRING_BEG, scanner.matched

      elsif scanner.scan(/\%x/)
        start_word = scanner.scan(/./)
        end_word   = { '(' => ')', '[' => ']', '{' => '}' }[start_word] || start_word
        @string_parse = { :beg => start_word, :end => end_word, :balance => true, :nesting => 0, :interpolate => true }
        return :XSTRING_BEG, scanner.matched

      elsif scanner.scan(/\//)
        if [:expr_beg, :expr_mid].include? @lex_state
          @string_parse = { :beg => '/', :end => '/', :interpolate => true, :regexp => true }
          return :REGEXP_BEG, scanner.matched
        elsif scanner.scan(/\=/)
          @lex_state = :expr_beg
          return :OP_ASGN, '/'
        elsif @lex_state == :expr_fname
          @lex_state = :expr_end
        end

        return '/', '/'

      elsif scanner.scan(/\%/)
        if scanner.scan(/\=/)
          @lex_state = :expr_beg
          return :OP_ASGN, '%'
        end
        @lex_state = @lex_state == :expr_fname ? :expr_end : :expr_beg
        return '%', '%'

      elsif scanner.scan(/\(/)
        result = scanner.matched
        if [:expr_beg, :expr_mid].include? @lex_state
          result = :PAREN_BEG
        elsif space_seen
          result = '('
        end

        @lex_state = :expr_beg
        cond_push 0
        cmdarg_push 0

        return result, scanner.matched

      elsif scanner.scan(/\)/)
        cond_lexpop
        cmdarg_lexpop
        @lex_state = :expr_end
        return ')', scanner.matched

      elsif scanner.scan(/\[/)
        result = scanner.matched

        if [:expr_fname, :expr_dot].include? @lex_state
          @lex_state = :expr_arg
          if scanner.scan(/\]=/)
            return '[]=', '[]='
          elsif scanner.scan(/\]/)
            return '[]', '[]'
          else
            raise "Unexpected '[' token"
          end
        elsif [:expr_beg, :expr_mid].include?(@lex_state) || space_seen
          @lex_state = :expr_beg
          cond_push 0
          cmdarg_push 0
          return '[', scanner.matched
        else
          @lex_state = :expr_beg
          cond_push 0
          cmdarg_push 0
          return '[@', scanner.matched
        end

      elsif scanner.scan(/\]/)
        cond_lexpop
        cmdarg_lexpop
        @lex_state = :expr_end
        return ']', scanner.matched

      elsif scanner.scan(/\}/)
        cond_lexpop
        cmdarg_lexpop
        @lex_state = :expr_end

        return '}', scanner.matched

      elsif scanner.scan(/\.\.\./)
        @lex_state = :expr_beg
        return '...', scanner.matched

      elsif scanner.scan(/\.\./)
        @lex_state = :expr_beg
        return '..', scanner.matched

      elsif scanner.scan(/\./)
        @lex_state = :expr_dot unless @lex_state == :expr_fname
        return '.', scanner.matched

      elsif scanner.scan(/\*\*\=/)
        @lex_state = :expr_beg
        return :OP_ASGN, '**'

      elsif scanner.scan(/\*\*/)
        return '**', '**'

      elsif scanner.scan(/\*\=/)
        @lex_state = :expr_beg
        return :OP_ASGN, '*'

      elsif scanner.scan(/\*/)
        result = scanner.matched
        if @lex_state == :expr_fname
          @lex_state = :expr_end
          return '*', result
        elsif space_seen && scanner.check(/\S/)
          @lex_state = :expr_beg
          return :SPLAT, result
        elsif [:expr_beg, :expr_mid].include? @lex_state
          @lex_state = :expr_beg
          return :SPLAT, result
        else
          @lex_state = :expr_beg
          return '*', result
        end

      elsif scanner.scan(/\:\:/)
        if [:expr_beg, :expr_mid, :expr_class].include? @lex_state
          @lex_state = :expr_beg
          return '::@', scanner.matched
        end

        @lex_state = :expr_dot
        return '::', scanner.matched

      elsif scanner.scan(/\:/)
        if [:expr_end, :expr_endarg].include?(@lex_state) || scanner.check(/\s/)
          unless scanner.check(/\w/)
            @lex_state = :expr_beg
            return ':', ':'
          end

          @lex_state = :expr_fname
          return :SYMBOL_BEG, ':'
        end

        if scanner.scan(/\'/)
          @string_parse = { :beg => "'", :end => "'" }
        elsif scanner.scan(/\"/)
          @string_parse = { :beg => '"', :end => '"', :interpolate => true }
        end

        @lex_state = :expr_fname
        return :SYMBOL_BEG, ':'

      elsif scanner.check(/\|/)
        if scanner.scan(/\|\|\=/)
          @lex_state = :expr_beg
          return :OP_ASGN, '||'
        elsif scanner.scan(/\|\|/)
          @lex_state = :expr_beg
          return '||', '||'
        elsif scanner.scan(/\|\=/)
          @lex_state = :expr_beg
          return :OP_ASGN, '|'
        elsif scanner.scan(/\|/)
          if @lex_state == :expr_fname
            @lex_state = :expr_end
            return '|', scanner.matched
          else
            @lex_state = :expr_beg
            return '|', scanner.matched
          end
        end

      elsif scanner.scan(/\^\=/)
        @lex_state = :exor_beg
        return :OP_ASGN, '^'
      elsif scanner.scan(/\^/)
        if @lex_state == :expr_fname
          @lex_state = :expr_end
          return '^', scanner.matched
        end

        @lex_state = :expr_beg
        return '^', scanner.matched

      elsif scanner.check(/\&/)
        if scanner.scan(/\&\&\=/)
          @lex_state = :expr_beg
          return :OP_ASGN, '&&'
        elsif scanner.scan(/\&\&/)
          @lex_state = :expr_beg
          return '&&', scanner.matched
        elsif scanner.scan(/\&\=/)
          @lex_state = :expr_beg
          return :OP_ASGN, '&'
        elsif scanner.scan(/\&/)
          if space_seen && !scanner.check(/\s/) && (@lex_state == :expr_cmdarg || @lex_state == :expr_arg)
            return '&@', '&'
          elsif [:expr_beg, :expr_mid].include? @lex_state
            return '&@', '&'
          else
            return '&', '&'
          end
        end

      elsif scanner.check(/\</)
        if scanner.scan(/\<\<\=/)
          @lex_state = :expr_beg
          return :OP_ASGN, '<<'
        elsif scanner.scan(/\<\</)
          if @lex_state == :expr_fname
            @lex_state = :expr_end
            return '<<', '<<'
          elsif ![:expr_end, :expr_dot, :expr_endarg, :expr_class].include?(@lex_state) && space_seen
            if scanner.scan(/(-?)(\w+)/)
              heredoc = scanner[2]
              # for now just scrap rest of line + skip down one line for
              # string content
              scanner.scan(/.*\n/)
              @string_parse = { :beg => heredoc, :end => heredoc, :interpolate => true }
              return :STRING_BEG, heredoc
            end
            @lex_state = :expr_beg
            return '<<', '<<'
          end
          @lex_state = :expr_beg
          return '<<', '<<'
        elsif scanner.scan(/\<\=\>/)
          if @lex_state == :expr_fname
            @lex_state = :expr_end
          else
            @lex_state = :expr_beg
          end
          return '<=>', '<=>'
        elsif scanner.scan(/\<\=/)
          if @lex_state == :expr_fname
            @lex_state = :expr_end
          else
            @lex_state = :expr_beg
          end
          return '<=', '<='
        elsif scanner.scan(/\</)
          if @lex_state == :expr_fname
            @lex_state = :expr_end
          else
            @lex_state = :expr_beg
          end
          return '<', '<'
        end

      elsif scanner.check(/\>/)
        if scanner.scan(/\>\>\=/)
          return :OP_ASGN, '>>'
        elsif scanner.scan(/\>\>/)
          return '>>', '>>'
        elsif scanner.scan(/\>\=/)
          if @lex_state == :expr_fname
            @lex_state = :expr_end
          else
            @lex_state = :expr_beg
          end
          return '>=', scanner.matched
        elsif scanner.scan(/\>/)
          if @lex_state == :expr_fname
            @lex_state = :expr_end
          else
            @lex_state = :expr_beg
          end
          return '>', '>'
        end

      elsif scanner.scan(/[+-]/)
        result  = scanner.matched
        sign    = result + '@'

        if @lex_state == :expr_beg || @lex_state == :expr_mid
          @lex_state = :expr_mid
          return [sign, sign]
        elsif @lex_state == :expr_fname
          @lex_state = :expr_end
          return [:IDENTIFIER, result + scanner.matched] if scanner.scan(/@/)
          return [result, result]
        end

        if scanner.scan(/\=/)
          @lex_state = :expr_beg
          return [:OP_ASGN, result]
        end

        @lex_state = :expr_beg
        return [result, result]

      elsif scanner.scan(/\?/)
        @lex_state = :expr_beg if [:expr_end, :expr_endarg].include?(@lex_state)
        return '?', scanner.matched

      elsif scanner.scan(/\=\=\=/)
        if @lex_state == :expr_fname
          @lex_state = :expr_end
          return '===', '==='
        end
        @lex_state = :expr_beg
        return '===', '==='

      elsif scanner.scan(/\=\=/)
        if @lex_state == :expr_fname
          @lex_state = :expr_end
          return '==', '=='
        end
        @lex_state = :expr_beg
        return '==', '=='

      elsif scanner.scan(/\=\~/)
        if @lex_state == :expr_fname
          @lex_state = :expr_end
          return '=~', '=~'
        end
        @lex_state = :expr_beg
        return '=~', '=~'

      elsif scanner.scan(/\=\>/)
        @lex_state = :expr_beg
        return '=>', '=>'

      elsif scanner.scan(/\=/)
        @lex_state = :expr_beg
        return '=', '='

      elsif scanner.scan(/\!\=/)
        if @lex_state == :expr_fname
          @lex_state == :expr_end
          return '!=', '!='
        end
        @lex_state = :expr_beg
        return '!=', '!='

      elsif scanner.scan(/\!\~/)
        @lex_state = :expr_beg
        return '!~', '!~'

      elsif scanner.scan(/\!/)
        if @lex_state == :expr_fname
          @lex_state = :expr_end
          return '!', '!'
        end
        @lex_state = :expr_beg
        return '!', '!'

      elsif scanner.scan(/\~/)
        if @lex_state == :expr_fname
          @lex_state = :expr_end
          return '~', '~'
        end
        @lex_state = :expr_beg
        return '~', '~'

      elsif scanner.scan(/\$[\+\'\`\&!@\"~*$?\/\\:;=.,<>_]/)
        @lex_state = :expr_end
        return :GVAR, scanner.matched

      elsif scanner.scan(/\$\w+/)
        @lex_state = :expr_end
        return :GVAR, scanner.matched

      elsif scanner.scan(/\@\@\w*/)
        @lex_state = :expr_end
        return :CVAR, scanner.matched

      elsif scanner.scan(/\@\w*/)
        @lex_state = :expr_end
        return :IVAR, scanner.matched

      elsif scanner.scan(/\,/)
        @lex_state = :expr_beg
        return ',', scanner.matched

      elsif scanner.scan(/\{/)
        if [:expr_end, :expr_arg, :expr_cmdarg].include? @lex_state
          result = :LCURLY
        elsif @lex_state == :expr_endarg
          result = :LBRACE_ARG
        else
          result = '{'
        end

        @lex_state = :expr_beg
        cond_push 0
        cmdarg_push 0
        return result, scanner.matched

      elsif scanner.check(/[0-9]/)
        @lex_state = :expr_end
        if scanner.scan(/[\d_]+\.[\d_]+\b/)
          return [:FLOAT, scanner.matched.gsub(/_/, '').to_f]
        elsif scanner.scan(/[\d_]+\b/)
          return [:INTEGER, scanner.matched.gsub(/_/, '').to_i]
        elsif scanner.scan(/0(x|X)(\d|[a-f]|[A-F])+/)
          return [:INTEGER, scanner.matched.to_i]
        else
          raise "Lexing error on numeric type: `#{scanner.peek 5}`"
        end

      elsif scanner.scan(/(\w)+[\?\!]?/)
        matched = scanner.matched
        if scanner.peek(2) != '::' && scanner.scan(/:/)
          @lex_state = :expr_beg
          return :LABEL, "#{matched}"
        end

        case matched
        when 'class'
          if @lex_state == :expr_dot
            @lex_state = :expr_end
            return :IDENTIFIER, matched
          end
          @lex_state = :expr_class
          return :CLASS, matched

        when 'module'
          return :IDENTIFIER, matched if @lex_state == :expr_dot
          @lex_state = :expr_class
          return :MODULE, matched

        when 'defined?'
          return :IDENTIFIER, matched if @lex_state == :expr_dot
          @lex_state = :expr_arg
          return :DEFINED, 'defined?'

        when 'def'
          @lex_state = :expr_fname
          @scope_line = @line
          return :DEF, matched

        when 'undef'
          @lex_state = :expr_fname
          return :UNDEF, matched

        when 'end'
          if [:expr_dot, :expr_fname].include? @lex_state
            @lex_state = :expr_end
            return :IDENTIFIER, matched
          end

          @lex_state = :expr_end
          return :END, matched

        when 'do'
          #puts cond?
          #puts cmdarg?
          #nputs @lex_state
          if cond?
            @lex_state = :expr_beg
            return :DO_COND, matched
          elsif cmdarg? && @lex_state != :expr_cmdarg
            @lex_state = :expr_beg
            return :DO_BLOCK, matched
          elsif @lex_state == :expr_endarg
            return :DO_BLOCK, matched
          else
            @lex_state = :expr_beg
            return :DO, matched
          end

        when 'if'
          return :IF, matched if @lex_state == :expr_beg
          @lex_state = :expr_beg
          return :IF_MOD, matched

        when 'unless'
          return :UNLESS, matched if @lex_state == :expr_beg
          @lex_state = :expr_beg
          return :UNLESS_MOD, matched

        when 'else'
          return :ELSE, matched

        when 'elsif'
          return :ELSIF, matched

        when 'self'
          @lex_state = :expr_end unless @lex_state == :expr_fname
          return :SELF, matched

        when 'true'
          @lex_state = :expr_end
          return :TRUE, matched

        when 'false'
          @lex_state = :expr_end
          return :FALSE, matched

        when 'nil'
          @lex_state = :expr_end
          return :NIL, matched

        when '__LINE__'
          @lex_state = :expr_end
          return :LINE, @line.to_s

        when '__FILE__'
          @lex_state = :expr_end
          return :FILE, matched

        when 'begin'
          if [:expr_dot, :expr_fname].include? @lex_state
            @lex_state = :expr_end
            return :IDENTIFIER, matched
          end
          @lex_state = :expr_beg
          return :BEGIN, matched

        when 'rescue'
          return :IDENTIFIER, matched if [:expr_dot, :expr_fname].include? @lex_state
          return :RESCUE, matched if @lex_state == :expr_beg
          @lex_state = :expr_beg
          return :RESCUE_MOD, matched

        when 'ensure'
          @lex_state = :expr_beg
          return :ENSURE, matched

        when 'case'
          @lex_state = :expr_beg
          return :CASE, matched

        when 'when'
          @lex_state = :expr_beg
          return :WHEN, matched

        when 'or'
          @lex_state = :expr_beg
          return :OR, matched

        when 'and'
          @lex_state = :expr_beg
          return :AND, matched

        when 'not'
          @lex_state = :expr_beg
          return :NOT, matched

        when 'return'
          @lex_state = :expr_mid
          return :RETURN, matched

        when 'next'
          if @lex_state == :expr_dot || @lex_state == :expr_fname
            @lex_state = :expr_end
            return :IDENTIFIER, matched
          end

          @lex_state = :expr_mid
          return :NEXT, matched

        when 'redo'
          if @lex_state == :expr_dot || @lex_state == :expr_fname
            @lex_state = :expr_end
            return :IDENTIFIER, matched
          end

          @lex_state = :expr_mid
          return :REDO, matched

        when 'break'
          @lex_state = :expr_mid
          return :BREAK, matched

        when 'super'
          @lex_state = :expr_arg
          return :SUPER, matched

        when 'then'
          return :THEN, matched

        when 'while'
          return :WHILE, matched if @lex_state == :expr_beg
          @lex_state = :expr_beg
          return :WHILE_MOD, matched

        when 'until'
          return :UNTIL, matched if @lex_state == :expr_beg
          @lex_state = :expr_beg
          return :UNTIL_MOD, matched

        when 'yield'
          @lex_state = :expr_arg
          return :YIELD, matched

        when 'alias'
          @lex_state = :expr_fname
          return :ALIAS, matched
        end

        matched = matched
        if scanner.peek(2) != '::' && scanner.scan(/\:/)
          return :LABEL, matched 
        end

        if @lex_state == :expr_fname
          if scanner.scan(/\=/)
            @lex_state = :expr_end
            return :IDENTIFIER, matched + scanner.matched
          end
        end

        if [:expr_beg, :expr_dot, :expr_mid, :expr_arg, :expr_cmdarg].include? @lex_state
          # old:
          #@lex_state = :expr_cmdarg
          # new:
          @lex_state = cmd_start ? :expr_cmdarg : :expr_arg
        else
          @lex_state = :expr_end
        end

        return [matched =~ /[A-Z]/ ? :CONSTANT : :IDENTIFIER, matched]

      end
      return [false, false] if scanner.eos?

      raise LexingError, "Unexpected content in parsing stream `#{scanner.peek 5}`"
    end
  end
end
end
