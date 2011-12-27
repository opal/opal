class Opal::Grammar

token CLASS MODULE DEF UNDEF BEGIN RESCUE ENSURE END IF UNLESS
      THEN ELSIF ELSE CASE WHEN WHILE UNTIL FOR BREAK NEXT
      REDO RETRY IN DO DO_COND DO_BLOCK RETURN YIELD SUPER
      SELF NIL TRUE FALSE AND OR NOT IF_MOD UNLESS_MOD WHILE_MOD
      UNTIL_MOD RESCUE_MOD ALIAS DEFINED klBEGIN klEND LINE
      FILE IDENTIFIER FID GVAR IVAR CONSTANT CVAR NTH_REF
      BACK_REF STRING_CONTENT INTEGER FLOAT REGEXP_END '+@'
      '-@' '-@NUM' '**' '<=>' '==' '===' '!=' '>=' '<=' '&&'
      '||' '=~' '!~' '.' '..' '...' '[]' '[]=' '<<' '>>'
      '::' '::@' OP_ASGN '=>' PAREN_BEG '(' ')' tLPAREN_ARG
      ARRAY_BEG ']' tLBRACE tLBRACE_ARG SPLAT '*' '&@' '&'
      '~' '%' '/' '+' '-' '<' '>' '|' '!' '^'
      LCURLY '}' BACK_REF2 SYMBOL_BEG STRING_BEG XSTRING_BEG REGEXP_BEG
      WORDS_BEG AWORDS_BEG STRING_DBEG STRING_DVAR STRING_END STRING
      SYMBOL '\\n' '?' ':' ',' SPACE ';' LABEL

prechigh
  right    '!' '~' '+@'
  right    '**'
  right    '-@NUM' '-@'
  left     '*' '/' '%'
  left     '+' '-'
  left     '<<' '>>'
  left     '&'
  left     '|' '^'
  left     '>' '>=' '<' '<='
  nonassoc '<=>' '==' '===' '!=' '=~' '!~'
  left     '&&'
  left     '||'
  nonassoc '..' '...'
  right    '?' ':'
  left     RESCUE_MOD
  right    '=' OP_ASGN
  nonassoc DEFINED
  right    NOT
  left     OR AND
  nonassoc IF_MOD UNLESS_MOD WHILE_MOD UNTIL_MOD
  nonassoc tLBRACE_ARG
  nonassoc LOWEST
preclow

rule

target:
    compstmt
    {
      result = val[0]
    }

bodystmt:
    compstmt opt_rescue opt_else opt_ensure
    {
      result = new_body val[0], val[1], val[2], val[3]
    }

compstmt:
    stmts opt_terms
    {
      comp = new_compstmt val[0]
      if comp and comp[0] == :begin and comp.size == 2
        result = comp[1]
        result.line = comp.line
      else
        result = comp
      end
    }

stmts:
    none
    {
      result = new_block
    }
  | stmt
    {
      result = new_block val[0]
    }
  | stmts terms stmt
    {
      val[0] << val[2]
      result = val[0]
    }

stmt:
    ALIAS fitem fitem
    {
      result = s(:alias, val[1], val[2])
    }
  | ALIAS GVAR GVAR
    {
      result = s(:valias, val[1].intern, val[2].intern)
    }
  | ALIAS GVAR BACK_REF
  | ALIAS GVAR NTH_REF
    {
      result = s(:valias, val[1].intern, val[2].intern)
    }
  | UNDEF undef_list
    {
      result = val[1]
    }
  | stmt IF_MOD expr_value
    {
      result = new_if val[2], val[0], nil
    }
  | stmt UNLESS_MOD expr_value
    {
      result = new_if val[2], nil, val[0]
    }
  | stmt WHILE_MOD expr_value
    {
      result = s(:while, val[2], val[0], true)
    }
  | stmt UNTIL_MOD expr_value
    {
      result = s(:until, val[2], val[0], true)
    }
  | stmt RESCUE_MOD stmt
  | klBEGIN LCURLY compstmt '}'
  | klEND LCURLY compstmt '}'
  | lhs '=' command_call
    {
      result = new_assign val[0], val[2]
    }
  | mlhs '=' command_call
    {
      result = MlhsAssignNode.new val[1], val[0], val[2]
    }
  | var_lhs OP_ASGN command_call
    {
      result = new_op_asgn val[1].intern, val[0], val[2]
    }
  | primary_value '[@' aref_args ']' OP_ASGN command_call
    # {
      # result = OpAsgnNode.new(val[4], ArefNode.new(val[0], val[2]), val[5])
    # }
  | primary_value '.' IDENTIFIER OP_ASGN command_call
    {
      result = OpAsgnNode.new(val[3], CallNode.new(val[0], val[2], []), val[4])
    }
  | primary_value '.' CONSTANT OP_ASGN command_call
  | primary_value '::' IDENTIFIER OP_ASGN command_call
  | backref OP_ASGN command_call
  | lhs '=' mrhs
  | mlhs '=' arg_value
    {
      result = MlhsAssignNode.new val[1], val[0], val[2]
    }
  | mlhs '=' mrhs
    {
      result = MlhsAssignNode.new val[1], val[0], val[2]
    }
  | expr

