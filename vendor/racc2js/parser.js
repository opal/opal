var parser = function() {
  
};

parser.prototype.do_parse = function() {
  return this.do_parse_js(parser.Racc_arg, false);
};

parser.prototype.do_parse_js = function(arg, in_debug) {
  var action_table    = arg[0],
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
  //  console.log('looping');
    if ((i = action_pointer[racc_state[racc_state.length - 1]]) !== null) {
    //  console.log('yeap');
      if (racc_read_next) {
        if (racc_t !== 0) { // not EOF
          token = this.next_token();
          racc_tok = token[0];
          racc_val = token[1];
          
        //  console.log('token is: ' + token.join(','));
          
          if (!racc_tok) { // EOF
            racc_t = 0;
          }
          else {
            racc_t = token_table[racc_tok];
            if (racc_t === undefined) racc_t = 1;
          }
          
        //  console.log('racc_t: ' + racc_t);
          
          racc_read_next = false;
        }
      }
            
      i += racc_t;
      
    //  console.log('i is now ' + i);
      
      if ((i < 0) || ((act = action_table[i]) === null) || (action_check[i] !== racc_state[racc_state.length - 1])) {
        act = action_default[racc_state[racc_state.length - 1]];
      }
    }
    else {
      act = action_default[racc_state[racc_state.length - 1]];
    }
    
  //  console.log('act is: ' + act);
    
    // ================
    // = racc_evalact =
    // ================
    
    if (act > 0 && act < shift_n) {
    //  console.log('shift on ' + act);
      // 
      // shift
      // 
      if (racc_error_status > 0) {
        // error token
      //  console.log('err part 1');
        if (racc_t !== 1) {
        //  console.log('err part 2');
          racc_error_status -= 1;
        }
      }
      
      racc_vstack.push(racc_val);
      curstate = act;
      racc_state.push(act);
      racc_read_next = true;
    }
    else if (act < 0 && act > -reduce_n) {
    //  console.log('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ reduce on ' + act);
      // 
      // reduce
      // 
      var reduce_i    = act * -3,
          reduce_len  = reduce_table[reduce_i],
          reduce_to   = reduce_table[reduce_i + 1],
          method_id   = reduce_table[reduce_i + 2];
      
      var tmp_v = racc_vstack.slice(racc_vstack.length - reduce_len);
    //  console.log('reduce len is: ' + reduce_len);
    //  console.log('tmp_v is: ' + tmp_v.join(', '));
      
      // pop for number of reductions
      while(reduce_len--) {
      //  console.log('popping: ' + reduce_len);
        racc_state.pop();
        racc_vstack.pop();
        racc_tstack.pop();
      }
      
      if (use_result) {
        // msgsend..we push on result of method call..?
      //  console.log('reducing: ' + method_id);
      //  console.log('['+tmp_v.join(', ')+']');
      //  console.log('[' + racc_vstack.join(', ') + ']');
        // racc_vstack.push(method_id);
      //  console.log("NEED TO EXECUTE: [" + tmp_v.join(',') + ']');
      //  console.log(this[method_id]);
        var reduce_call_result = this[method_id](tmp_v, tmp_v[0]);
      //  console.log(reduce_call_result);
        racc_vstack.push(reduce_call_result);
      }
      else {
        throw "not using result?!?!?!?!?!";
      }
      
      racc_tstack.push(reduce_to);
      
    //  console.log('VSTACK: [' + racc_vstack.join(', ') + ']');
      
      var k1 = reduce_to - nt_base;
    //  console.log('k1 is ' +k1);
    //  console.log("goto pointer is: " + goto_pointer[k1]);
      if ((reduce_i = goto_pointer[k1]) !== null) {
        
        reduce_i += racc_state[racc_state.length - 1];
      //  console.log("reduce_i is now: " + reduce_i);
      //  console.log("-- potential curstate is: " + goto_table[reduce_i]);
        if ((reduce_i >= 0) && ((curstate = goto_table[reduce_i]) !== null) &&
                (curstate !== undefined) && (goto_check[reduce_i] === k1)) {
          // curstate = curstate; ..?
        //  console.log('========== return current state: ' + curstate);
          racc_state.push(curstate);
        }
        else {//
          // console.log("dont do this??");
          // curstate = k1;
        //  console.log("=========== PUSHING curstate " + curstate);
        //  console.log('=========== goto default is: ' + goto_default[k1]);
          racc_state.push(goto_default[k1]);
        }
        // tmp_v is return value from stack
        // racc_vstack.push(tmp_v[0]);
        
      }
      else {
      //  console.log('GOTO default down here init!!!!!!!!!!!');
        racc_state.push(goto_default[k1]);
      }
      
      // return;
    }
    else if (act === shift_n) {
    //  console.log('accept on ' + act);
      // 
      // accept
      // 
    //  console.log('accepting!!!!');
    //  console.log(racc_vstack[0]);
      return racc_vstack[0];
    }
    else if (act === -reduce_n) {
    //  console.log('error on ' + act);
      // 
      // error
      // 
    //  console.log('racc error status: ' + racc_error_status);
    //  console.log(racc_tok + ", " + racc_val);
      throw new Error('syntax error, unexpected ' + racc_tok);
      return;
    }
    else {
      throw "Racc - unknown action: " + act;
    }
    
    // return;
  }  
};

// default next token implementation
parser.prototype.next_token = function() {
  throw "next_token is not defined for parser."
};

parser.prototype.yyerror = function(err) {
  throw "yyerror: " + err;
};

parser.prototype._reduce_none = function(val, result) {
  return result;
};

