var RubyParser = opal.dev.RubyParser;
var StringScanner = opal.dev.StringScanner;

var EXPR_BEG    = 0,    EXPR_END    = 1,    EXPR_ENDARG = 2,    EXPR_ARG   = 3,
    EXPR_CMDARG = 4,    EXPR_MID    = 5,    EXPR_FNAME  = 6,    EXPR_DOT   = 7,
    EXPR_CLASS  = 8,    EXPR_VALUE  = 9;

RubyParser.prototype.parse = function(source) {
  var token;

  this._string = source;
  this._scanner = new StringScanner(source);
  this.lex_state = EXPR_BEG;
  this._tokens = [];
  this._string_parse_stack = [];
  this._line_number = 1;

  // cond stack
  this._cond = 0;
  // cmd arg stack
  this._cmdarg = 0;

  try {
    var result = this.do_parse();
    return result;
  } catch (e) {
    e.message += " on line: " + this._line_number;
    throw e;
  }
};

/**
  Tokens are fed into the parser as an array. The 0 index is the token type,
  and the index 1 is an object, with the line number the token was found on,
  and the value. e.g.

      ['IDENTIFIER', { value: 'wow', line: 1 }]
*/
RubyParser.prototype.next_token = function() {
  var token = this.get_next_token();
  // console.log('[' + token.join(', ') + '] - ' + this._line_number);
  token[1] = { value: token[1], line: this._line_number };
  return token;
};

RubyParser.prototype.cond_push = function(n) {
  // print('cond_push ' + n);
  return this._cond = (this._cond << 1) | ((n) & 1);
};

RubyParser.prototype.cond_pop = function() {
  // print('cond_pop');
  return this._cond = this._cond >> 1;
};

RubyParser.prototype.cond_lexpop = function() {
  // print('cond_lexpop');
  return this._cond = (this._cond >> 1) | (this._cond & 1);
};

RubyParser.prototype.cond_p = function() {
  // print('cond_p');
  return this._cond & 1;
};

RubyParser.prototype.cmdarg_push = function(n) {
  // print('cmdarg_push ' + n);
  return this._cmdarg = (this._cmdarg << 1) | ((n) & 1);
};

RubyParser.prototype.cmdarg_pop = function() {
  // print('cmdarg_pop');
  return this._cmdarg = this._cmdarg >> 1;
};

RubyParser.prototype.cmdarg_lexpop = function() {
  // print('cmdarg_lexpop');
  return this._cmdarg = (this._cmdarg >> 1) | (this._cmdarg & 1);
};

RubyParser.prototype.cmdarg_p = function() {
  // print('cmdarg_p');
  return this._cmdarg & 1;
};

RubyParser.prototype.current_string_parse = function() {
  if (this._string_parse_stack.length == 0) return null;
  return this._string_parse_stack[this._string_parse_stack.length - 1];
};

RubyParser.prototype.push_string_parse = function(o) {
  this._string_parse_stack.push(o);
};

RubyParser.prototype.pop_string_parse = function() {
  this._string_parse_stack.pop();
};