expr:
    command_call
  | expr AND expr
    {
      result = s(:and, val[0], val[2])
      result.line = val[0].line
    }
  | expr OR expr
    {
      result = s(:or, val[0], val[2])
      result.line = val[0].line
    }
  | NOT expr
    {
      result = s(:not, val[1])
      result.line = val[1].line
    }
  | '!' command_call
    {
      result = s(:not, val[1])
    }
  | arg

expr_value:
    expr

command_call:
    command
  | block_command
  | RETURN call_args
    {
      args = val[1]
      args = args[1] if args.size == 2
      result = s(:return, args)
    }
  | BREAK call_args
    {
      args = val[1]
      args = args[1] if args.size == 2
      result = s(:break, args)
    }
  | NEXT call_args
    {
      args = val[1]
      args = args[1] if args.size == 2
      result = s(:next, args)
    }

block_command:
    block_call
  | block_call '.' operation2 command_args
  | block_call '::' operation2 command_args

cmd_brace_block:
    tLBRACE_ARG opt_block_var compstmt '}'

command:
    operation command_args =LOWEST
    {
      result = new_call nil, val[0].intern, val[1]
    }
  | operation command_args cmd_brace_block
  | primary_value '.' operation2 command_args =LOWEST
    {
      result = new_call val[0], val[2].intern, val[3]
    }
  | primary_value '.' operation2 command_args cmd_brace_block
  | primary_value '::' operation2 command_args =LOWEST
    {
      result = "result = ['call', val[0], val[2], val[3]];"
    }
  | primary_value '::' operation2 command_args cmd_brace_block
  | SUPER command_args
    {
      result = new_super val[1]
    }
  | YIELD command_args
    {
      result = new_yield val[1]
    }

mlhs:
    mlhs_basic
    {
      result = val[0]
    }
  | PAREN_BEG mlhs_entry ')'
    {
      result = val[1]
    }

mlhs_entry:
    mlhs_basic
    {
      result = val[0]
    }
  | PAREN_BEG mlhs_entry ')'
    {
      result = val[1]
    }

mlhs_basic:
    mlhs_head
    {
      result = [val[0]]
    }
  | mlhs_head mlhs_item
    {
      result = [val[0] << val[1]]
    }
  | mlhs_head SPLAT mlhs_node
  | mlhs_head SPLAT
  | SPLAT mlhs_node
  | SPLAT

mlhs_item:
    mlhs_node
    {
      result = val[0]
    }
  | PAREN_BEG mlhs_entry ')'
    {
      result = val[1]
    }

mlhs_head:
    mlhs_item ','
    {
      result = [val[0]]
    }
  | mlhs_head mlhs_item ','
    {
      result = val[0] << val[1]
    }

mlhs_node:
    variable
  | primary_value '[@' aref_args ']'
  | primary_value '.' IDENTIFIER
  | primary_value '::' IDENTIFIER
  | primary_value '.' CONSTANT
  | primary_value '::' CONSTANT
  | '::@' CONSTANT
  | backref

