
require 'opal/ruby/ruby_parser'
require 'opal/ruby/nodes'

require 'strscan'

module Opal
  class RubyParser < Racc::Parser

  class RubyLexingError < StandardError

  end

  def initialize(source, options = {})
    @lex_state = :expr_beg

    @cond = 0
    @cmdarg = 0
    @line_number = 1

    @string_parse_stack = []

    @scanner = StringScanner.new source
  end

  def parse!
    do_parse
  end

  def next_token
    t = get_next_token
    # puts "returning token #{t.inspect}"
    t[1] = { :value => t[1], :line => @line_number }
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

  def push_string_parse(hash)
    @string_parse_stack << hash
  end

  def pop_string_parse
    @string_parse_stack.pop
  end

  def current_string_parse
    @string_parse_stack.last
  end

  def next_string_token
    # str_parse, scanner = current_string_parse, @scanner
    str_parse = current_string_parse
    scanner = @scanner
    space = false

    # everything bar single quote and lower case bare wrds can interpolate
    interpolate = (str_parse[:beg] != "'" && str_parse[:beg] != 'w')

    words = ['w', 'W'].include? str_parse[:beg]

    space = true if ['w', 'W'].include?(str_parse[:beg]) and scanner.scan(/\s+/)

    # see if we can read end of string/xstring/regecp markers
    # if scanner.scan /#{str_parse[:end]}/
    if scanner.scan Regexp.new(Regexp.escape(str_parse[:end]))
      if words && !str_parse[:done_last_space]#&& space
        str_parse[:done_last_space] = true
        scanner.pos -= 1
        return :SPACE, ' '
      end
      pop_string_parse

      # return :SPACE, ' ' if words && space
      
      if ['"', "'"].include? str_parse[:beg]
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

    # not end of string, so we must be parsing contents
    str_buffer = []

    if scanner.scan(/#(\$\@)\w+/)
      if interpolate
        return :STRING_DVAR, scanner.matched.slice(2)
      else
        str_buffer << scanner.matched
      end

    elsif scanner.scan(/#\{/)
      if interpolate
        # we are into ruby code, so stop parsing content (for now)
        str_parse[:content] = false
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
    interpolate = ['"', 'W', '/', '`'].include? str_parse[:beg]

    words = ['W', 'w'].include? str_parse[:beg]

    until scanner.eos?
      c = nil
      handled = true

      if scanner.check end_str_re
        # eos
        break

      elsif words && scanner.scan(/\s/)
        scanner.pos -= 1
        break

      elsif interpolate && scanner.check(/#(?=[\@\{])/)
        break

      elsif scanner.scan(/\\\\/)
        c = scanner.matched

      elsif scanner.scan(/\\/)
        c = scanner.matched
        c += scanner.matched if scanner.scan end_str_re

      else
        handled = false
      end

      unless handled
        reg = words ? Regexp.new("[^#{Regexp.escape str_parse[:end]}\#\0\n\ \\\\]+|.") : Regexp.new("[^#{Regexp.escape str_parse[:end]}\#\0\\\\]+|.")
        scanner.scan reg
        c = scanner.matched
      end

      c ||= scanner.matched
      str_buffer << c
    end

    raise "reached EOF while in string" if scanner.eos?
  end

  def get_next_token
    string_scanner = current_string_parse

    if string_scanner && string_scanner[:content]
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
        if c == '#' then scanner.scan(/(.*)/) else @line_number += 1; end

        scanner.scan(/(\n+)/)
        @line_number += scanner.matched.length if scanner.matched

        next if [:expr_beg, :expr_dot].include? @lex_state

        cmd_start = true
        @lex_state = :expr_beg
        return '\\n', '\\n'

      elsif scanner.scan(/\;/)
        @lex_state = :expr_beg
        return ';', ';'

      elsif scanner.scan(/\"/)
        push_string_parse :beg => '"', :content => true, :end => '"'
        return :STRING_BEG, scanner.matched

      elsif scanner.scan(/\'/)
        push_string_parse :beg => "'", :content => true, :end => "'"
        return :STRING_BEG, scanner.matched

      elsif scanner.scan(/\`/)
        push_string_parse :beg => "`", :content => true, :end => "`"
        return :XSTRING_BEG, scanner.matched

      elsif scanner.scan(/\%W/)
        start_word  = scanner.scan(/./)
        end_word    = { '(' => ')', '[' => ']', '{' => '}' }[start_word] || start_word
        push_string_parse :beg => 'W', :content => true, :end => end_word
        return :WORDS_BEG, scanner.matched

      elsif scanner.scan(/\%w/)
        start_word  = scanner.scan(/./)
        end_word    = { '(' => ')', '[' => ']', '{' => '}' }[start_word] || start_word
        push_string_parse :beg => 'w', :content => true, :end => end_word
        return :AWORDS_BEG, scanner.matched

      elsif scanner.scan(/\%[Qq]/)
        start_word  = scanner.scan(/./)
        end_word    = { '(' => ')', '[' => ']', '{' => '}' }[start_word] || start_word
        push_string_parse :beg => start_word, :content => true, :end => end_word
        return :STRING_BEG, scanner.matched

      elsif scanner.scan(/\//)
        if [:expr_beg, :expr_mid].include? @lex_state
          push_string_parse :beg => '/', :content => true, :end => '/'
          return :REGEXP_BEG, scanner.matched
        elsif scanner.scan(/\=/)
          @lex_state = :expr_beg
          return :OP_ASGN, '/'
        elsif @lex_state == :expr_fname
          @lex_state = :expr_end
        end

        return '/', '/'

      elsif scanner.scan(/\%/)
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

        current_string_parse[:content] = true if current_string_parse
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
          push_string_parse :beg => "'", :content => true, :end => "'"
        elsif scanner.scan(/\"/)
          push_string_parse :beg => '"', :content => true, :end => '"'
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
          if space_seen && !scanner.check(/\s/) && @lex_state == :expr_cmdarg
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
          @lex_state = :expr_end
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
        if [:expr_end, :expr_cmdarg].include? @lex_state
          result = '{@'
        elsif @lex_state == :expr_endarg
          result = 'LBRACE_ARG'
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
          return [:FLOAT, scanner.matched.gsub(/_/, '')]
        elsif scanner.scan(/[\d_]+\b/)
          return [:INTEGER, scanner.matched.gsub(/_/, '')]
        elsif scanner.scan(/0(x|X)(\d|[a-f]|[A-F])+/)
          return [:INTEGER, scanner.matched]
        else
          raise "Lexing error on numeric type: `#{scanner.peek 5}`"
        end

      elsif scanner.scan(/(\w)+[\?\!]?/)
        case scanner.matched
        when 'class'
          if @lex_state == :expr_dot
            @lex_state = :expr_end
            return :IDENTIFIER, scanner.matched
          end
          @lex_state = :expr_class
          return :CLASS, scanner.matched

        when 'module'
          return :IDENTIFIER, scanner.matched if @lex_state == :expr_dot
          @lex_state = :expr_class
          return :MODULE, scanner.matched

        when 'def'
          @lex_state = :expr_fname
          return :DEF, scanner.matched

        when 'end'
          if [:expr_dot, :expr_fname].include? @lex_state
            @lex_state = :expr_end
            return :IDENTIFIER, scanner.matched
          end

          @lex_state = :expr_end
          return :END, scanner.matched

        when 'do'
          if cond?
            @lex_state = :expr_beg
            return :DO_COND, scanner.matched
          elsif cmdarg? && @lex_state != :expr_cmdarg
            @lex_state = :expr_beg
            return :DO_BLOCK, scanner.matched
          elsif @lex_state == :expr_endarg
            return :DO_BLOCK, scanner.matched
          else
            @lex_state = :expr_beg
            return :DO, scanner.matched
          end

        when 'if'
          return :IF, scanner.matched if @lex_state == :expr_beg
          @lex_state = :expr_beg
          return :IF_MOD, scanner.matched

        when 'unless'
          return :UNLESS, scanner.matched if @lex_state == :expr_beg
          return :UNLESS_MOD, scanner.matched

        when 'else'
          return :ELSE, scanner.matched

        when 'elsif'
          return :ELSIF, scanner.matched

        when 'self'
          @lex_state = :expr_end unless @lex_state == :expr_fname
          return :SELF, scanner.matched

        when 'true'
          @lex_state = :expr_end
          return :TRUE, scanner.matched

        when 'false'
          @lex_state = :expr_end
          return :FALSE, scanner.matched

        when 'nil'
          @lex_state = :expr_end
          return :NIL, scanner.matched

        when '__LINE__'
          @lex_state = :expr_end
          return :LINE, @line_number.to_s

        when '__FILE__'
          @lex_state = :expr_end
          return :FILE, scanner.matched

        when 'begin'
          if [:expr_dot, :expr_fname].include? @lex_state
            @lex_state = :expr_end
            return :IDENTIFIER, scanner.matched
          end
          @lex_state = :expr_beg
          return :BEGIN, scanner.matched

        when 'rescue'
          return :IDENTIFIER, scanner.matched if [:expr_dot, :expr_fname].include? @lex_state
          return :RESCUE, scanner.matched if @lex_state == :expr_beg
          @lex_state = :expr_beg
          return :RESCUE_MOD, scanner.matched

        when 'ensure'
          @lex_state = :expr_beg
          return :ENSURE, scanner.matched

        when 'case'
          @lex_state = :expr_beg
          return :CASE, scanner.matched

        when 'when'
          @lex_state = :expr_beg
          return :WHEN, scanner.matched

        when 'or'
          @lex_state = :expr_beg
          return :OR, scanner.matched

        when 'and'
          @lex_state = :expr_beg
          return :AND, scanner.matched

        when 'not'
          @lex_state = :expr_beg
          return :NOT, scanner.matched

        when 'return'
          @lex_state = :expr_mid
          return :RETURN, scanner.matched

        when 'next'
          if @lex_state == :expr_dot || @lex_state == :expr_fname
            @lex_state = :expr_end
            return :IDENTIFIER, scanner.matched
          end

          @lex_state = :expr_mid
          return :NEXT, scanner.matched

        when 'redo'
          if @lex_state == :expr_dot || @lex_state == :expr_fname
            @lex_state = :expr_end
            return :IDENTIFIER, scanner.matched
          end

          @lex_state = :expr_mid
          return :REDO, scanner.matched

        when 'break'
          @lex_state = :expr_mid
          return :BREAK, scanner.matched

        when 'super'
          @lex_state = :expr_arg
          return :SUPER, scanner.matched

        when 'then'
          return :THEN, scanner.matched

        when 'while'
          return :WHILE, scanner.matched if @lex_state == :expr_beg
          @lex_state = :expr_beg
          return :WHILE_MOD, scanner.matched

        when 'until'
          return :WHILE, scanner.matched if @lex_state == :expr_beg
          @lex_state = :expr_beg
          return :UNTIL_MOD, scanner.matched

        when 'block_given?'
          @lex_state = :expr_end
          return :BLOCK_GIVEN, scanner.matched

        when 'yield'
          @lex_state = :expr_arg
          return :YIELD, scanner.matched
        end

        matched = scanner.matched
        return :LABEL, matched if scanner.peek(2) != '::' && scanner.scan(/\:/)

        if @lex_state == :expr_fname
          if scanner.scan(/\=/)
            @lex_state = :expr_end
            return :IDENTIFIER, matched + scanner.matched
          end
        end

        if [:expr_beg, :expr_dot, :expr_mid, :expr_arg, :expr_cmdarg].include? @lex_state
          @lex_state = :expr_cmdarg
        else
          @lex_state = :expr_end
        end

        return [matched =~ /[A-Z]/ ? :CONSTANT : :IDENTIFIER, matched]

      end
      return [false, false] if scanner.eos?

      raise RubyLexingError, "Unexpected content in parsing stream `#{scanner.peek 5}`"
    end
  end
end
  end