RubyParser.prototype.next_string_token = function() {
  var str_parse = this.current_string_parse(), scanner = this._scanner;
  
  // everything bar single quote and lower case barewords can interpolate
  var interpolate = (str_parse.beg !== "'" && str_parse.beg !== '%w');
  
  // see if we can read end of string/xstring/regexp markers
  if (scanner.scan( new RegExp('^\\' + str_parse.end))) {
    this.pop_string_parse();
    if (str_parse.beg == '"' || str_parse.beg == "'") {
      this.lex_state = EXPR_END;
      return ['STRING_END', scanner.matched];
    }
    else if (str_parse.beg == '`') {
      // assume to be xstring
      this.lex_state = EXPR_END;
      return ['STRING_END', scanner.matched];
    }
    else if (str_parse.beg == '/') {
      var result = "";
      if (scanner.scan(/^\w+/)) {
        result = scanner.matched;
      }
      this.lex_state = EXPR_END;
      return ['REGEXP_END', result];
    }
    else { // words?
      this.lex_state = EXPR_END;
      return ['STRING_END', scanner.matched];
    }
  }
  
  // not end of string, so we must be parsing contents
  var str_buffer = [];
  
  if (scanner.scan(/^#(\$|\@)\w+/)) {
    if (interpolate) {
      return ['STRING_DVAR', scanner.matched.substr(2)];
    }
    else {
      str_buffer.push(scanner.matched);
    }
  }
  else if (scanner.scan(/^#\{/)) {
    if (interpolate) {
      // we are into ruby code, so stop parsing content (for the moment)
      str_parse.content = false;
      return ['STRING_DBEG', scanner.matched];
    }
    else {
      str_buffer.push(scanner.matched);
    }
  }
  // causes error, so we will just collect it later on with other text
  else if (scanner.scan(/^#/)) {
    str_buffer.push('#');
  }
  
  this.add_string_content(str_buffer, str_parse);
  var complete_str = str_buffer.join('');

  return ['STRING_CONTENT', complete_str];
};

RubyParser.prototype.add_string_content = function(str_buffer, str_parse) {
  var scanner = this._scanner;
  // regexp for end of string/regexp 
  var end_str_re = new RegExp('^' + str_parse.end);
  // can we interpolate?
  var interpolate = ['"', '%W', '/', '`'].indexOf(str_parse.beg) != -1;

  while (!scanner.eos()) {
    var c = null, handled = true;
    if (scanner.check(end_str_re)) {
      //throw new Error("EOS");
      break;

    } else if (interpolate && scanner.check(/^#(?=[\@\{])/)) {
      break;
   
    } else if (scanner.scan(/^\\\\/)) {
      c = scanner.matched; 

    } else if (scanner.scan(/^\\/)) {
      c = scanner.matched;
      if (scanner.scan(end_str_re)) {
        c += scanner.matched;
      }
    
    } else {
      handled = false;
    }
    
    if (!handled) {
      var reg = new RegExp("^[^\\" + str_parse.end + "\#\0\\\\]+|.");
      scanner.scan(reg);
      c = scanner.matched;
    }

    c = c || scanner.matched;
    str_buffer.push(c);
  }

  if (scanner.eos()) {
    throw new Error("reached end of file when in string")
  }
};



RubyParser.prototype.get_next_token = function() {
  var string_scanner;
  if ((string_scanner = this.current_string_parse()) && string_scanner.content){
    return this.next_string_token();
  }
  
  var scanner    = this._scanner,
      space_seen = false,
      c          = '',
      cmd_start  = false;
      
  
  while (true) {
    if (scanner.scan(/^(\ |\t|\r)/)) {
      space_seen = true;
      continue;
    }
    else if (scanner.scan(/^(\n|#)/)) {
      c = scanner.matched;
      if (c == '#') {
        scanner.scan(/^(.*)/);
      }
      else {
        this._line_number++;
      }
      
      scanner.scan(/^(\n+)/);
      this._line_number += scanner.matched.length;
      
      if ([EXPR_BEG, EXPR_DOT].indexOf(this.lex_state) !== -1) {
        continue;
      }
      cmd_start = true;
      this.lex_state = EXPR_BEG;
      return ["\\n", "\\n"];
    }
    
    else if (scanner.scan(/^\;/)) {
      this.lex_state = EXPR_BEG;
      return [";", ";"];
    }
    
    else if (scanner.scan(/^\"/)) {
      this.push_string_parse({ beg: '"', content: true, end:'"' });
      return ['STRING_BEG', scanner.matched];
    }
    else if (scanner.scan(/^\'/)) {
      this.push_string_parse({ beg: "'", content: true, end:"'" });
      return ['STRING_BEG', scanner.matched];
    }
    else if (scanner.scan(/^\`/)) {
      this.push_string_parse({ beg: "`", content: true, end: "`" });
      return ["XSTRING_BEG", scanner.matched];
    }
    else if (scanner.scan(/^\%[Ww]/)) {
      var start_word = scanner.scan(/^./),
          end_word   = { '(': ')', '[': ']', '{': '}'}[start_word],
          end_word   = end_word || start_word;
      
      this.push_string_parse({ beg: start_word, content: true, end: end_word });
      return ["WORDS_BEG", scanner.matched]; 
    }
    else if (scanner.scan(/^\%[Qq]/)) {
      var start_word = scanner.scan(/^./),
          end_word   = { '(': ')', '[': ']', '{': '}'}[start_word],
          end_word   = end_word || start_word;
      
      this.push_string_parse({ beg: start_word, content: true, end: end_word });
      return ["STRING_BEG", scanner.matched];
    }
    else if (scanner.scan(/^\%[Rr]/)) {
      var start_word = scanner.scan(/^./),
          end_word   = { '(': ')', '{': '}', '[': ']' }[start_word],
          end_word   = end_word || start_word;
      
      this.push_string_parse({ beg: '/', content: true, end: end_word });
      return ['REGEXP_BEG', scanner.matched];
    }
    
    else if (scanner.scan(/^\//)) {
      if (this.lex_state == EXPR_BEG || this.lex_state == EXPR_MID) {
        this.push_string_parse({ beg: "/", content: true, end: "/" });
        return ["REGEXP_BEG", scanner.matched];
      }
      else if (scanner.scan(/^\=/)) {
        this.lex_state = EXPR_BEG;
        return ["OP_ASGN", "/"];
      }
      else if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
      }
      return ["/", '/'];
    }
    
    else if (scanner.scan(/^\%/)) {
      // if (scanner.scan(/^\=/)) {
        // this.lex_state = EXPR_BEG;
        // return ["OP_ASGN", "%"];
      // }
      if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
      }
      else {
        this.lex_state = EXPR_BEG;
      }
      return ["%", '%'];
    }
    
    else if (scanner.scan(/^\(/)) {
      var result = '(';
      if (this.lex_state == EXPR_BEG || this.lex_state == EXPR_MID) {
        result = 'PAREN_BEG';
      }
      else if (space_seen) {
        result = '(';
      }
      this.lex_state = EXPR_BEG;
      this.cond_push(0);
      this.cmdarg_push(0);
      return [result, scanner.matched];
    }
    
    else if (scanner.scan(/^\)/)) {
      this.cond_lexpop();
      this.cmdarg_lexpop();
      this.lex_state = EXPR_END;
      return [")", scanner.matched];
    }
    
    else if (scanner.scan(/^\[/)) {
      var result = scanner.matched;
      
      if (this.lex_state == EXPR_FNAME || this.lex_state == EXPR_DOT) {
        this.lex_state = EXPR_ARG;
        if (scanner.scan(/^\]\=/)) {
          return ["[]=", "[]="];
        }
        else if (scanner.scan(/^\]/)) {
          return ["[]", "[]"];
        }
        else {
          throw "error - unexpected '[' token"
        }
      }
      else if (this.lex_state == EXPR_BEG || this.lex_state == EXPR_MID || space_seen) {
        this.lex_state = EXPR_BEG;
        this.cond_push(0);
        this.cmdarg_push(0);
        return ["[", scanner.matched];
      }
      else {
        this.lex_state = EXPR_BEG;
        this.cond_push(0);
        this.cmdarg_push(0);
        return ["[@", scanner.matched];
      }
    }
    
    else if (scanner.scan(/^\]/)) {
      this.cond_lexpop();
      this.cmdarg_lexpop();
      this.lex_state = EXPR_END;
      return ["]", scanner.matched];
    }
    else if (scanner.scan(/^\}/)) {
      this.cond_lexpop();
      this.cmdarg_lexpop();
      this.lex_state = EXPR_END;
      
      if (this.current_string_parse()) {
        this.current_string_parse().content = true
      }
      // if (string_parse) string_parse.content = true;
      return ["}", scanner.matched];
    }
    
    else if (scanner.scan(/^\.\.\./)) {
      this.lex_state = EXPR_BEG;
      return ["...", scanner.matched];
    }
    else if (scanner.scan(/^\.\./)) {
      this.lex_state = EXPR_BEG;
      return ["..", scanner.matched];
    }
    else if (scanner.scan(/^\./)) {
      if (this.lex_state !== EXPR_FNAME) this.lex_state = EXPR_DOT;
      return [".", scanner.matched];
    }
    
    else if (scanner.scan(/^\*\*\=/)) {
      this.lex_state = EXPR_BEG;
      return ["OP_ASGN", "**"];
    }
    else if (scanner.scan(/^\*\*/)) {
      return ["**", "**"];
    }
    else if (scanner.scan(/^\*\=/)) {
      this.lex_state = EXPR_BEG;
      return ["OP_ASGN", "*"];
    }
    else if (scanner.scan(/^\*/)) {
      if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
        return ["*", scanner.matched];
      }
      else if (space_seen && scanner.check(/^\S/)) {
        this.lex_state = EXPR_BEG;
        return ["SPLAT", scanner.matched];
      }
      else if (this.lex_state == EXPR_BEG || this.lex_state == EXPR_MID) {
        this.lex_state = EXPR_BEG;
        return ["SPLAT", scanner.matched];
      }
      else {
        this.lex_state = EXPR_BEG;
        return ["*", scanner.matched];
      }
    }
    
    else if (scanner.scan(/^\:\:/)) {
      if ([EXPR_BEG, EXPR_MID, EXPR_CLASS].indexOf(this.lex_state) !== -1) {
        this.lex_state = EXPR_BEG;
        return ["::@", scanner.matched];
      }
      this.lex_state = EXPR_DOT;
      return ["::", scanner.matched];
    }
    else if (scanner.scan(/^\:/)) {
      if (this.lex_state == EXPR_END || this.lex_state == EXPR_ENDARG || scanner.check(/^\s/)) {
        if (!scanner.check(/^\w/)) {
          this.lex_state = EXPR_BEG;
          return [":", scanner.matched];
        }
        
        this.lex_state = EXPR_FNAME;
        return ["SYMBOL_BEG", scanner.matched];
      }
      
      if (scanner.scan(/^\'/)) {
        this.push_string_parse({ beg: "'", content: true, end: "'" });
      }
      else if (scanner.scan(/^\"/)) {
        this.push_string_parse({ beg: '"', content: true, end: '"' });
      }
      
      this.lex_state = EXPR_FNAME;
      return ["SYMBOL_BEG", scanner.matched];
    }
    
    else if (scanner.check(/^\|/)) {
      if (scanner.scan(/^\|\|\=/)) {
        this.lex_state = EXPR_BEG;
        return ["OP_ASGN", "||"];
      }
      else if (scanner.scan(/^\|\|/)) {
        this.lex_state = EXPR_BEG;
        return ["||", scanner.matched];
      }
      else if (scanner.scan(/^\|\=/)) {
        this.lex_state = EXPR_BEG;
        return ["OP_ASGN", "|"];
      }
      else if (scanner.scan(/^\|/)) {
        if (this.lex_state == EXPR_FNAME) {
          this.lex_state = EXPR_END;
          return ["|", scanner.matched];
        }
        this.lex_state = EXPR_BEG;
        return ["|", scanner.matched];
      }
    }
    
    else if (scanner.scan(/^\^/)) {
      if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
        return ["^", scanner.matched];
      }
      this.lex_state = EXPR_BEG;
      return ["^", scanner.matched];
    }
    
    else if (scanner.scan(/^\&\&\=/)) {
      this.lex_state = EXPR_BEG;
      return ["OP_ASGN", "&&"];
    }
    else if (scanner.scan(/^\&\&/)) {
      this.lex_state = EXPR_BEG;
      return ["&&", scanner.matched];
    }
    else if (scanner.scan(/^\&\=/)) {
      this.lex_state = EXPR_BEG;
      return ["OP_ASGN", "&"];
    }
    else if (scanner.scan(/^\&/)) {
      // print(this.lex_state);
      if (space_seen && !scanner.check(/^\s/) && this.lex_state == EXPR_CMDARG){
        return ["&@", scanner.matched];
      }
      else if (this.lex_state == EXPR_BEG || this.lex_state == EXPR_MID) {
        return ["&@", scanner.matched];
      }
      else {
        return ["&", scanner.matched];
      }
    }
    
    else if (scanner.scan(/^\<\<\=/)) {
      this.lex_state = EXPR_BEG;
      return ["OP_ASGN", "<<"];
    }
    else if (scanner.scan(/^\<\</)) {
      if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
        return ["<<", "<<"];
      }
      if ([EXPR_END, EXPR_DOT, EXPR_ENDARG, EXPR_CLASS].indexOf(this.lex_state) == -1 && space_seen) {
        this.lex_state = EXPR_BEG;
        return ["<<", "<<"];
      }
      this.lex_state = EXPR_BEG;
      return ["<<", "<<"];
    }
    else if (scanner.scan(/^\<\=\>/)) {
      if (this.lex_state == EXPR_FNAME) this.lex_state = EXPR_END
      else this.lex_state = EXPR_BEG;
      return ["<=>", "<=>"];
    }
    else if (scanner.scan(/^\<\=/)) {
      if (this.lex_state == EXPR_FNAME) this.lex_state = EXPR_END
      else this.lex_state = EXPR_BEG;
      return ["<=", "<="];
    }
    else if (scanner.scan(/^\</)) {
      if (this.lex_state == EXPR_FNAME) this.lex_state = EXPR_END
      else this.lex_state = EXPR_BEG;
      return ["<", "<"];
    }
    
    else if (scanner.scan(/^\>\=/)) {
      if (this.lex_state == EXPR_FNAME) this.lex_state = EXPR_END
      else this.lex_state = EXPR_BEG;
      return [">=", scanner.matched];
    }
    else if (scanner.scan(/^\>\>\=/)) {
      return ["OP_ASGN", ">>"];
    }
    else if (scanner.scan(/^\>\>/)) {
      return [">>", scanner.matched];
    }
    else if (scanner.scan(/^\>/)) {
      if (this.lex_state == EXPR_FNAME) this.lex_state = EXPR_END
      else this.lex_state = EXPR_BEG;
      return [">", ">"];
    }

    else if (scanner.scan(/^[+-]/)) {
      var result = scanner.matched;
      // var sign = (result == '+') ? 'UPLUS' : 'UMINUS';
      var sign = result + '@';
      
      if (this.lex_state == EXPR_BEG || this.lex_state == EXPR_MID) {
        this.lex_state = EXPR_BEG;
        return [sign, sign];
      }
      else if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
        if (scanner.scan(/^@/)) {
          return ['IDENTIFIER', result + scanner.matched];
        }
        return [result, result];
      }
      
      if (scanner.scan(/^\=/)) {
        this.lex_state = EXPR_BEG;
        return ["OP_ASGN", result];
      }
      this.lex_state = EXPR_BEG;
      return [result, result];
    }
    
    else if (scanner.scan(/^\?/)) {
      if (this.lex_state = EXPR_END || this.lex_state == EXPR_ENDARG) {
        this.lex_state = EXPR_BEG;
      }
      return ["?", scanner.matched];
    }
    
    else if (scanner.scan(/^\=\=\=/)) {
      if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
        return ["===", "==="];
      }
      this.lex_state = EXPR_BEG;
      return ["===", "==="];
    }
    else if (scanner.scan(/^\=\=/)) {
      if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
        return ["==", "=="];
      }
      this.lex_state = EXPR_BEG;
      return ["==", "=="];
    }
    else if (scanner.scan(/^\=\~/)) {
      if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
        return ["=~", "=~"];
      }
      this.lex_state = EXPR_BEG;
      return ["=~", "=~"];
    }
    else if (scanner.scan(/^\=\>/)) {
      this.lex_state = EXPR_BEG;
      return ["=>", scanner.matched];
    }
    else if (scanner.scan(/^\=/)) {
      this.lex_state = EXPR_BEG;
      return ["=", "="];
    }
    
    else if (scanner.scan(/^\!\=/)) {
      if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
        return ["!=", "!="];
      }
      this.lex_state = EXPR_BEG;
      return ["!=", scanner.matched];
    }
    else if (scanner.scan(/^\!\~/)) {
      if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
        return ["!~", "!~"];
      }
      this.lex_state = EXPR_BEG;
      return ["!~", "!~"];
    }
    else if (scanner.scan(/^\!/)) {
      if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
        return ["!", "!"];
      }
      this.lex_state = EXPR_BEG;
      return ["!", "!"];
    }
    
    else if (scanner.scan(/^\~/)) {
      if (this.lex_state == EXPR_FNAME) {
        this.lex_state = EXPR_END;
        return ["~", "~"];
      }
      this.lex_state = EXPR_BEG;
      return ["~", "~"];
    }
    
    // FIXME: do we really need to differentiate between these. generates the
    // same code. our checks will be in the gvar getters (for the relative 
    // parts..)
    // 
    // else if (scanner.scan(/^\$([1-9]\d*)/)) {
    //   this.lex_state = EXPR_END;
    //   return ["NTH_REF", scanner.matched];
    // }
    // else if (scanner.scan(/^\$([\+\'\&\`])/)) {
    //   this.lex_state = EXPR_END;
    //   return ["BACK_REF", scanner.matched];
    // }
    // else if (scanner.scan(/^\$[!@\"~*$?\/\\:;=.,<>_]/)) {
    //   this.lex_state = EXPR_END;
    //   return ["GVAR", scanner.matched];
    // }
    else if (scanner.scan(/^\$[\+\'\`\&!@\"~*$?\/\\:;=.,<>_]/)) {
      this.lex_state = EXPR_END;
      return ["GVAR", scanner.matched];
    }
    else if (scanner.scan(/^\$\w+/)) {
      this.lex_state = EXPR_END;
      return ["GVAR", scanner.matched];
    }
    else if (scanner.scan(/^\@\@\w*/)) {
      this.lex_state = EXPR_END;
      return ["CVAR", scanner.matched];
    }
    else if (scanner.scan(/^\@\w*/)) {
      this.lex_state = EXPR_END;
      return ["IVAR", scanner.matched];
    }
    
    else if (scanner.scan(/^\,/)) {
      this.lex_state = EXPR_BEG;
      return [",", scanner.matched];
    }
    
    else if (scanner.scan(/^\{/)) {
      var result;
      // print(this.lex_state);
      if (this.lex_state == EXPR_END || this.lex_state == EXPR_CMDARG) {
        result = '{@';
      }
      else if (this.lex_state == EXPR_ENDARG) {
        result = 'LBRACE_ARG';
      }
      else {
        result = '{';
      }
      
      this.lex_state = EXPR_BEG;
      this.cond_push(0);
      this.cmdarg_push(0);
      
      return [result, scanner.matched];
    }
    
    else if (scanner.check(/^[0-9]/)) {
      this.lex_state = EXPR_END;
      if (scanner.scan(/^[\d_]+\.[\d_]+\b/)) {
        return ['FLOAT', scanner.matched.replace(/_/g, '')];
      }
      else if (scanner.scan(/^[\d_]+\b/)) {
        return ['INTEGER', scanner.matched.replace(/_/g, '')];
      }
      else if (scanner.scan(/^0(x|X)(\d|[a-f]|[A-F])+/)) {
        return ['INTEGER', scanner.matched.replace(/_/g, '')];
      }
      else {
        // console.log('unexpected number type');
        return [false, false];
      }
    }
    
    else if (scanner.scan(/^(\w)+[\?\!]?/)) {
      switch (scanner.matched) {
        case 'class':
          if (this.lex_state == EXPR_DOT) {
            this.lex_state = EXPR_END;
            return ["IDENTIFIER", scanner.matched];
          }
          this.lex_state = EXPR_CLASS;
          return ["CLASS", scanner.matched];
        case 'module':
          if (this.lex_state == EXPR_DOT) return ["IDENITFIER", scanner.matched];
          this.lex_state = EXPR_CLASS;
          return ["MODULE", scanner.matched];
        case 'def':
          this.lex_state = EXPR_FNAME;
          return ["DEF", scanner.matched];
        case 'end':
          this.lex_state = EXPR_END;
          return ["END", scanner.matched];
        
        case 'do':
          if (this.cond_p()) {
            this.lex_state = EXPR_BEG;
            return ["DO_COND", scanner.matched];
          }
          else if (this.cmdarg_p() && this.lex_state != EXPR_CMDARG) {
            this.lex_state = EXPR_BEG;
            return ["DO_BLOCK", scanner.matched];
          }

          else if (this.lex_state == EXPR_ENDARG) {
            return ["DO_BLOCK", scanner.matched];
          }
          else {
            this.lex_state = EXPR_BEG;
            return ["DO", scanner.matched];
          }
            
            // this.lex_state = EXPR_BEG;
            // return ["DO", scanner.matched];
          // }
          // this.lex_state = EXPR_BEG;
          // return ["DO_BLOCK", scanner.matched];
        case 'if':
          if (this.lex_state == EXPR_BEG) return ["IF", scanner.matched];
          this.lex_state = EXPR_BEG;
          return ["IF_MOD", scanner.matched];
        case 'unless':
          if (this.lex_state == EXPR_BEG) return ["UNLESS", scanner.matched];
          this.lex_state = EXPR_BEG;
          return ["UNLESS_MOD", scanner.matched];
        case 'else':
          return ["ELSE", scanner.matched];
        case 'elsif':
          return ["ELSIF", scanner.matched];
        case 'self':
          if (this.lex_state !== EXPR_FNAME) this.lex_state = EXPR_END;
          return ["SELF", scanner.matched];
        case 'true':
          this.lex_state = EXPR_END;
          return ["TRUE", scanner.matched];
        case 'false':
          this.lex_state = EXPR_END;
          return ["FALSE", scanner.matched];
        case 'nil':
          this.lex_state = EXPR_END;
          return ["NIL", scanner.matched];
        case '__LINE__':
          this.lex_state = EXPR_END;
          return ["LINE", this._line_number.toString()];
        case '__FILE__':
          this.lex_state = EXPR_END;
          return ["FILE", scanner.matched];
        case 'begin':
          this.lex_state = EXPR_BEG;
          return ["BEGIN", scanner.matched];
        case 'rescue':
        if (this.lex_state == EXPR_DOT || this.lex_state == EXPR_FNAME) return ["IDENTIFIER", scanner.matched];
          if (this.lex_state == EXPR_BEG) return ["RESCUE", scanner.matched];
          this.lex_state = EXPR_BEG;
          return ["RESCUE_MOD", scanner.matched];
        case 'ensure':
          this.lex_state = EXPR_BEG;
          return ["ENSURE", scanner.matched];
        case 'case':
          this.lex_state = EXPR_BEG;
          return ["CASE", scanner.matched];
        case 'when':
          this.lex_state = EXPR_BEG;
          return ["WHEN", scanner.matched];
        case 'or':
          this.lex_state = EXPR_BEG;
          return ["OR", scanner.matched];
        case 'and':
          this.lex_state = EXPR_BEG;
          return ["AND", scanner.matched];
        case 'not':
          this.lex_state = EXPR_BEG;
          return ["NOT", scanner.matched];
        case 'return':
          this.lex_state = EXPR_MID;
          return ["RETURN", scanner.matched];
        case 'next':
          if (this.lex_state == EXPR_DOT) {
            this.lex_state = EXPR_END;
            return ["IDENTIFIER", scanner.matched];
          }

          this.lex_state = EXPR_MID;
          return ["NEXT", scanner.matched];
        case 'break':
          this.lex_state = EXPR_MID;
          return ["BREAK", scanner.matched];
        case 'super':
          this.lex_state = EXPR_ARG;
          return ["SUPER", scanner.matched];
        case 'then':
          return ["THEN", scanner.matched];
        case 'while':
          if (this.lex_state == EXPR_BEG) return ["WHILE", scanner.matched];
          this.lex_state = EXPR_BEG;
          return ["WHILE_MOD", scanner.matched];
        case 'until':
          // generator determines between while and until (mod)
          if (this.lex_state == EXPR_BEG) return ["WHILE", scanner.matched];
          this.lex_state = EXPR_BEG;
          return ["WHILE_MOD", scanner.matched];
        case 'block_given?':
          this.lex_state = EXPR_END;
          return ["BLOCK_GIVEN", scanner.matched];
        case 'yield':
          this.lex_state = EXPR_ARG;
          return ["YIELD", scanner.matched];
        // case 'require':
          // if (this.lex_state == EXPR_DOT || this.lex_state == EXPR_FNAME) {
            // return ["IDENTIFIER", scanner.matched];
          // }
          // this.lex_state = EXPR_MID;
          // return ['REQUIRE', scanner.matched];
      }
      
      var matched = scanner.matched;
      
      if (scanner.peek(2) !== '::' && scanner.scan(/^\:/)) {
        return["LABEL", matched];
      }
      
      if (this.lex_state == EXPR_FNAME) {
        if (scanner.scan(/^=/)) {
          this.lex_state = EXPR_END;
          return ["IDENTIFIER", matched + scanner.matched];
        }
        
        // this.lex_state = EXPR_END;
        // return ["IDENTIFIER", matched];
      }
      
      // IDENTIFIER2, when we have identifer() .. when we dont preceed identifier
      // with :: or .
      // this makes our parser easier and removes conflicts
      // if (this.lex_state !== EXPR_DOT && scanner.peek(1) == '(') {
        // this.lex_state = EXPR_CMDARG;
        // return ["IDENTIFIER2", matched];
      // }
      
      if ([EXPR_BEG, EXPR_DOT, EXPR_MID, EXPR_ARG, EXPR_CMDARG].indexOf(this.lex_state) !== -1) {
        this.lex_state = EXPR_CMDARG;
      }
      else {
        this.lex_state = EXPR_END;
      }
      
      return [/^[A-Z]/.exec(matched) ? "CONSTANT" : "IDENTIFIER", matched];
    }
    
    else {
      
      return [false, false];
    }
    
    return [false, false];
  }
};