lhs:
    variable
    {
      result = new_assignable val[0]
    }
  | primary_value '[@' aref_args ']'
    {
      args = val[2]
      args[0] = :arglist if args[0] == :array
      result = s(:attrasgn, val[0], :[]=, args)
    }
  | primary_value '.' IDENTIFIER
    {
      result = s(:attrasgn, val[0], "#{val[2]}=".intern, s(:arglist))
    }
  | primary_value '::' IDENTIFIER
    {
      result = s(:attrasgn, val[0], "#{val[2]}=".intern, s(:arglist))
    }
  | primary_value '.' CONSTANT
    {
      result = s(:attrasgn, val[0], "#{val[2]}=".intern, s(:arglist))
    }
  | primary_value '::' CONSTANT
  | '::@' CONSTANT
  | backref

cname:
    CONSTANT

cpath:
    '::@' cname
    {
      result = s(:colon3, val[1].intern)
    }
  | cname
    {
      result = val[0].intern
    }
  | primary_value '::' cname
    {
      result = s(:colon2, val[0], val[2].intern)
    }

fname:
    IDENTIFIER
  | CONSTANT
  | FID
  | op
    {
      @lex_state = :expr_end
      result = val[0]
    }
  | reswords

fitem:
    fname
    {
      result = s(:lit, val[0].intern)
    }
  | symbol
    {
      result = s(:lit, val[0])
    }

undef_list:
    fitem
    {
      result = s(:undef, val[0])
    }
  | undef_list ',' fitem
    {
      result = val[0] << val[2]
    }

op:
    '|'    | '^'     | '&'    | '<=>'  | '=='    | '==='
  | '=~'   | '>'     | '>='   | '<'    | '<='    | '<<'
  | '>>'   | '+'     | '-'    | '*'    | SPLAT   | '/'
  | '%'    | '**'    | '~'    | '+@'   | '-@'    | '[]'
  | '[]='  | BACK_REF2 | '!'  | '!='

reswords:
    LINE     | FILE       | klBEGIN   | klEND    | ALIAS  | AND
  | BEGIN    | BREAK      | CASE      | CLASS    | DEF  | DEFINED
  | DO       | ELSE       | ELSIF     | END      | ENSURE | FALSE
  | FOR      | IN         | MODULE    | NEXT     | NIL    | NOT
  | OR       | REDO       | RESCUE    | RETRY    | RETURN | SELF
  | SUPER    | THEN       | TRUE      | UNDEF    | WHEN   | YIELD
  | IF_MOD   | UNLESS_MOD | WHILE_MOD | UNTIL_MOD | RESCUE_MOD 

