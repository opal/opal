require 'opal/core_ext'
require 'opal/grammar'
require 'opal/grammar_helpers'
require 'opal/lexer_scope'
require 'strscan'

module Opal

  class Grammar < Racc::Parser

    attr_reader :line

    def initialize
      @lex_state  = :expr_beg
      @cond       = 0
      @cmdarg     = 0
      @line       = 1
      @scopes     = []

      @string_parse_stack = []
    end

    def s(*parts)
      sexp = Sexp.new(parts)
      sexp.line = @line
      sexp
    end

    def parse(source, file = '(string)')
      @file = file
      @scanner = StringScanner.new source
      push_scope
      result = do_parse
      pop_scope

      result
    end

    def on_error(t, val, vstack)
      raise "parse error on value #{val.inspect} (#{token_to_str(t) || '?'}) :#{@file}:#{@line}"
    end

    def push_scope(type = nil)
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

    def arg?
      [:expr_arg, :expr_cmdarg].include? @lex_state
    end

    def end?
      [:expr_end, :expr_endarg, :expr_endfn].include? @lex_state
    end

    def beg?
      [:expr_beg, :expr_value, :expr_mid, :expr_class].include? @lex_state
    end

    def after_operator?
      [:expr_fname, :expr_dot].include? @lex_state
    end

    def spcarg?
      arg? and @space_seen and !space?
    end

    def space?
      @scanner.check(/\s/)
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

        if str_parse[:balance]
          if str_parse[:nesting] == 0
            @lex_state = :expr_end

            if str_parse[:regexp]
              result = scanner.scan(/\w+/)
              return :REGEXP_END, result
            end
            return :STRING_END, scanner.matched
          else
            str_buffer << scanner.matched
            str_parse[:nesting] -= 1
            @string_parse = str_parse
          end

        elsif ['"', "'"].include? str_parse[:beg]
          @lex_state = :expr_end
          return :STRING_END, scanner.matched

        elsif str_parse[:beg] == '`'
          @lex_state = :expr_end
          return :STRING_END, scanner.matched

        elsif str_parse[:beg] == '/' || str_parse[:regexp]
          result = scanner.scan(/\w+/)
          @lex_state = :expr_end
          return :REGEXP_END, result

        else
          @lex_state = :expr_end
          return :STRING_END, scanner.matched
        end
      end

      return :SPACE, ' ' if space

      if str_parse[:balance] and scanner.scan Regexp.new(Regexp.escape(str_parse[:beg]))
        str_buffer << scanner.matched
        str_parse[:nesting] += 1
      elsif scanner.check(/#[@$]/)
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
      @line += complete_str.count("\n")
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

        elsif interpolate && scanner.check(/#(?=[\$\@\{])/)
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
            elsif scanner.scan(/r/)
              "\r"
            elsif scanner.scan(/\n/)
              "\n"
            elsif scanner.scan(/t/)
              "\t"
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
                  Regexp.new("[^#{Regexp.escape str_parse[:end]}#{Regexp.escape str_parse[:beg]}\#\0\\\\]+|.")
                else
                  Regexp.new("[^#{Regexp.escape str_parse[:end]}\#\0\\\\]+|.")
                end

          scanner.scan reg
          c = scanner.matched
        end

        c ||= scanner.matched
        str_buffer << c
      end

      raise "reached EOF while in string" if scanner.eos?
    end

    def next_token
      # if we are trying to parse a string, then delegate to that
      return next_string_token if @string_parse

      # scanner, @space_seen, cmd_start, c = @scanner, false, false, ''
      scanner = @scanner
      @space_seen = false
      cmd_start = false
      c = ''

      while true
        if scanner.scan(/\ |\t|\r/)
          @space_seen = true
          next

        elsif scanner.scan(/(\n|#)/)
          c = scanner.matched
          if c == '#' then scanner.scan(/(.*)/) else @line += 1; end

          scanner.scan(/(\n+)/)
          @line += scanner.matched.length if scanner.matched

          next if [:expr_beg, :expr_dot].include? @lex_state

          if scanner.scan(/([\ \t\r\f\v]*)\./)
            @space_seen = true unless scanner[1].empty?
            scanner.pos = scanner.pos - 1

            next unless scanner.check(/\.\./)
          end

          cmd_start = true
          @lex_state = :expr_beg
          return '\\n', '\\n'

        elsif scanner.scan(/\;/)
          @lex_state = :expr_beg
          return ';', ';'

        elsif scanner.scan(/\*/)
          if scanner.scan(/\*/)
            if scanner.scan(/\=/)
              @lex_state = :expr_beg
              return :OP_ASGN, '**'
            end

            if @lex_state == :expr_fname or @lex_state == :expr_dot
              @lex_state = :expr_arg
            else
              @lex_state = :expr_beg
            end

            return '**', '**'

          else
            if scanner.scan(/\=/)
              @lex_state = :expr_beg
              return :OP_ASGN, '*'
            end
          end

          if scanner.scan(/\*\=/)
            @lex_state = :expr_beg
            return :OP_ASGN, '**'
          end

          if scanner.scan(/\*/)
            if after_operator?
              @lex_state = :expr_arg
            else
              @lex_state = :expr_beg
            end

            return '**', '**'
          end

          if scanner.scan(/\=/)
            @lex_state = :expr_beg
            return :OP_ASGN, '*'
          else
            result = '*'
            if @lex_state == :expr_fname
              @lex_state = :expr_end
              return '*', result
            elsif @space_seen && scanner.check(/\S/)
              @lex_state = :expr_beg
              return :SPLAT, result
            elsif [:expr_beg, :expr_mid].include? @lex_state
              @lex_state = :expr_beg
              return :SPLAT, result
            else
              @lex_state = :expr_beg
              return '*', result
            end
          end

        elsif scanner.scan(/\!/)
          c = scanner.scan(/./)
          if after_operator?
            @lex_state = :expr_arg
            if c == "@"
              return '!', '!'
            end
          else
            @lex_state = :expr_beg
          end

          if c == '='
            return '!=', '!='
          elsif c == '~'
            return '!~', '!~'
          end

          scanner.pos = scanner.pos - 1
          return '!', '!'

        elsif scanner.scan(/\=/)
          if @lex_state == :expr_beg and !@space_seen
            if scanner.scan(/begin/) and space?
              scanner.scan(/(.*)/) # end of line

              while true
                if scanner.eos?
                  raise "embedded document meets end of file"
                end

                if scanner.scan(/\=end/) and space?
                  return next_token
                end

                if scanner.scan(/\n/)
                  next
                end

                scanner.scan(/(.*)/)
              end
            end
          end

          @lex_state = if after_operator?
                         :expr_arg
                       else
                         :expr_beg
                       end

          if scanner.scan(/\=/)
            if scanner.scan(/\=/)
              return '===', '==='
            end

            return '==', '=='
          end

          if scanner.scan(/\~/)
            return '=~', '=~'
          elsif scanner.scan(/\>/)
            return '=>', '=>'
          end

          return '=', '='

        elsif scanner.scan(/\"/)
          @string_parse = { :beg => '"', :end => '"', :interpolate => true }
          return :STRING_BEG, scanner.matched

        elsif scanner.scan(/\'/)
          @string_parse = { :beg => "'", :end => "'" }
          return :STRING_BEG, scanner.matched

        elsif scanner.scan(/\`/)
          @string_parse = { :beg => "`", :end => "`", :interpolate => true }
          return :XSTRING_BEG, scanner.matched

        elsif scanner.scan(/\&/)
          if scanner.scan(/\&/)
            @lex_state = :expr_beg

            if scanner.scan(/\=/)
              return :OP_ASGN, '&&'
            end

            return '&&', '&&'

          elsif scanner.scan(/\=/)
            @lex_state = :expr_beg
            return :OP_ASGN, '&'
          end

          if spcarg?
            #puts "warning: `&' interpreted as argument prefix"
            result = '&@'
          elsif beg?
            result = '&@'
          else
            #puts "warn_balanced: & argument prefix"
            result = '&'
          end

          @lex_state = after_operator? ? :expr_arg : :expr_beg
          return result, '&'

        elsif scanner.scan(/\|/)
          if scanner.scan(/\|/)
            @lex_state = :expr_beg
            if scanner.scan(/\=/)
              return :OP_ASGN, '||'
            end

            return '||', '||'

          elsif scanner.scan(/\=/)
            return :OP_ASGN, '|'
          end

          @lex_state = after_operator?() ? :expr_arg : :expr_beg
          return '|', '|'

        elsif scanner.scan(/\%W/)
          start_word  = scanner.scan(/./)
          end_word    = { '(' => ')', '[' => ']', '{' => '}' }[start_word] || start_word
          @string_parse = { :beg => 'W', :end => end_word, :interpolate => true }
          scanner.scan(/\s*/)
          return :WORDS_BEG, scanner.matched

        elsif scanner.scan(/\%w/) or scanner.scan(/\%i/)
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

        elsif scanner.scan(/\%r/)
          start_word = scanner.scan(/./)
          end_word   = { '(' => ')', '[' => ']', '{' => '}' }[start_word] || start_word
          @string_parse = { :beg => start_word, :end => end_word, :regexp => true, :balance => true, :nesting => 0, :interpolate => true }
          return :REGEXP_BEG, scanner.matched

        elsif scanner.scan(/\//)
          if [:expr_beg, :expr_mid].include? @lex_state
            @string_parse = { :beg => '/', :end => '/', :interpolate => true, :regexp => true }
            return :REGEXP_BEG, scanner.matched
          elsif scanner.scan(/\=/)
            @lex_state = :expr_beg
            return :OP_ASGN, '/'
          elsif @lex_state == :expr_fname
            @lex_state = :expr_end
          elsif @lex_state == :expr_cmdarg || @lex_state == :expr_arg
            if !scanner.check(/\s/) && @space_seen
              @string_parse = { :beg => '/', :end => '/', :interpolate => true, :regexp => true }
              return :REGEXP_BEG, scanner.matched
            end
          else
            @lex_state = :expr_beg
          end

          return '/', '/'

        elsif scanner.scan(/\%/)
          if scanner.scan(/\=/)
            @lex_state = :expr_beg
            return :OP_ASGN, '%'
          elsif scanner.check(/[^\s]/)
            if @lex_state == :expr_beg or (@lex_state == :expr_arg && @space_seen)
              interpolate = true
              start_word  = scanner.scan(/./)
              end_word    = { '(' => ')', '[' => ']', '{' => '}' }[start_word] || start_word
              @string_parse = { :beg => start_word, :end => end_word, :balance => true, :nesting => 0, :interpolate => interpolate }
              return :STRING_BEG, scanner.matched
            end
          end

          @lex_state = after_operator? ? :expr_arg : :expr_beg

          return '%', '%'

        elsif scanner.scan(/\\/)
          if scanner.scan(/\r?\n/)
            @space_seen = true
            next
          end

          raise SyntaxError, "backslash must appear before newline :#{@file}:#{@line}"

        elsif scanner.scan(/\(/)
          result = scanner.matched
          if [:expr_beg, :expr_mid].include? @lex_state
            result = :PAREN_BEG
          elsif @space_seen && [:expr_arg, :expr_cmdarg].include?(@lex_state)
            result = :tLPAREN_ARG
          else
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
          elsif [:expr_beg, :expr_mid].include?(@lex_state) || @space_seen
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

        elsif scanner.scan(/\:\:/)
          if [:expr_beg, :expr_mid, :expr_class].include? @lex_state
            @lex_state = :expr_beg
            return '::@', scanner.matched
          elsif @space_seen && @lex_state == :expr_arg
            @lex_state = :expr_beg
            return '::@', scanner.matched
          end

          @lex_state = :expr_dot
          return '::', scanner.matched

        elsif scanner.scan(/\:/)
          if end? || scanner.check(/\s/)
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

        elsif scanner.scan(/\^\=/)
          @lex_state = :expr_beg
          return :OP_ASGN, '^'
        elsif scanner.scan(/\^/)
          if @lex_state == :expr_fname
            @lex_state = :expr_end
            return '^', scanner.matched
          end

          @lex_state = :expr_beg
          return '^', scanner.matched

        elsif scanner.check(/\</)
          if scanner.scan(/\<\<\=/)
            @lex_state = :expr_beg
            return :OP_ASGN, '<<'
          elsif scanner.scan(/\<\</)
            if @lex_state == :expr_fname
              @lex_state = :expr_end
              return '<<', '<<'
            elsif ![:expr_end, :expr_dot, :expr_endarg, :expr_class].include?(@lex_state) && @space_seen
              if scanner.scan(/(-?)['"]?(\w+)['"]?/)
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
            if after_operator?
              @lex_state = :expr_arg
            else
              if @lex_state == :expr_class
                cmd_start = true
              end

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
            if @lex_state == :expr_fname or @lex_state == :expr_dot
              @lex_state = :expr_arg
            else
              @lex_state = :expr_beg
            end
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
              @lex_state = :expr_arg
            else
              @lex_state = :expr_beg
            end
            return '>', '>'
          end

        elsif scanner.scan(/->/)
          # FIXME: # should be :expr_arg, but '(' breaks it...
          @lex_state = :expr_end
          @start_of_lambda = true
          return [:LAMBDA, scanner.matched]

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

          if @lex_state == :expr_cmdarg || @lex_state == :expr_arg
            if !scanner.check(/\s/) && @space_seen
              @lex_state = :expr_mid
              return [sign, sign]
            end
          end

          @lex_state = :expr_beg
          return [result, result]

        elsif scanner.scan(/\?/)
          if end?
            @lex_state = :expr_beg
            return '?', scanner.matched
          end

          unless scanner.check(/\ |\t|\r|\s/)
            @lex_state = :expr_end
            return :STRING, scanner.scan(/./)
          end

          @lex_state = :expr_beg
          return '?', scanner.matched

        elsif scanner.scan(/\~/)
          if @lex_state == :expr_fname
            @lex_state = :expr_end
            return '~', '~'
          end
          @lex_state = :expr_beg
          return '~', '~'

        elsif scanner.check(/\$/)
          if scanner.scan(/\$([1-9]\d*)/)
            @lex_state = :expr_end
            return :NTH_REF, scanner.matched.sub('$', '')

          elsif scanner.scan(/(\$_)(\w+)/)
            @lex_state = :expr_end
            return :GVAR, scanner.matched

          elsif scanner.scan(/\$[\+\'\`\&!@\"~*$?\/\\:;=.,<>_]/)
            @lex_state = :expr_end
            return :GVAR, scanner.matched
          elsif scanner.scan(/\$\w+/)
            @lex_state = :expr_end
            return :GVAR, scanner.matched
          else
            raise "Bad gvar name: #{scanner.peek(5).inspect}"
          end

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
          if @start_of_lambda
            @start_of_lambda = false
            @lex_state = :expr_beg
            return [:LAMBEG, scanner.matched]

          elsif [:expr_end, :expr_arg, :expr_cmdarg].include? @lex_state
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
          if scanner.scan(/0b?(0|1|_)+/)
            return [:INTEGER, scanner.matched.to_i(2)]
          elsif scanner.scan(/0o?([0-7]|_)+/)
            return [:INTEGER, scanner.matched.to_i(8)]
          elsif scanner.scan(/[\d_]+\.[\d_]+\b|[\d_]+(\.[\d_]+)?[eE][-+]?[\d_]+\b/)
            return [:FLOAT, scanner.matched.gsub(/_/, '').to_f]
          elsif scanner.scan(/[\d_]+\b/)
            return [:INTEGER, scanner.matched.gsub(/_/, '').to_i]
          elsif scanner.scan(/0(x|X)(\d|[a-f]|[A-F]|_)+/)
            return [:INTEGER, scanner.matched.to_i(16)]
          else
            raise "Lexing error on numeric type: `#{scanner.peek 5}`"
          end

        elsif scanner.scan(/(\w)+[\?\!]?/)
          matched = scanner.matched

          if scanner.peek(2) != '::' && scanner.scan(/:/)
            @lex_state = :expr_beg
            return :LABEL, "#{matched}"
          end

          if matched == 'self'
            if @lex_state == :expr_dot
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_end unless @lex_state == :expr_fname
            return :SELF, matched
          end

          if @lex_state == :expr_fname
            if scanner.scan(/\=/)
              @lex_state = :expr_end
              return :IDENTIFIER, matched + scanner.matched
            end
          end

          case matched
          when 'class'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_class
            return :CLASS, matched

          when 'module'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_class
            return :MODULE, matched

          when 'defined?'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_arg
            return :DEFINED, 'defined?'

          when 'def'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_fname
            @scope_line = @line
            return :DEF, matched

          when 'undef'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_fname
            return :UNDEF, matched

          when 'end'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_end
            return :END, matched

          when 'do'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            if @start_of_lambda
              @start_of_lambda = false
              @lex_state = :expr_beg
              return [:DO_LAMBDA, scanner.matched]
            elsif cond?
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
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            return :IF, matched if @lex_state == :expr_beg
            @lex_state = :expr_beg
            return :IF_MOD, matched

          when 'unless'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            return :UNLESS, matched if @lex_state == :expr_beg
            @lex_state = :expr_beg
            return :UNLESS_MOD, matched

          when 'else'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            return :ELSE, matched

          when 'elsif'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            return :ELSIF, matched

          when 'true'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_end
            return :TRUE, matched

          when 'false'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_end
            return :FALSE, matched

          when 'nil'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_end
            return :NIL, matched

          when '__LINE__'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_end
            return :LINE, @line.to_s

          when '__FILE__'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_end
            return :FILE, matched

          when 'begin'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_beg
            return :BEGIN, matched

          when 'rescue'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            if @lex_state == :expr_beg
              @lex_state = :expr_mid
              return :RESCUE, matched
            end

            @lex_state = :expr_beg
            return :RESCUE_MOD, matched

          when 'ensure'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_beg
            return :ENSURE, matched

          when 'case'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_beg
            return :CASE, matched

          when 'when'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_beg
            return :WHEN, matched

          when 'or'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_beg
            return :OR, matched

          when 'and'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_beg
            return :AND, matched

          when 'not'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_arg
            return :NOT, matched

          when 'return'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_mid
            return :RETURN, matched

          when 'next'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_mid
            return :NEXT, matched

          when 'redo'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_mid
            return :REDO, matched

          when 'break'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_mid
            return :BREAK, matched

          when 'super'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_arg
            return :SUPER, matched

          when 'then'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_beg
            return :THEN, matched

          when 'while'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            return :WHILE, matched if @lex_state == :expr_beg
            @lex_state = :expr_beg
            return :WHILE_MOD, matched

          when 'until'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            return :UNTIL, matched if @lex_state == :expr_beg
            @lex_state = :expr_beg
            return :UNTIL_MOD, matched

          when 'yield'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_arg
            return :YIELD, matched

          when 'alias'
            if after_operator?
              @lex_state = :expr_end
              return :IDENTIFIER, matched
            end

            @lex_state = :expr_fname
            return :ALIAS, matched
          end

          if @lex_state == :expr_fname
            if scanner.scan(/\=/)
              @lex_state = :expr_end
              return :IDENTIFIER, matched + scanner.matched
            end
          end

          if [:expr_beg, :expr_dot, :expr_mid, :expr_arg, :expr_cmdarg].include? @lex_state
            @lex_state = cmd_start ? :expr_cmdarg : :expr_arg
          else
            @lex_state = :expr_end
          end

          return [matched =~ /^[A-Z]/ ? :CONSTANT : :IDENTIFIER, matched]

        end
        return [false, false] if scanner.eos?

        raise "Unexpected content in parsing stream `#{scanner.peek 5}` :#{@file}:#{@line}"
      end
    end
  end
end
