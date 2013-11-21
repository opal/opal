require 'strscan'
require 'opal/parser/keywords'

module Opal
  class Lexer

    attr_reader :line, :scope_line, :scope

    attr_accessor :lex_state, :strterm, :scanner

    def initialize(source, file)
      @lex_state  = :expr_beg
      @cond       = 0
      @cmdarg     = 0
      @line       = 1
      @file       = file

      @scanner = StringScanner.new(source)
      @scanner_stack = [@scanner]
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

    def set_arg_state
      @lex_state = after_operator? ? :expr_arg : :expr_beg
    end

    def scan(regexp)
      @scanner.scan regexp
    end

    def check(regexp)
      @scanner.check regexp
    end

    def pushback(n)
      @scanner.pos -= 1
    end

    def matched
      @scanner.matched
    end

    def next_token
      self.yylex
    end

    def strterm_expand?(strterm)
      type = strterm[:type]

      [:dquote, :dsym, :dword, :heredoc, :xquote, :regexp].include? type
    end

    def new_strterm(type, start, finish)
      { :type => type, :beg => start, :end => finish }
    end

    def new_strterm2(type, start, finish)
      term = new_strterm(type, start, finish)
      term.merge({ :balance => true, :nesting => 0 })
    end

    def process_numeric
      @lex_state = :expr_end
      scanner = @scanner

      if scan(/0b?(0|1|_)+/)
        return [:tINTEGER, scanner.matched.to_i(2)]
      elsif scan(/0o?([0-7]|_)+/)
        return [:tINTEGER, scanner.matched.to_i(8)]
      elsif scan(/[\d_]+\.[\d_]+\b|[\d_]+(\.[\d_]+)?[eE][-+]?[\d_]+\b/)
        return [:tFLOAT, scanner.matched.gsub(/_/, '').to_f]
      elsif scan(/[\d_]+\b/)
        return [:tINTEGER, scanner.matched.gsub(/_/, '').to_i]
      elsif scan(/0(x|X)(\d|[a-f]|[A-F]|_)+/)
        return [:tINTEGER, scanner.matched.to_i(16)]
      else
        raise "Lexing error on numeric type: `#{scanner.peek 5}`"
      end
    end

    def next_string_token
      str_parse = self.strterm
      scanner = @scanner
      space = false

      expand = strterm_expand?(str_parse)

      words = ['w', 'W'].include? str_parse[:beg]

      space = true if ['w', 'W'].include?(str_parse[:beg]) and scan(/\s+/)

      # if not end of string, so we must be parsing contents
      str_buffer = []

      if str_parse[:type] == :heredoc
        eos_regx = /[ \t]*#{Regexp.escape(str_parse[:end])}(\r*\n|$)/

        if check(eos_regx)
          scan(/[ \t]*#{Regexp.escape(str_parse[:end])}/)
          self.strterm = nil

          if str_parse[:scanner]
            @scanner_stack << str_parse[:scanner]
            @scanner = str_parse[:scanner]
          end

          @lex_state = :expr_end
          return :tSTRING_END, scanner.matched
        end
      end

      # see if we can read end of string/xstring/regexp markers
      # if scan /#{str_parse[:end]}/
      if scan Regexp.new(Regexp.escape(str_parse[:end]))
        if words && !str_parse[:done_last_space]#&& space
          str_parse[:done_last_space] = true
          pushback(1)
          return :tSPACE, ' '
        end
        self.strterm = nil

        if str_parse[:balance]
          if str_parse[:nesting] == 0
            @lex_state = :expr_end

            if str_parse[:type] == :regexp
              result = scan(/\w+/)
              return :tREGEXP_END, result
            end
            return :tSTRING_END, scanner.matched
          else
            str_buffer << scanner.matched
            str_parse[:nesting] -= 1
            self.strterm = str_parse
          end

        elsif ['"', "'"].include? str_parse[:beg]
          @lex_state = :expr_end
          return :tSTRING_END, scanner.matched

        elsif str_parse[:beg] == '`'
          @lex_state = :expr_end
          return :tSTRING_END, scanner.matched

        elsif str_parse[:beg] == '/' || str_parse[:type] == :regexp
          result = scan(/\w+/)
          @lex_state = :expr_end
          return :tREGEXP_END, result

        else
          if str_parse[:scanner]
            @scanner_stack << str_parse[:scanner]
            @scanner = str_parse[:scanner]
          end

          @lex_state = :expr_end
          return :tSTRING_END, scanner.matched
        end
      end

      return :tSPACE, ' ' if space

      if str_parse[:balance] and scan Regexp.new(Regexp.escape(str_parse[:beg]))
        str_buffer << scanner.matched
        str_parse[:nesting] += 1
      elsif check(/#[@$]/)
        scan(/#/)
        if expand
          return :tSTRING_DVAR, scanner.matched
        else
          str_buffer << scanner.matched
        end

      elsif scan(/#\{/)
        if expand
          # we are into ruby code, so stop parsing content (for now)
          return :tSTRING_DBEG, scanner.matched
        else
          str_buffer << scanner.matched
        end

      # causes error, so we will just collect it later on with other text
      elsif scan(/\#/)
        str_buffer << '#'
      end

      if str_parse[:type] == :heredoc
        add_heredoc_content str_buffer, str_parse
      else
        add_string_content str_buffer, str_parse
      end

      complete_str = str_buffer.join ''
      @line += complete_str.count("\n")
      return :tSTRING_CONTENT, complete_str
    end

    def add_heredoc_content(str_buffer, str_parse)
      scanner = @scanner

      eos_regx = /[ \t]*#{Regexp.escape(str_parse[:end])}(\r*\n|$)/
      expand = true

      until scanner.eos?
        c = nil
        handled = true

        if scan(/\n/)
          c = scanner.matched
        elsif check(eos_regx) && scanner.bol?
          break # eos!
        elsif expand && check(/#(?=[\$\@\{])/)
          break
        elsif scan(/\\/)
          if str_parse[:type] == :regexp
            if scan(/(.)/)
              c = "\\" + scanner.matched
            end
          else
            c = if scan(/n/)
              "\n"
            elsif scan(/r/)
              "\r"
            elsif scan(/\n/)
              "\n"
            elsif scan(/t/)
              "\t"
            else
              # escaped char doesnt need escaping, so just return it
              scan(/./)
              scanner.matched
            end
          end
        else
          handled = false
        end

        unless handled
          reg = Regexp.new("[^#{Regexp.escape str_parse[:end]}\#\0\\\\\n]+|.")

          scan reg
          c = scanner.matched
        end

        c ||= scanner.matched
        str_buffer << c
      end

      raise "reached EOF while in string" if scanner.eos?
    end

    def add_string_content(str_buffer, str_parse)
      scanner = @scanner
      # regexp for end of string/regexp
      # end_str_re = /#{str_parse[:end]}/
      end_str_re = Regexp.new(Regexp.escape(str_parse[:end]))

      expand = strterm_expand?(str_parse)

      words = ['W', 'w'].include? str_parse[:beg]

      until scanner.eos?
        c = nil
        handled = true

        if check end_str_re
          # eos
          # if its just balancing, add it ass normal content..
          if str_parse[:balance] && (str_parse[:nesting] != 0)
            # we only checked above, so actually scan it
            scan end_str_re
            c = scanner.matched
            str_parse[:nesting] -= 1
          else
            # not balancing, so break (eos!)
            break
          end

        elsif str_parse[:balance] and scan Regexp.new(Regexp.escape(str_parse[:beg]))
          str_parse[:nesting] += 1
          c = scanner.matched

        elsif words && scan(/\s/)
          pushback(1)
          break

        elsif expand && check(/#(?=[\$\@\{])/)
          break

        #elsif scan(/\\\\/)
          #c = scanner.matched

        elsif scan(/\\/)
          if str_parse[:type] == :regexp
            if scan(/(.)/)
              c = "\\" + scanner.matched
            end
          else
            c = if scan(/n/)
              "\n"
            elsif scan(/r/)
              "\r"
            elsif scan(/\n/)
              "\n"
            elsif scan(/t/)
              "\t"
            else
              # escaped char doesnt need escaping, so just return it
              scan(/./)
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

          scan reg
          c = scanner.matched
        end

        c ||= scanner.matched
        str_buffer << c
      end

      raise "reached EOF while in string" if scanner.eos?
    end

    def heredoc_identifier
      if @scanner.scan(/(-?)['"]?(\w+)['"]?/)
        heredoc = @scanner[2]
        self.strterm = new_strterm(:heredoc, heredoc, heredoc)

        # if ruby code at end of line after heredoc, we have to store it to
        # parse after heredoc is finished parsing
        end_of_line = @scanner.scan(/.*\n/)
        self.strterm[:scanner] = StringScanner.new(end_of_line) if end_of_line != "\n"

        return :tSTRING_BEG, heredoc
      end
    end

    def process_identifier(matched, cmd_start)
      scanner = @scanner
      matched = scanner.matched

      if scanner.peek(2) != '::' && scan(/:/)
        @lex_state = :expr_beg
        return :tLABEL, "#{matched}"
      end

      if matched == 'defined?'
        if after_operator?
          @lex_state = :expr_end
          return :tIDENTIFIER, matched
        end

        @lex_state = :expr_arg
        return :kDEFINED, 'defined?'
      end

      if matched.end_with? '?', '!'
        result = :tIDENTIFIER
      else
        if @lex_state == :expr_fname
          if scan(/\=/)
            result = :tIDENTIFIER
            matched += scanner.matched
          end

        elsif matched =~ /^[A-Z]/
          result = :tCONSTANT
        else
          result = :tIDENTIFIER
        end
      end

      if @lex_state != :expr_dot and kw = Keywords.keyword(matched)
        old_state = @lex_state
        @lex_state = kw.state

        if old_state == :expr_fname
          return [kw.id[0], kw.name]
        end

        if @lex_state == :expr_beg
          cmd_start = true
        end

        if matched == "do"
          if after_operator?
            @lex_state = :expr_end
            return :tIDENTIFIER, matched
          end

          if @start_of_lambda
            @start_of_lambda = false
            @lex_state = :expr_beg
            return [:kDO_LAMBDA, scanner.matched]
          elsif cond?
            @lex_state = :expr_beg
            return :kDO_COND, matched
          elsif cmdarg? && @lex_state != :expr_cmdarg
            @lex_state = :expr_beg
            return :kDO_BLOCK, matched
          elsif @lex_state == :expr_endarg
            return :kDO_BLOCK, matched
          else
            @lex_state = :expr_beg
            return :kDO, matched
          end
        else
          if old_state == :expr_beg or old_state == :expr_value
            return [kw.id[0], matched]
          else
            if kw.id[0] != kw.id[1]
              @lex_state = :expr_beg
            end

            return [kw.id[1], matched]
          end
        end
      end

      if [:expr_beg, :expr_dot, :expr_mid, :expr_arg, :expr_cmdarg].include? @lex_state
        @lex_state = cmd_start ? :expr_cmdarg : :expr_arg
      else
        @lex_state = :expr_end
      end

      return [matched =~ /^[A-Z]/ ? :tCONSTANT : :tIDENTIFIER, matched]
    end

    def yylex
      @space_seen = false
      cmd_start = false
      c = ''

      if self.strterm
        return next_string_token
      end

      while true
        if scan(/\ |\t|\r/)
          @space_seen = true
          next

        elsif scan(/(\n|#)/)
          c = scanner.matched
          if c == '#' then scan(/(.*)/) else @line += 1; end

          scan(/(\n+)/)
          @line += scanner.matched.length if scanner.matched

          next if [:expr_beg, :expr_dot].include? @lex_state

          if scan(/([\ \t\r\f\v]*)\./)
            @space_seen = true unless scanner[1].empty?
            scanner.pos = scanner.pos - 1

            next unless check(/\.\./)
          end

          cmd_start = true
          @lex_state = :expr_beg
          return :tNL, '\\n'

        elsif scan(/\;/)
          @lex_state = :expr_beg
          return :tSEMI, ';'

        elsif scan(/\*/)
          if scan(/\*/)
            if scan(/\=/)
              @lex_state = :expr_beg
              return :tOP_ASGN, '**'
            end

            self.set_arg_state
            return :tPOW, '**'

          else
            if scan(/\=/)
              @lex_state = :expr_beg
              return :tOP_ASGN, '*'
            end
          end

          if scan(/\*\=/)
            @lex_state = :expr_beg
            return :tOP_ASGN, '**'
          end

          if scan(/\*/)
            self.set_arg_state
            return :tPOW, '**'
          end

          if scan(/\=/)
            @lex_state = :expr_beg
            return :tOP_ASGN, '*'
          else
            result = '*'

            if after_operator?
              @lex_state = :expr_arg
              return :tSTAR2, result
            elsif @space_seen && check(/\S/)
              @lex_state = :expr_beg
              return :tSTAR, result
            elsif [:expr_beg, :expr_mid].include? @lex_state
              @lex_state = :expr_beg
              return :tSTAR, result
            else
              @lex_state = :expr_beg
              return :tSTAR2, result
            end
          end

        elsif scan(/\!/)
          c = scan(/./)
          if after_operator?
            @lex_state = :expr_arg
            if c == "@"
              return :tBANG, '!'
            end
          else
            @lex_state = :expr_beg
          end

          if c == '='
            return :tNEQ, '!='
          elsif c == '~'
            return :tNMATCH, '!~'
          end

          scanner.pos = scanner.pos - 1
          return :tBANG, '!'

        elsif scan(/\=/)
          if @lex_state == :expr_beg and !@space_seen
            if scan(/begin/) and space?
              scan(/(.*)/) # end of line
              line_count = 0

              while true
                if scanner.eos?
                  raise "embedded document meets end of file"
                end

                if scan(/\=end/) and space?
                  @line += line_count
                  return next_token
                end

                if scan(/\n/)
                  line_count += 1
                  next
                end

                scan(/(.*)/)
              end
            end
          end

          self.set_arg_state

          if scan(/\=/)
            if scan(/\=/)
              return :tEQQ, '==='
            end

            return :tEQ, '=='
          end

          if scan(/\~/)
            return :tMATCH, '=~'
          elsif scan(/\>/)
            return :tASSOC, '=>'
          end

          return :tEQL, '='

        elsif scan(/\"/)
          self.strterm = new_strterm(:dquote, '"', '"')
          return :tSTRING_BEG, scanner.matched

        elsif scan(/\'/)
          self.strterm = new_strterm(:squote, "'", "'")
          return :tSTRING_BEG, scanner.matched

        elsif scan(/\`/)
          self.strterm = new_strterm(:xquote, '`', '`')
          return :tXSTRING_BEG, scanner.matched

        elsif scan(/\&/)
          if scan(/\&/)
            @lex_state = :expr_beg

            if scan(/\=/)
              return :tOP_ASGN, '&&'
            end

            return :tANDOP, '&&'

          elsif scan(/\=/)
            @lex_state = :expr_beg
            return :tOP_ASGN, '&'
          end

          if spcarg?
            #puts "warning: `&' interpreted as argument prefix"
            result = :tAMPER
          elsif beg?
            result = :tAMPER
          else
            #puts "warn_balanced: & argument prefix"
            result = :tAMPER2
          end

          self.set_arg_state
          return result, '&'

        elsif scan(/\|/)
          if scan(/\|/)
            @lex_state = :expr_beg
            if scan(/\=/)
              return :tOP_ASGN, '||'
            end

            return :tOROP, '||'

          elsif scan(/\=/)
            return :tOP_ASGN, '|'
          end

          self.set_arg_state
          return :tPIPE, '|'

        elsif scan(/\%[QqWwixr]/)
          str_type = scanner.matched[1, 1]
          paren = scan(/./)

          term = case paren
                 when '(' then ')'
                 when '[' then ']'
                 when '{' then '}'
                 else paren
                 end

          case str_type
          when 'Q'
            self.strterm = new_strterm2(:dquote, paren, term)
            return :tSTRING_BEG, scanner.matched
          when 'q'
            self.strterm = new_strterm2(:squote, paren, term)
            return :tSTRING_BEG, scanner.matched
          when 'W'
            self.strterm = new_strterm(:dword, 'W', term)
            scan(/\s*/)
            return :tWORDS_BEG, scanner.matched
          when 'w', 'i'
            self.strterm = new_strterm(:sword, 'w', term)
            scan(/\s*/)
            return :tAWORDS_BEG, scanner.matched
          when 'x'
            self.strterm = new_strterm2(:xquote, paren, term)
            return :tXSTRING_BEG, scanner.matched
          when 'r'
            self.strterm = new_strterm2(:regexp, paren, term)
            return :tREGEXP_BEG, scanner.matched
          end

        elsif scan(/\//)
          if beg?
            self.strterm = new_strterm(:regexp, '/', '/')
            return :tREGEXP_BEG, scanner.matched
          elsif scan(/\=/)
            @lex_state = :expr_beg
            return :tOP_ASGN, '/'
          elsif after_operator?
            @lex_state = :expr_arg
          elsif arg?
            if !check(/\s/) && @space_seen
              self.strterm = new_strterm(:regexp, '/', '/')
              return :tREGEXP_BEG, scanner.matched
            end
          else
            @lex_state = :expr_beg
          end

          return :tDIVIDE, '/'

        elsif scan(/\%/)
          if scan(/\=/)
            @lex_state = :expr_beg
            return :tOP_ASGN, '%'
          elsif check(/[^\s]/)
            if @lex_state == :expr_beg or (@lex_state == :expr_arg && @space_seen)
              start_word  = scan(/./)
              end_word    = { '(' => ')', '[' => ']', '{' => '}' }[start_word] || start_word
              self.strterm = new_strterm2(:dquote, start_word, end_word)
              return :tSTRING_BEG, scanner.matched
            end
          end

          self.set_arg_state

          return :tPERCENT, '%'

        elsif scan(/\\/)
          if scan(/\r?\n/)
            @space_seen = true
            next
          end

          raise SyntaxError, "backslash must appear before newline :#{@file}:#{@line}"

        elsif scan(/\(/)
          result = scanner.matched
          if beg?
            result = :tLPAREN
          elsif @space_seen && arg?
            result = :tLPAREN_ARG
          else
            result = :tLPAREN2
          end

          @lex_state = :expr_beg
          cond_push 0
          cmdarg_push 0

          return result, scanner.matched

        elsif scan(/\)/)
          cond_lexpop
          cmdarg_lexpop
          @lex_state = :expr_end
          return :tRPAREN, scanner.matched

        elsif scan(/\[/)
          result = scanner.matched

          if after_operator?
            @lex_state = :expr_arg
            if scan(/\]=/)
              return :tASET, '[]='
            elsif scan(/\]/)
              return :tAREF, '[]'
            else
              raise "Unexpected '[' token"
            end
          elsif beg? || @space_seen
            @lex_state = :expr_beg
            cond_push 0
            cmdarg_push 0
            return :tLBRACK, scanner.matched
          else
            @lex_state = :expr_beg
            cond_push 0
            cmdarg_push 0
            return :tLBRACK2, scanner.matched
          end

        elsif scan(/\]/)
          cond_lexpop
          cmdarg_lexpop
          @lex_state = :expr_end
          return :tRBRACK, scanner.matched

        elsif scan(/\}/)
          cond_lexpop
          cmdarg_lexpop
          @lex_state = :expr_end

          return :tRCURLY, scanner.matched

        elsif scan(/\.\.\./)
          @lex_state = :expr_beg
          return :tDOT3, scanner.matched

        elsif scan(/\.\./)
          @lex_state = :expr_beg
          return :tDOT2, scanner.matched

        elsif scan(/\./)
          @lex_state = :expr_dot unless @lex_state == :expr_fname
          return :tDOT, scanner.matched

        elsif scan(/\:\:/)
          if beg?
            @lex_state = :expr_beg
            return :tCOLON3, scanner.matched
          elsif spcarg?
            @lex_state = :expr_beg
            return :tCOLON3, scanner.matched
          end

          @lex_state = :expr_dot
          return :tCOLON2, scanner.matched

        elsif scan(/\:/)
          if end? || check(/\s/)
            unless check(/\w/)
              @lex_state = :expr_beg
              return :tCOLON, ':'
            end

            @lex_state = :expr_fname
            return :tSYMBEG, ':'
          end

          if scan(/\'/)
            self.strterm = new_strterm(:ssym, "'", "'")
          elsif scan(/\"/)
            self.strterm = new_strterm(:dsym, '"', '"')
          end

          @lex_state = :expr_fname
          return :tSYMBEG, ':'

        elsif scan(/\^\=/)
          @lex_state = :expr_beg
          return :tOP_ASGN, '^'
        elsif scan(/\^/)
          self.set_arg_state
          return :tCARET, scanner.matched

        elsif check(/\</)
          if scan(/\<\<\=/)
            @lex_state = :expr_beg
            return :tOP_ASGN, '<<'
          elsif scan(/\<\</)
            if after_operator?
              @lex_state = :expr_arg
              return :tLSHFT, '<<'
            elsif !after_operator? && !end? && (!arg? || @space_seen)
              if token = heredoc_identifier
                return token
              end

              @lex_state = :expr_beg
              return :tLSHFT, '<<'
            end
            @lex_state = :expr_beg
            return :tLSHFT, '<<'
          elsif scan(/\<\=\>/)
            if after_operator?
              @lex_state = :expr_arg
            else
              if @lex_state == :expr_class
                cmd_start = true
              end

              @lex_state = :expr_beg
            end

            return :tCMP, '<=>'
          elsif scan(/\<\=/)
            self.set_arg_state
            return :tLEQ, '<='

          elsif scan(/\</)
            self.set_arg_state
            return :tLT, '<'
          end

        elsif check(/\>/)
          if scan(/\>\>\=/)
            return :tOP_ASGN, '>>'
          elsif scan(/\>\>/)
            self.set_arg_state
            return :tRSHFT, '>>'

          elsif scan(/\>\=/)
            self.set_arg_state
            return :tGEQ, scanner.matched

          elsif scan(/\>/)
            self.set_arg_state
            return :tGT, '>'
          end

        elsif scan(/->/)
          # FIXME: # should be :expr_arg, but '(' breaks it...
          @lex_state = :expr_end
          @start_of_lambda = true
          return [:tLAMBDA, scanner.matched]

        elsif scan(/[+-]/)
          matched = scanner.matched
          sign, utype = if matched == '+'
                          [:tPLUS, :tUPLUS]
                        else
                          [:tMINUS, :tUMINUS]
                        end

          if beg?
            @lex_state = :expr_mid
            return [utype, matched]
          elsif after_operator?
            @lex_state = :expr_arg
            return [:tIDENTIFIER, matched + '@'] if scan(/@/)
            return [sign, matched]
          end

          if scan(/\=/)
            @lex_state = :expr_beg
            return [:tOP_ASGN, matched]
          end

          if spcarg?
            @lex_state = :expr_mid
            return [utype, matched]
          end

          @lex_state = :expr_beg
          return [sign, sign]

        elsif scan(/\?/)
          if end?
            @lex_state = :expr_beg
            return :tEH, scanner.matched
          end

          unless check(/\ |\t|\r|\s/)
            @lex_state = :expr_end
            return :tSTRING, scan(/./)
          end

          @lex_state = :expr_beg
          return :tEH, scanner.matched

        elsif scan(/\~/)
          self.set_arg_state
          return :tTILDE, '~'

        elsif check(/\$/)
          if scan(/\$([1-9]\d*)/)
            @lex_state = :expr_end
            return :tNTH_REF, scanner.matched.sub('$', '')

          elsif scan(/(\$_)(\w+)/)
            @lex_state = :expr_end
            return :tGVAR, scanner.matched

          elsif scan(/\$[\+\'\`\&!@\"~*$?\/\\:;=.,<>_]/)
            @lex_state = :expr_end
            return :tGVAR, scanner.matched
          elsif scan(/\$\w+/)
            @lex_state = :expr_end
            return :tGVAR, scanner.matched
          else
            raise "Bad gvar name: #{scanner.peek(5).inspect}"
          end

        elsif scan(/\$\w+/)
          @lex_state = :expr_end
          return :tGVAR, scanner.matched

        elsif scan(/\@\@\w*/)
          @lex_state = :expr_end
          return :tCVAR, scanner.matched

        elsif scan(/\@\w*/)
          @lex_state = :expr_end
          return :tIVAR, scanner.matched

        elsif scan(/\,/)
          @lex_state = :expr_beg
          return :tCOMMA, scanner.matched

        elsif scan(/\{/)
          if @start_of_lambda
            @start_of_lambda = false
            @lex_state = :expr_beg
            return [:tLAMBEG, scanner.matched]

          elsif arg? or @lex_state == :expr_end
            result = :tLCURLY
          elsif @lex_state == :expr_endarg
            result = :LBRACE_ARG
          else
            result = '{'
          end

          @lex_state = :expr_beg
          cond_push 0
          cmdarg_push 0
          return result, scanner.matched

        elsif check(/[0-9]/)
          return process_numeric

        elsif scan(/(\w)+[\?\!]?/)
          return process_identifier scanner.matched, cmd_start
        end

        if scanner.eos?
          if @scanner_stack.size == 1 # our main scanner, we cant pop this
            return [false, false]
          else # we were probably parsing a heredoc, so pop that parser and continue
            @scanner_stack.pop
            @scanner = @scanner_stack.last
            return next_token
          end
        end

        raise "Unexpected content in parsing stream `#{scanner.peek 5}` :#{@file}:#{@line}"
      end
    end
  end
end