arg:
    lhs '=' arg
    {
      result = new_assign val[0], val[2]
    }
  | lhs '=' arg RESCUE_MOD arg
  | var_lhs OP_ASGN arg
    {
      result = new_op_asgn val[1].intern, val[0], val[2]
    }
  | primary_value '[@' aref_args ']' OP_ASGN arg
    {
      result = OpAsgnNode.new val[4], ArefNode.new(val[0], val[2]), val[5]
    }
  | primary_value '.' IDENTIFIER OP_ASGN arg
    {
      result = OpAsgnNode.new(val[3], CallNode.new(val[0], val[2], [[]]), val[4])
    }
  | primary_value '.' CONSTANT OP_ASGN arg
  | primary_value '::' IDENTIFIER OP_ASGN arg
  | primary_value '::' CONSTANT OP_ASGN arg
  | '::@' CONSTANT OP_ASGN arg
  | backref OP_ASGN arg
  | arg '..' arg
    {
      result = s(:dot2, val[0], val[2])
      result.line = val[0].line
    }
  | arg '...' arg
    {
      result = s(:dot3, val[0], val[2])
      result.line = val[0].line
    }
  | arg '+' arg
    {
      result = new_call val[0], :"+", s(:arglist, val[2])
    }
  | arg '-' arg
    {
      result = new_call val[0], :"-", s(:arglist, val[2])
    }
  | arg '*' arg
    {
      result = new_call val[0], :"*", s(:arglist, val[2])
    }
  | arg '/' arg
    {
      result = new_call val[0], :"/", s(:arglist, val[2])
    }
  | arg '%' arg
    {
      result = new_call val[0], :"%", s(:arglist, val[2])
    }
  | arg '**' arg
    {
      result = new_call val[0], :"**", s(:arglist, val[2])
    }
  | '-@NUM' INTEGER '**' arg
  | '-@NUM' FLOAT '**' arg
  | '+@' arg
    {
      result = new_call val[1], :"+@", s(:arglist)
      result = val[1] if val[1][0] == :lit and Numeric === val[1][1]
    }
  | '-@' arg
    {
      result = new_call val[1], :"-@", s(:arglist)
      if val[1][0] == :lit and Numeric === val[1][1]
        val[1][1] = -val[1][1]
        result = val[1]
      end
    }
  | arg '|' arg
    {
      result = new_call val[0], :"|", s(:arglist, val[2])
    }
  | arg '^' arg
    {
      result = new_call val[0], :"^", s(:arglist, val[2])
    }
  | arg '&' arg
    {
      result = new_call val[0], :"&", s(:arglist, val[2])
    }
  | arg '<=>' arg
    {
      result = new_call val[0], :"<=>", s(:arglist, val[2])
    }
  | arg '>' arg
    {
      result = new_call val[0], :">", s(:arglist, val[2])
    }
  | arg '>=' arg
    {
      result = new_call val[0], :">=", s(:arglist, val[2])
    }
  | arg '<' arg
    {
      result = new_call val[0], :"<", s(:arglist, val[2])
    }
  | arg '<=' arg
    {
      result = new_call val[0], :"<=", s(:arglist, val[2])
    }
  | arg '==' arg
    {
      result = new_call val[0], :"==", s(:arglist, val[2])
    }
  | arg '===' arg
    {
      result = new_call val[0], :"===", s(:arglist, val[2])
    }
  | arg '!=' arg
    {
      result = s(:not, new_call(val[0], :"==", s(:arglist, val[2])))
    }
  | arg '=~' arg
    {
      result = new_call val[0], :"=~", s(:arglist, val[2])
    }
  | arg '!~' arg
    {
      result = s(:not, new_call(val[0], :"=~", s(:arglist, val[2])))
    }
  | '!' arg
    {
      result = s(:not, val[1])
    }
  | '~' arg
    {
      result = new_call val[1], :"~", s(:arglist)
    }
  | arg '<<' arg
    {
      result = new_call val[0], :"<<", s(:arglist, val[2])
    }
  | arg '>>' arg
    {
      result = new_call val[0], :">>", s(:arglist, val[2])
    }
  | arg '&&' arg
    {
      result = s(:and, val[0], val[2])
      result.line = val[0].line
    }
  | arg '||' arg
    {
      result = s(:or, val[0], val[2])
      result.line = val[0].line
    }
  | DEFINED opt_nl arg
  | arg '?' arg ':' arg
    {
      result = s(:if, val[0], val[2], val[4])
      result.line = val[0].line
    }
  | primary

arg_value:
    arg

aref_args:
    none
    {
      result = nil
    }
  | args trailer
    {
      result = val[0]
    }
  | assocs trailer
    {
      result = s(:array, val[0])
      #result.line = val[0].line
      # FIXME:
      result = s(:array)
    }

paren_args:
    '(' none ')'
    {
      result = nil
    }
  | '(' call_args opt_nl ')'
    {
      result = val[1]
    }
  | '(' block_call opt_nl ')'
  | '(' args ',' block_call opt_nl ')'

opt_paren_args:
    none
  | paren_args

call_args:
    command
    {
      result = s(:array, val[0])
    }
  | args opt_block_arg
    {
      result = val[0]
      add_block_pass val[0], val[1]
    }
  | assocs opt_block_arg
    {
      result = s(:arglist, s(:hash, *val[0]))
      add_block_pass result, val[1]
    }
  | args ',' assocs opt_block_arg
    {
      result = val[0]
      result << s(:hash, *val[2])
    }
  | block_arg
    {
      result = s(:arglist)
      add_block_pass result, val[0]
    }

call_args2:
    arg_value ',' args opt_block_arg
  | block_arg

command_args:
    {
      cmdarg_push 1
    }
    open_args
    {
      cmdarg_pop
      result = val[1]
    }

open_args:
    call_args
  | tLPAREN_ARG ')'
    {
      result = nil
    }
  | tLPAREN_ARG call_args2 ')'
    {
      result = val[1]
    }

block_arg:
    '&@' arg_value
    {
      result = s(:block_pass, val[1])
    }

