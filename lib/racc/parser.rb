module Racc
  class Parser

    def _racc_setup
      Racc_arg
    end

    def do_parse
      _racc_do_parse_js racc_setup, false
    end

    def _racc_do_parse_js(arg, in_debug)
      `var action_table    = arg[0],
          action_check    = arg[1],
          action_default  = arg[2],
          action_pointer  = arg[3],

          goto_table      = arg[4],
          goto_check      = arg[5],
          goto_default    = arg[6],
          goto_pointer    = arg[7],

          nt_base         = arg[8],
          reduce_table    = arg[9],
          token_table     = arg[10],
          shift_n         = arg[11],
          reduce_n        = arg[12],

          use_result      = arg[13];

      // racc sys vars
      var racc_state      = [0],
          racc_tstack     = [],
          racc_vstack     = [],

          racc_t          = null,
          racc_tok        = null,
          racc_val        = null,
          racc_read_next  = true,

          racc_user_yyerror = false,
          racc_error_status = 0;

      var token = null, act = null, i = null, nerr = 0, curstate = null;

    while (true) {

      if ((i = action_pointer[racc_state[racc_state.length - 1]]) !== null) {

      if (racc_read_next) {
        if (racc_t !== 0) { // not EOF
          token = this.next_token();
          racc_tok = token[0];
          racc_val = token[1];

          if (!racc_tok) { // EOF
            racc_t = 0;
          }
          else {
            racc_t = token_table[racc_tok];
            if (racc_t === undefined) racc_t = 1;
          }
          racc_read_next = false;
        }
      }

      i += racc_t;

      if ((i < 0) || ((act = action_table[i]) === null) || (action_check[i] !== racc_state[racc_state.length - 1])) {
        act = action_default[racc_state[racc_state.length - 1]];
      }
    }
    else {
      act = action_default[racc_state[racc_state.length - 1]];
    }

    if (act > 0 && act < shift_n) {
      if (racc_error_status > 0) {
        if (racc_t !== 1) {
          racc_error_status -= 1;
        }
      }

      racc_vstack.push(racc_val);
      curstate = act;
      racc_state.push(act);
      racc_read_next = true;
    }
    else if (act < 0 && act > -reduce_n) {
      var reduce_i    = act * -3,
          reduce_len  = reduce_table[reduce_i],
          reduce_to   = reduce_table[reduce_i + 1],
          method_id   = reduce_table[reduce_i + 2];

      var tmp_v = racc_vstack.slice(racc_vstack.length - reduce_len);

      while(reduce_len--) {
        racc_state.pop();
        racc_vstack.pop();
        racc_tstack.pop();
      }

      if (use_result) {
        var reduce_call_result = this[method_id](tmp_v, tmp_v[0]);
        racc_vstack.push(reduce_call_result);
      }
      else {
        throw "not using result?!?!?!?!?!";
      }

      racc_tstack.push(reduce_to);

      var k1 = reduce_to - nt_base;
      if ((reduce_i = goto_pointer[k1]) !== null) {

        reduce_i += racc_state[racc_state.length - 1];
        if ((reduce_i >= 0) && ((curstate = goto_table[reduce_i]) !== null) &&
                (curstate !== undefined) && (goto_check[reduce_i] === k1)) {
          racc_state.push(curstate);
        }
        else {
          racc_state.push(goto_default[k1]);
        }
      }
      else {
        racc_state.push(goto_default[k1]);
      }
    }
    else if (act === shift_n) {
      // action
      return racc_vstack[0];
    }
    else if (act === -reduce_n) {
      // reduce
      throw new Error('syntax error, unexpected ' + racc_tok);
      return;
    }
    else {
      throw "Racc - unknown action: " + act;
    }
  }`
    end
  end
end

