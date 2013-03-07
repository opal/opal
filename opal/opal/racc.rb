# Opal port of racc/parser.rb.
#
# Original license:
#
# $originalId: parser.rb,v 1.8 2006/07/06 11:42:07 aamine Exp $
#
# Copyright (c) 1999-2006 Minero Aoki
#
# This program is free software.
# You can distribute/modify this program under the same terms of ruby.
#
# As a special exception, when this code is copied by Racc
# into a Racc output file, you may use that output file
# without restriction.
module Racc

  class Parser

    def _racc_setup
      self.class::Racc_arg
    end

    def do_parse
      _racc_do_parse_rb _racc_setup, false
    end

    def _racc_do_parse_rb(arg, in_debug)
      action_table   = arg[0]
      action_check   = arg[1]
      action_default = arg[2]
      action_pointer = arg[3]

      goto_table     = arg[4]
      goto_check     = arg[5]
      goto_default   = arg[6]
      goto_pointer   = arg[7]

      nt_base        = arg[8]
      reduce_table   = arg[9]
      token_table    = arg[10]
      shift_n        = arg[11]
      reduce_n       = arg[12]

      use_result     = arg[13]

      # racc sys vars
      racc_state     = [0]
      racc_tstack    = []
      racc_vstack    = []

      racc_t         = nil
      racc_tok       = nil
      racc_val       = nil
      racc_read_next = true

      racc_user_yyerror = false
      racc_error_status = 0

      token = nil; act = nil; i = nil; nerr = nil; custate = nil

      while true
        i = action_pointer[racc_state[-1]]

        if i
          if racc_read_next
            if racc_t != 0 # not EOF
              token = next_token

              racc_tok = token[0]
              racc_val = token[1]

              if racc_tok == false # EOF
                racc_t = 0
              else
                racc_t = token_table[racc_tok]
                racc_t = 1 unless racc_t
                # racc_t ||= 1
              end

              racc_read_token(racc_t, racc_tok, racc_val) if @yydebug
              racc_read_next = false
            end
          end

          i += racc_t

          if (i < 0) || (act = action_table[i]).nil? || (action_check[i] != racc_state[-1])
            act = action_default[racc_state[-1]]
          end

        else
          act = action_default[racc_state[-1]]
        end

        puts "(act: #{act}, shift_n: #{shift_n}, reduce_n: #{reduce_n})" if @yydebug
        if act > 0 && act < shift_n
          if racc_error_status > 0
            if racc_t != 1
              racc_error_status -= 1
            end
          end

          racc_vstack.push racc_val
          curstate = act
          racc_state << act
          racc_read_next = true

          if @yydebug
            racc_tstack.push racc_t
            racc_shift racc_t, racc_tstack, racc_vstack
          end

        elsif act < 0 && act > -reduce_n
          reduce_i   = act * -3
          reduce_len = reduce_table[reduce_i]
          reduce_to  = reduce_table[reduce_i + 1]
          method_id  = reduce_table[reduce_i + 2]

          tmp_t = racc_tstack.last reduce_len
          tmp_v = racc_vstack.last reduce_len

          racc_state.pop reduce_len
          racc_vstack.pop reduce_len
          racc_tstack.pop reduce_len

          if use_result
            reduce_call_result = self.__send__ method_id, tmp_v, nil, tmp_v[0]
            racc_vstack.push reduce_call_result
          else
            raise "not using result??"
          end

          racc_tstack.push reduce_to

          if @yydebug
            racc_reduce tmp_t, reduce_to, racc_tstack, racc_vstack
          end

          k1 = reduce_to - nt_base

          if (reduce_i = goto_pointer[k1]) != nil
            reduce_i += racc_state[-1]

            if (reduce_i >= 0) && ((curstate = goto_table[reduce_i]) != nil) && (goto_check[reduce_i] == k1)
              racc_state.push curstate
            else
              racc_state.push goto_default[k1]
            end

          else
            racc_state.push goto_default[k1]
          end

        elsif act == shift_n
          # action
          return racc_vstack[0]

        elsif act == -reduce_n
          # reduce
          raise SyntaxError, "unexpected '#{racc_tok.inspect}'"

        else
          raise "Rac: unknown action: #{act}"
        end

        if @yydebug
          racc_next_state racc_state[-1], racc_state
        end
        # raise "and finished loop"
      end

    end # _racc_do_parse_rb

    def racc_read_token(t, tok, val)
      puts "read    #{tok}(#{racc_token2str(t)}) #{val.inspect}"
      puts "\n"
    end

    def racc_shift(tok, tstack, vstack)
      puts "shift  #{racc_token2str tok}"
      racc_print_stacks tstack, vstack
      puts "\n"
    end

    def racc_reduce(toks, sim, tstack, vstack)
      puts "reduce #{toks.empty? ? '<none>' : toks.map { |t| racc_token2str(t) }}"
      puts "  --> #{racc_token2str(sim)}"
      racc_print_stacks tstack, vstack
    end

    def racc_next_state(curstate, state)
      puts "goto  #{curstate}"
      racc_print_states state
      puts "\n"
    end

    def racc_token2str(tok)
      self.class::Racc_token_to_s_table[tok]
    end

    def racc_print_stacks(t, v)
      puts '  ['
      t.each_index do |i|
        puts "    (#{racc_token2str(t[i])} #{v[i].inspect})"
      end
      puts '  ]'
    end

    def racc_print_states(s)
      puts '  ['
      s.each { |st| puts "   #{st}" }
      puts '  ]'
    end
  end
end