opt_block_arg:
    ',' block_arg
    {
      result = val[1]
    }
  | none_block_pass
    {
      result = nil
    }

args:
    arg_value
    {
      result = s(:array, val[0])
    }
  | SPLAT arg_value
    {
      result = s(:array, s(:splat, val[1]))
    }
  | args ',' arg_value
    {
      result = val[0] << val[2]
    }
  | args ',' SPLAT arg_value
    {
      result  = val[0] << s(:splat, val[3])
    }

mrhs:
    args ',' arg_value
  | args ',' SPLAT arg_value
  | SPLAT arg_value

primary:
    literal
  | strings
  | xstring
  | regexp
  | words
  | awords
  | var_ref
  | backref
  | FID
  | BEGIN
    {
      result = @line
    }
    bodystmt END
    {
      result = s(:begin, val[2])
      result.line = val[1]
    }
  | tLPAREN_ARG expr opt_nl ')'
  | PAREN_BEG compstmt ')'
    {
      result = val[1] || s(:nil)
    }
  | primary_value '::' CONSTANT
    {
      result = s(:colon2, val[0], val[2].intern)
    }
  | '::@' CONSTANT
    {
      result = s(:colon3, val[1])
    }
  | primary_value '[@' aref_args ']'
    {
      result = new_call val[0], :[], val[2]
    }
  | '[' aref_args ']'
    {
      result = val[1] || s(:array)
    }
  | '{' assoc_list '}'
    {
      result = s(:hash, *val[1])
    }
  | RETURN
    {
      result = s(:return)
    }
  | YIELD '(' call_args ')'
    {
      result = new_yield val[2]
    }
  | YIELD '(' ')'
    {
      result = s(:yield)
    }
  | YIELD
    {
      result = s(:yield)
    }
  | DEFINED opt_nl '(' expr ')'
    {
      result = s(:defined, val[3])
    }
  | operation brace_block
    {
      result = val[1]
      result[1] = new_call(nil, val[0].intern, s(:arglist))
    }
  | method_call
  | method_call brace_block
    {
      result = val[1]
      result[1] = val[0]
    }
  | IF expr_value then compstmt if_tail END
    {
      result = new_if val[1], val[3], val[4]
    }
  | UNLESS expr_value then compstmt opt_else END
    {
      result = new_if val[1], val[4], val[3]
    }
  | WHILE
    {
      cond_push 1
      result = @line
    }
    expr_value do
    {
      cond_pop
    }
    compstmt END
    {
      result = s(:while, val[2], val[5], true)
      result.line = val[1]
    }
  | UNTIL
    {
      cond_push 1
      result = @line
    }
    expr_value do
    {
      cond_pop
    }
    compstmt END
    {
      result = s(:until, val[2], val[5], true)
      result.line = val[1]
    }
  | CASE expr_value opt_terms case_body END
    {
      result = s(:case, val[1], *val[3])
      result.line = val[1].line
    }
  | CASE opt_terms case_body END
    {
      result = s(:case, nil, *val[2])
      result.line = val[2].line
    }
  | CASE opt_terms ELSE compstmt END
    {
      result = s(:case, nil, val[3])
      result.line = val[3].line
    }
  | FOR block_var IN
    {
      result = "this.cond_push(1);"
    }
    expr_value do
    {
      result = "this.cond_pop();"
    }
    compstmt END
  | CLASS
    {
      result = @line
    }
    cpath superclass
    {
      # ...
    }
    bodystmt END
    {
      result = new_class val[2], val[3], val[5]
      result.line = val[1]
      result.end_line = @line
    }
  | CLASS '<<'
    {
      result = @line
    }
    expr term
    {
      # ...
    }
    bodystmt END
    {
      result = new_sclass val[3], val[6]
      result.line = val[2]
    }
  | MODULE
    {
      result = @line
    }
    cpath
    {
      # ...
    }
    bodystmt END
    {
      result = new_module val[2], val[4]
      result.line = val[1]
    }
  | DEF fname
    {
      result = @scope_line
      push_scope
    }
    f_arglist bodystmt END
    {
      result = new_defn val[2], val[1], val[3], val[4]
      pop_scope
    }
  | DEF singleton dot_or_colon
    {
       # ..
    }
    fname
    {
      result = @scope_line
      push_scope
    }
    f_arglist bodystmt END
    {
      result = new_defs val[5], val[1], val[4], val[6], val[7]
      pop_scope
    }
  | BREAK
    {
      result = s(:break)
    }
  | NEXT
    {
      result = s(:next)
    }
  | REDO
    {
      result = s(:redo)
    }
  | RETRY

primary_value:
    primary

then:
    term
  | ':'
  | THEN
  | term THEN

do:
    term
  | ':'
  | DO_COND

if_tail:
    opt_else
    {
      result = val[0]
    }
  | ELSIF
    {
      result = @line
    }
    expr_value then compstmt if_tail
    {
      result = s(:if, val[2], val[4], val[5])
      result.line = val[1]
    }

opt_else:
    none
  | ELSE compstmt
    {
      result = val[1]
    }

block_var:
    block_var_args
    {
      result = val[0]
    }

block_var_args:
    f_arg ',' f_block_optarg ',' f_rest_arg opt_f_block_arg
    {
      result = new_block_args val[0], val[2], val[4], val[5]
    }
  | f_arg ',' f_block_optarg opt_f_block_arg
    {
      result = new_block_args val[0], val[2], nil, val[3]
    }
  | f_arg ',' f_rest_arg opt_f_block_arg
    {
      result = new_block_args val[0], nil, val[2], val[3]
    }
  | f_arg opt_f_block_arg
    {
      result = new_block_args val[0], nil, nil, val[1]
    }
  | f_block_optarg ',' f_rest_arg opt_f_block_arg
    {
      result = new_block_args nil, val[0], val[2], val[3]
    }
  | f_block_optarg opt_f_block_arg
    {
      result = new_block_args nil, val[0], nil, val[1]
    }
  | f_rest_arg opt_f_block_arg
    {
      result = new_block_args nil, nil, val[0], val[1]
    }
  | f_block_arg
    {
      result = new_block_args nil, nil, nil, val[0]
    }

f_block_optarg:
    f_block_opt
    {
      result = s(:block, val[0])
    }
  | f_block_optarg ',' f_block_opt
    {
      val[0] << val[2]
      result = val[0]
    }

f_block_opt:
    IDENTIFIER '=' primary_value
    {
      result = new_assign new_assignable(s(:identifier, val[0].intern)), val[2]
    }

opt_block_var:
    none
  | '|' '|'
    {
      result = 0
    }
  | '||'
    {
      result = 0
    }
  | '|' block_var '|'
    {
      result = val[1]
    }

do_block:
    DO_BLOCK
    {
      push_scope :block
      result = @line
    }
    opt_block_var compstmt END
    {
      result = new_iter nil, val[2], val[3]
      result.line = val[1]
      pop_scope
    }

block_call:
    command do_block
    {
      result = val[1]
      result[1] = val[0]
    }
  | block_call '.' operation2 opt_paren_args
  | block_call '::' operation2 opt_paren_args

method_call:
    operation paren_args
    {
      result = new_call nil, val[0].intern, val[1]
    }
  | primary_value '.' operation2 opt_paren_args
    {
      result = new_call val[0], val[2].intern, val[3]
    }
  | primary_value '::' operation2 paren_args
  | primary_value '::' operation3
  | SUPER paren_args
    {
      result = new_super val[1]
    }
  | SUPER
    {
      result = s(:zsuper)
    }

brace_block:
    LCURLY
    {
      push_scope :block
      result = @line
    }
    opt_block_var compstmt '}'
    {
      result = new_iter nil, val[2], val[3]
      result.line = val[1]
      pop_scope
    }
  | DO
    {
      push_scope :block
      result = @line
    }
    opt_block_var compstmt END
    {
      result = new_iter nil, val[2], val[3]
      result.line = val[1]
      pop_scope
    }

case_body:
    WHEN
    {
      result = @line
    }
    args then compstmt cases
    {
      part = s(:when, val[2], val[4])
      part.line = val[2].line
      result = [part]
      result.push *val[5] if val[5]
    }

cases:
    opt_else
    {
      result = [val[0]]
    }
  | case_body

opt_rescue:
    RESCUE exc_list exc_var then compstmt opt_rescue
    {
      exc = val[1] || s(:array)
      exc << new_assign(val[2], s(:gvar, '$!'.intern)) if val[2]
      result = [s(:resbody, exc, val[4])]
      result.push val[5].first if val[5]
    }
  |
    {
      result = nil
    }

exc_list:
    arg_value
    {
      result = s(:array, val[0])
    }
  | mrhs
  | none

exc_var:
    '=>' lhs
    {
      result = val[1]
    }
  | none
    {
      result = nil
    }

opt_ensure:
    ENSURE compstmt
    {
      result = val[1].nil? ? s(:nil) : val[1]
    }
  | none

literal:
    numeric
    {
      result = s(:lit, val[0])
    }
  | symbol
    {
      result = s(:lit, val[0])
    }
  | dsym

strings:
    string
    {
      result = new_str val[0]
    }

string:
    string1
  | string string1

string1:
    STRING_BEG string_contents STRING_END
    {
      result = val[1]
    }
  | STRING

xstring:
    XSTRING_BEG xstring_contents STRING_END
    {
      result = new_xstr val[1]
    }

regexp:
    REGEXP_BEG xstring_contents REGEXP_END
    {
      result = new_regexp val[1]
    }

words:
    WORDS_BEG SPACE STRING_END
    {
      result = s(:array)
    }
  | WORDS_BEG word_list STRING_END
    {
      result = val[1]
    }

word_list:
    none
    {
      result = s(:array)
    }
  | word_list word SPACE
    {
      part = val[1]
      part = s(:dstr, "", val[1]) if part[0] == :evstr
      result = val[0] << part
    }

word:
    string_content
    {
      result = val[0]
    }
  | word string_content
    {
      result = val[0].concat([val[1]])
    }

awords:
    AWORDS_BEG SPACE STRING_END
    {
      result = s(:array)
    }
  | AWORDS_BEG qword_list STRING_END
    {
      result = val[1]
    }

qword_list:
    none
    {
      result = s(:array)
    }
  | qword_list STRING_CONTENT SPACE
    {
      result = val[0] << s(:str, val[1])
    }

string_contents:
    none
    {
      result = nil
    }
  | string_contents string_content
    {
      result = str_append val[0], val[1]
    }

xstring_contents:
    none
    {
      result = nil
    }
  | xstring_contents string_content
    {
      result = str_append val[0], val[1]
    }

string_content:
    STRING_CONTENT
    {
      result = s(:str, val[0])
    }
  | STRING_DVAR
    {
      result = @string_parse
      @string_parse = nil
    }
    string_dvar
    {
      @string_parse = val[1]
      result = s(:evstr, val[2])
    }
  | STRING_DBEG
    {
      cond_push 0
      cmdarg_push 0
      result = @string_parse
      @string_parse = nil
    }
    compstmt '}'
    {
      @string_parse = val[1]
      cond_lexpop
      cmdarg_lexpop
      result = s(:evstr, val[2])
    }

string_dvar:
    GVAR
    {
      result = s(:gvar, val[0].intern)
    }
  | IVAR
    {
      result = s(:ivar, val[0].intern)
    }
  | CVAR
    {
      result = s(:cvar, val[0].intern)
    }
  | backref


symbol:
    SYMBOL_BEG sym
    {
      result = val[1].intern
    }
  | SYMBOL

sym: fname
  | IVAR
  | GVAR
  | CVAR

dsym:
    SYMBOL_BEG xstring_contents STRING_END
    {
      result = new_dsym val[1]
    }

numeric:
    INTEGER
  | FLOAT
  | '-@NUM' INTEGER =LOWEST
  | '-@NUM' FLOAT   =LOWEST

variable:
    IDENTIFIER
    {
      result = s(:identifier, val[0].intern)
    }
  | IVAR
    {
      result = s(:ivar, val[0].intern)
    }
  | GVAR
    {
      result = s(:gvar, val[0].intern)
    }
  | CONSTANT
    {
      result = s(:const, val[0].intern)
    }
  | CVAR
    {
      result = s(:cvar, val[0].intern)
    }
  | NIL
    {
      result = s(:nil)
    }
  | SELF
    {
      result = s(:self)
    }
  | TRUE
    {
      result = s(:true)
    }
  | FALSE
    {
      result = s(:false)
    }
  | FILE
    {
      result = s(:str, @file)
    }
  | LINE
    {
      result = s(:lit, @line)
    }

var_ref:
    variable
    {
      result = new_var_ref val[0]
    }

var_lhs:
    variable
    {
      result = new_assignable val[0]
    }

backref:
    NTH_REF
  | BACK_REF

superclass:
    term
    {
      result = nil
    }
  | '<' expr_value term
    {
      result = val[1]
    }
  | error term
    {
      result = nil
    }

f_arglist:
    '(' f_args opt_nl ')'
    {
      result = val[1]
    }
  | f_args term
    {
      result = val[0]
    }

f_args:
    f_arg ',' f_optarg ',' f_rest_arg opt_f_block_arg
    {
      result = new_args val[0], val[2], val[4], val[5]
    }
  | f_arg ',' f_optarg opt_f_block_arg
    {
      result = new_args val[0], val[2], nil, val[3]
    }
  | f_arg ',' f_rest_arg opt_f_block_arg
    {
      result = new_args val[0], nil, val[2], val[3]
    }
  | f_arg opt_f_block_arg
    {
      result = new_args val[0], nil, nil, val[1]
    }
  | f_optarg ',' f_rest_arg opt_f_block_arg
    {
      result = new_args nil, val[0], val[2], val[3]
    }
  | f_optarg opt_f_block_arg
    {
      result = new_args nil, val[0], nil, val[1]
    }
  | f_rest_arg opt_f_block_arg
    {
      result = new_args nil, nil, val[0], val[1]
    }
  | f_block_arg
    {
      result = new_args nil, nil, nil, val[0]
    }
  |
    {
      result = s(:args)
    }

f_norm_arg:
    CONSTANT
    {
      raise 'formal argument cannot be a constant'
    }
  | IVAR
    {
      raise 'formal argument cannot be an instance variable'
    }
  | CVAR
    {
      raise 'formal argument cannot be a class variable'
    }
  | GVAR
    {
      raise 'formal argument cannot be a global variable'
    }
  | IDENTIFIER
    {
      result = val[0].intern
      @scope.add_local result
    }

f_arg:
    f_norm_arg
    {
      result = [val[0]]
    }
  | f_arg ',' f_norm_arg
    {
      val[0] << val[2]
      result = val[0]
    }

f_opt:
    IDENTIFIER '=' arg_value
    {
      result = new_assign new_assignable(s(:identifier, val[0].intern)), val[2]
    }

f_optarg:
    f_opt
    {
      result = s(:block, val[0])
    }
  | f_optarg ',' f_opt
    {
      result = val[0]
      val[0] << val[2]
    }

restarg_mark:
    '*'
  | SPLAT

f_rest_arg:
    restarg_mark IDENTIFIER
    {
      result = "*#{val[1]}".intern
    }
  | restarg_mark
    {
      result = :"*"
    }

blkarg_mark:
    '&'
  | '&@'

f_block_arg:
    blkarg_mark IDENTIFIER
    {
      result = "&#{val[1]}".intern
    }

opt_f_block_arg:
    ',' f_block_arg
    {
      result = val[1]
    }
  |
    {
      result = nil
    }

singleton:
    var_ref
    {
      result = val[0]
    }
  | '(' expr opt_nl ')'
    {
      result = val[1]
    }

assoc_list:
    none
    {
      result = []
    }
  | assocs trailer
    {
      result = val[0]
    }
  | args trailer
    {
      raise "unsupported assoc list type (#@line_number)"
    }

assocs:
    assoc
    {
      result = val[0]
    }
  | assocs ',' assoc
    {
      result = val[0].push *val[2]
    }

assoc:
    arg_value '=>' arg_value
    {
      result = [val[0], val[2]]
    }
  | LABEL arg_value
    {
      result = [s(:lit, val[0].intern), val[1]]
    }

operation:
    IDENTIFIER
  | CONSTANT
  | FID

operation2:
    IDENTIFIER
  | CONSTANT
  | FID
  | op

operation3:
    IDENTIFIER
  | FID
  | op

dot_or_colon:
    '.'
  | '::'

opt_terms:
  | terms

opt_nl:
  | '\\n'

trailer:
  | '\\n'
  | ','

term:
    ';'
  | '\\n'

terms:
    term
  | terms ';'

none:

none_block_pass:

end

---- inner
