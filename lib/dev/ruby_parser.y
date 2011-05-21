class RubyParser

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
      '{@' '}' BACK_REF2 SYMBOL_BEG STRING_BEG XSTRING_BEG REGEXP_BEG
      WORDS_BEG AWORDS_BEG STRING_DBEG STRING_DVAR STRING_END STRING
      SYMBOL '\\n' '?' ':' ',' SPACE ';' BLOCK_GIVEN

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
      result = "result = val[0];"
    }

bodystmt:
    compstmt opt_rescue opt_else opt_ensure
    {
      result = "result = new this.BodyStatementsNode(
                    val[0], val[1], val[2], val[3]);"
    }

compstmt:
    stmts opt_terms
    {
      result = "result = val[0];"
    }

stmts:
    none
    {
      result = "result = new this.StatementsNode([]);"
    }
  | stmt
    {
      result = "result = new this.StatementsNode([val[0]]);"
    }
  | stmts terms stmt
    {
      result = "val[0].push(val[2]); result = val[0];"
    }

stmt:
    ALIAS fitem fitem
  | ALIAS GVAR GVAR
  | ALIAS GVAR BACK_REF
  | ALIAS GVAR NTH_REF
  | UNDEF undef_list
  | stmt IF_MOD expr_value
    {
      result = "result = new this.IfModNode(val[1], val[2], val[0]);"
    }
  | stmt UNLESS_MOD expr_value
    {
      result = "result = new this.IfModNode(val[1], val[2], val[0]);"
    }
  | stmt WHILE_MOD expr_value
  | stmt UNTIL_MOD expr_value
  | stmt RESCUE_MOD stmt
  | klBEGIN '{@' compstmt '}'
  | klEND '{@' compstmt '}'
  | lhs '=' command_call
    {
      result = "result = new this.AssignNode(val[0], val[2], val[1]);"
    }
  | mlhs '=' command_call
  | var_lhs OP_ASGN command_call
    {
      result = "result = new this.OpAsgnNode(val[1], val[0], val[2]);"
    }
  | primary_value '[@' aref_args ']' OP_ASGN command_call
  | primary_value '.' IDENTIFIER OP_ASGN command_call
  | primary_value '.' CONSTANT OP_ASGN command_call
  | primary_value '::' IDENTIFIER OP_ASGN command_call
  | backref OP_ASGN command_call
  | lhs '=' mrhs
  | mlhs '=' arg_value
  | mlhs '=' mrhs
  | expr

expr:
    command_call
  | expr AND expr
    {
      result = "result = new this.AndNode(val[1], val[0], val[2]);"
    }
  | expr OR expr
    {
      result = "result = [val[1], val[0], val[2]];"
    }
  | NOT expr
    {
      result = "result = ['unary', '!', val[1]];"
    }
  | '!' command_call
    {
      result = "result = ['unary', '!', val[1]];"
    }
  | arg

expr_value:
    expr

command_call:
    command
  | block_command
  | RETURN call_args
    {
      result = "result = new this.ReturnNode(val[0], val[1]);"
    }
  | BREAK call_args
    {
      result = "result = new this.BreakNode(val[0], val[1]);"
    }
  | NEXT call_args
    {
      result = "result = new this.NextNode(val[0], val[1]);"
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
      result = "result = new this.CallNode(null, val[0], val[1]);"
    }
  | operation command_args cmd_brace_block
  | primary_value '.' operation2 command_args =LOWEST
    {
      result = "result = new this.CallNode(val[0], val[2], val[3]);"
    }
  | primary_value '.' operation2 command_args cmd_brace_block
  | primary_value '::' operation2 command_args =LOWEST
    {
      result = "result = ['call', val[0], val[2], val[3]];"
    }
  | primary_value '::' operation2 command_args cmd_brace_block
  | SUPER command_args
    {
      result = "result = new this.SuperNode(val[0], val[1]);"
    }
  | YIELD command_args
    {
      result = "result = new this.YieldNode(val[0], val[1]);"
    }

mlhs:
    mlhs_basic
  | PAREN_BEG mlhs_entry ')'

mlhs_entry:
    mlhs_basic
  | PAREN_BEG mlhs_entry ')'

mlhs_basic:
    mlhs_head
  | mlhs_head mlhs_item
  | mlhs_head SPLAT mlhs_node
  | mlhs_head SPLAT
  | SPLAT mlhs_node
  | SPLAT

mlhs_item:
    mlhs_node
  | PAREN_BEG mlhs_entry ')'

mlhs_head:
    mlhs_item ','
  | mlhs_head mlhs_item ','

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
  | primary_value '[@' aref_args ']'
    {
      result = "result = new this.ArefNode(val[0], val[2]);"
    }
  | primary_value '.' IDENTIFIER
    {
      result = "result = new this.CallNode(val[0], val[2], [[]]);"
    }
  | primary_value '::' IDENTIFIER
  | primary_value '.' CONSTANT
  | primary_value '::' CONSTANT
  | '::@' CONSTANT
  | backref

cname:
    CONSTANT

cpath:
    '::@' cname
    {
      result = "result = ['::', val[1]];"
    }
  | cname
    {
      result = "result = [null, val[0]];"
    }
  | primary_value '::' cname
    {
      result = "result = [val[0], val[2]];"
    }

fname:
    IDENTIFIER
  | CONSTANT
  | FID
  | op
  | reswords

fitem:
    fname
  | symbol

undef_list:
    fitem
  | undef_list ',' fitem

op:
    '|'    | '^'     | '&'    | '<=>'  | '=='    | '==='
  | '=~'   | '>'     | '>='   | '<'    | '<='    | '<<'
  | '>>'   | '+'     | '-'    | '*'    | SPLAT   | '/'
  | '%'    | '**'    | '~'    | '+@'   | '-@'    | '[]'
  | '[]='  | BACK_REF2

reswords:
    LINE     | FILE       | klBEGIN   | klEND    | ALIAS  | AND
  | BEGIN    | BREAK      | CASE      | CLASS    | DEF  | DEFINED
  | DO       | ELSE       | ELSIF     | END      | ENSURE | FALSE
  | FOR      | IN         | MODULE    | NEXT     | NIL    | NOT
  | OR       | REDO       | RESCUE    | RETRY    | RETURN | SELF
  | SUPER    | THEN       | TRUE      | UNDEF    | WHEN   | YIELD
  | IF_MOD   | UNLESS_MOD | WHILE_MOD | UNTIL_MOD | RESCUE_MOD
  | BLOCK_GIVEN

arg:
    lhs '=' arg
    {
      result = "result = new this.AssignNode(val[0], val[2], val[1]);"
    }
  | lhs '=' arg RESCUE_MOD arg
  | var_lhs OP_ASGN arg
    {
      result = "result = new this.OpAsgnNode(val[1], val[0], val[2]);"
    }
  | primary_value '[@' aref_args ']' OP_ASGN arg
  | primary_value '.' IDENTIFIER OP_ASGN arg
  | primary_value '.' CONSTANT OP_ASGN arg
  | primary_value '::' IDENTIFIER OP_ASGN arg
  | primary_value '::' CONSTANT OP_ASGN arg
  | '::@' CONSTANT OP_ASGN arg
  | backref OP_ASGN arg
  | arg '..' arg
    {
      result = "result = ['range', val[1], val[0], val[2]];"
    }
  | arg '...' arg
    {
      result = "result = ['range', val[1], val[0], val[2]];"
    }
  | arg '+' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '-' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '*' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '/' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '%' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '**' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | '-@NUM' INTEGER '**' arg
  | '-@NUM' FLOAT '**' arg
  | '+@' arg
    {
      result = "result = new this.CallNode(val[1], val[0], []);"
    }
  | '-@' arg
    {
      result = "result = new this.CallNode(val[1], val[0], []);"
    }
  | arg '|' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '^' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '&' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '<=>' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '>' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '>=' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '<' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '<=' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '==' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '===' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '!=' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '=~' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '!~' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | '!' arg
    {
      result = "result = new this.CallNode(val[1], val[0], []);"
    }
  | '~' arg
    {
      result = "result = new this.CallNode(val[1], val[0], []);"
    }
  | arg '<<' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '>>' arg
    {
      result = "result = new this.CallNode(val[0], val[1], [[val[2]]]);"
    }
  | arg '&&' arg
    {
      result = "result = new this.AndNode(val[1], val[0], val[2]);"
    }
  | arg '||' arg
    {
      result = "result = new this.OrNode(val[1], val[0], val[2]);"
    }
  | DEFINED opt_nl arg
  | arg '?' arg ':' arg
    {
      result = "result = ['ternary', val[0], val[2], val[4]];"
    }
  | primary

arg_value:
    arg

aref_args:
    none
    {
      result = "result = [[], null];"
    }
  | command opt_nl
  | args trailer
    {
      result = "result = [val[0], null];"
    }
  | args ',' SPLAT arg opt_nl
    {
      result = "result = [val[0], val[3]];"
    }
  | assocs trailer
  | SPLAT arg opt_nl
    {
      result = "result = [[], val[1]];"
    }

paren_args:
    '(' none ')'
    {
      result = "result = [[]];"
    }
  | '(' call_args opt_nl ')'
    {
      result = "result = val[1];"
    }
  | '(' block_call opt_nl ')'
  | '(' args ',' block_call opt_nl ')'

opt_paren_args:
    none
    {
      result = "result = [];"
    }
  | paren_args

call_args:
    command
    {
      result = "result = [[val[0]], null, null, null];"
    }
  | args opt_block_arg
    {
      result = "result = [val[0], null, null, val[1]];"
    }
  | args ',' SPLAT arg_value opt_block_arg
    {
      result = "result = [val[0], val[3], null, val[4]];"
    }
  | assocs opt_block_arg
    {
      result = "result = [null, null, val[0], val[1]];"
    }
  | assocs ',' SPLAT arg_value opt_block_arg
    {
      result = "result = [null, val[3], val[0], val[4]];"
    }
  | args ',' assocs opt_block_arg
    {
      result = "result = [val[0], null, val[2], val[3]];"
    }
  | args ',' assocs ',' SPLAT arg opt_block_arg
    {
      result = "result = [val[0], val[5], val[2], val[6]];"
    }
  | SPLAT arg_value opt_block_arg
    {
      result = "result = [null, val[1], null, val[2]];"
    }
  | block_arg
    {
      result = "result = [null, null, null, val[0]];"
    }

call_args2:
    arg_value ',' args opt_block_arg
  | arg_value ',' block_arg
  | arg_value ',' SPLAT arg_value opt_block_arg
  | arg_value ',' args ',' SPLAT arg_value opt_block_arg
  | assocs opt_block_arg
  | assocs ',' SPLAT arg_value opt_block_arg
  | arg_value ',' assocs opt_block_arg
  | arg_value ',' args ',' assocs opt_block_arg
  | arg_value ',' assocs ',' SPLAT arg_value opt_block_arg
  | arg_value ',' args ',' assocs ',' SPLAT arg_value opt_block_arg
  | SPLAT arg_value opt_block_arg
  | block_arg

command_args:
    {
      result = "this.cmdarg_push(1);"
    }
    open_args
    {
      result = "this.cmdarg_pop(); result = val[1];"
    }

open_args:
    call_args
  | tLPAREN_ARG ')'
    {
      result = "result = [[]];"
    }
  | tLPAREN_ARG call_args2 ')'
    {
      result = "result = val[1];"
    }

block_arg:
    '&@' arg_value
    {
      result = "result = val[1];"
    }

opt_block_arg:
    ',' block_arg
    {
      result = "result = val[1];"
    }
  | none_block_pass
    {
      result = "result = null;"
    }

args:
    arg_value
    {
      result = "result = [val[0]];"
    }
  | args ',' arg_value
    {
      result = "val[0].push(val[2]); result = val[0];"
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
  | BEGIN bodystmt END
    {
      result = "result = new this.BeginNode(val[0], val[1], val[2]);"
    }
  | tLPAREN_ARG expr opt_nl ')'
  | PAREN_BEG compstmt ')'
    {
      result = "result = new this.ParenNode(val[0], val[1], val[2]);"
    }
  | primary_value '::' CONSTANT
    {
      result = "result = new this.Colon2Node(val[0], val[2]);"
    }
  | '::@' CONSTANT
    {
      result = "result = new this.Colon3Node(val[1]);"
    }
  | primary_value '[@' aref_args ']'
    {
      result = "result = new this.CallNode(
        val[0], { line: val[0].line, value: '[]' }, val[2]);"
    }
  | '[' aref_args ']'
    {
      result = "result = new this.ArrayNode(val[1], val[0], val[2]);"
    }
  | '{' assoc_list '}'
    {
      result = "result = new this.HashNode(val[1], val[0], val[2]);"
    }
  | RETURN
    {
      result = "result = new this.ReturnNode(val[0], [null]);"
    }
  | YIELD '(' call_args ')'
    {
      result = "result = new this.YieldNode(val[0], val[2]);"
    }
  | YIELD '(' ')'
    {
      result = "result = new this.YieldNode(val[0], []);"
    }
  | YIELD
    {
      result = "result = new this.YieldNode(val[0], []);"
    }
  | DEFINED opt_nl '(' expr ')'
  | operation brace_block
    {
      result = "result = new this.CallNode(null, val[0], []);
                result.block = val[1];"
    }
  | method_call
  | method_call brace_block
    {
      result = "result = val[0];
                result.block = val[1];"
    }
  | IF expr_value then compstmt if_tail END
    {
      result = "result = new this.IfNode(
        val[0], val[1], val[3], val[4], val[5]);"
    }
  | UNLESS expr_value then compstmt opt_else END
    {
      result = "result = new this.IfNode(
        val[0], val[1], val[3], val[4], val[5]);"
    }
  | WHILE
    {
      result = "this.cond_push(1);"
    }
    expr_value do
    {
      result = "this.cond_pop();"
    }
    compstmt END
    {
      result = "result = new this.WhileNode(
        val[0], val[2], val[5], val[6]);"
    }
  | UNTIL
    {
      result = "this.cond_push(1);"
    }
    expr_value do
    {
      result = "this.cond_pop();"
    }
    compstmt END
    {
      result = "result = ['while', val[0], val[2], val[5]];"
    }
  | CASE expr_value opt_terms case_body END
    {
      result = "result = ['case', val[1], val[3]];"
    }
  | CASE opt_terms case_body END
    {
      result = "result = ['case', null, val[2]];"
    }
  | CASE opt_terms ELSE compstmt END
  | FOR block_var IN
    {
      result = "this.cond_push(1);"
    }
    expr_value do
    {
      result = "this.cond_pop();"
    }
    compstmt END
  | CLASS cpath superclass bodystmt END
    {
      result = "result = new this.ClassNode(
        val[0], val[1], val[2], val[3], val[4]);"
    }
  | CLASS '<<' expr term bodystmt END
    {
      result = "result = new this.ClassShiftNode(
        val[0], val[2], val[4], val[5]);"
    }
  | MODULE cpath bodystmt END
    {
      result = "result = new this.ModuleNode(
        val[0], val[1], val[2], val[3]);"
    }
  | DEF fname f_arglist bodystmt END
    {
      result = "result = new this.DefNode(
        val[0], null, val[1], val[2], val[3], val[4]);"
    }
  | DEF singleton dot_or_colon fname f_arglist bodystmt END
    {
      result = "result = new this.DefNode(
        val[0], val[1], val[3], val[4], val[5], val[6]);"
    }
  | BREAK
    {
      result = "result = new this.BreakNode(val[0], []);"
    }
  | NEXT
    {
      result = "result = new this.NextNode(val[0], []);"
    }
  | REDO
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
      result = "result = val[0];"
    }
  | ELSIF expr_value then compstmt if_tail
    {
      result = "result = [[val[0], val[1], val[3]]].concat(val[4]);"
    }

opt_else:
    none
    {
      result = "result = [];"
    }
  | ELSE compstmt
    {
      result = "result = [[val[0], val[1]]];"
    }

block_var:
    block_var_args
    {
      result = "result = [val[0], null];"
    }

block_var_args:
    f_arg ',' f_block_optarg ',' f_rest_arg opt_f_block_arg
    {
      result = "result = [val[0], val[2], val[4], val[5]];"
    }
  | f_arg ',' f_block_optarg opt_f_block_arg
    {
      result = "result = [val[0], val[2], null, val[3]];"
    }
  | f_arg ',' f_rest_arg opt_f_block_arg
    {
      result = "result = [val[0], null, val[2], val[3]];"
    }
  | f_arg opt_f_block_arg
    {
      result = "result = [val[0], null, null, val[1]];"
    }
  | f_block_optarg ',' f_rest_arg opt_f_block_arg
    {
      result = "result = [null, val[0], val[2], val[3]];"
    }
  | f_block_optarg opt_f_block_arg
    {
      result = "result = [null, val[0], null, val[1]];"
    }
  | f_rest_arg opt_f_block_arg
    {
      result = "result = [null, null, val[0], val[1]];"
    }
  | f_block_arg
    {
      result = "result = [null, null, null, val[0]];"
    }

f_block_optarg:
    f_block_opt
    {
      result = "result = [val[0]];"
    }
  | f_block_optarg ',' f_block_opt
    {
      result = "val[0].push(val[2]); result = val[0];"
    }

f_block_opt:
    IDENTIFIER '=' primary_value
    {
      result = "result = [val[0], val[2]];"
    }

opt_block_var:
    none
    {
      result = "result = [null];"
    }
  | '|' '|'
    {
      result = "result = [null];"
    }
  | '||'
    {
      result = "result = [null];"
    }
  | '|' block_var '|'
    {
      result = "result = val[1];"
    }

do_block:
    DO_BLOCK
    {
      # result = "print('doing half command');"
    }
    opt_block_var compstmt END
    {
      result = "result = new this.BlockNode(val[0], val[2], val[3], val[4]);"
    }

block_call:
    command do_block
    {
      result = "result = val[0]; val[0].block = val[1];"
    }
  | block_call '.' operation2 opt_paren_args
  | block_call '::' operation2 opt_paren_args

method_call:
    operation paren_args
    {
      result = "result = new this.CallNode(null, val[0], val[1]);"
    }
  | primary_value '.' operation2 opt_paren_args
    {
      result = "result = new this.CallNode(val[0], val[2], val[3]);"
    }
  | primary_value '::' operation2 paren_args
  | primary_value '::' operation3
  | SUPER paren_args
    {
      result = "result = new this.SuperNode(val[0], val[1]);"
    }
  | SUPER
    {
      result = "result = new this.SuperNode(val[0], []);"
    }

brace_block:
    '{@' opt_block_var compstmt '}'
    {
      result = "result = new this.BlockNode(val[0], val[1], val[2], val[3]);"
    }
  | DO opt_block_var compstmt END
    {
      result = "result = new this.BlockNode(val[0], val[1], val[2], val[3]);"
    }

case_body:
    WHEN when_args then compstmt cases
    {
      result = "result = [['when', val[1], val[3]]].concat(val[4]);"
    }

when_args:
    args
    {
      result = "result = val[0];"
    }
  | args ',' SPLAT arg_value
    {
      result = "result = val[0];"
    }
  | SPLAT arg_value
    {
      result = "result = [];"
    }

cases:
    opt_else
  | case_body

opt_rescue:
    RESCUE exc_list exc_var then compstmt opt_rescue
    {
      result = "result = [[val[0], val[1], val[2], val[4]]];
                result.concat(val[5]);"
    }
  |
    {
      result = "result = [];"
    }

exc_list:
    arg_value
  | mrhs
  | none

exc_var:
    '=>' lhs
    {
      result = "result = val[1];"
    }
  | none
    {
      result = "result = null;"
    }

opt_ensure:
    ENSURE compstmt
  | none

literal:
    numeric
  | symbol
  | dsym

strings:
    string

string:
    string1
  | string string1

string1:
    STRING_BEG string_contents STRING_END
    {
      result = "result = new this.StringNode(val[1], val[2]);"
    }
  | STRING

xstring:
    XSTRING_BEG xstring_contents STRING_END
    {
      result = "result = new this.XStringNode(val[0], val[1], val[2]);"
    }

regexp:
    REGEXP_BEG xstring_contents REGEXP_END
    {
      result = "result = new this.RegexpNode(val[0], val[1]);"
    }

words:
    WORDS_BEG SPACE STRING_END
    {
      result = "result = new this.WordsNode(val[0], [], val[2]);"
    }
  | WORDS_BEG word_list STRING_END
    {
      result = "result = new this.WordsNode(val[0], val[1], val[2]);"
    }

word_list:
    none
    {
      result = "result = [];"
    }
  | word_list word SPACE
    {
      result = "result = val[0].concat([val[1]]);"
    }

word:
    string_content
    {
      result = "result = val[0];"
    }
  | word string_content
    {
      result = "result = val[0].concat([val[1]]);"
    }

awords:
    AWORDS_BEG SPACE STRING_END
    {
      result = "result = new this.WordsNode(val[0], [], val[2]);"
    }
  | AWORDS_BEG qword_list STRING_END
    {
      result = "result = new this.WordsNode(val[0], val[1], val[2]);"
    }

qword_list:
    none
    {
      result = "result = [];"
    }
  | qword_list STRING_CONTENT SPACE
    {
      result = "result = val[0].concat([['string_content', val[1]]]);"
    }

string_contents:
    none
    {
      result = "result = [];"
    }
  | string_contents string_content
    {
      result = "result = val[0]; val[0].push(val[1]);"
    }

xstring_contents:
    none
    {
      result = "result = [];"
    }
  | xstring_contents string_content
    {
      result = "result = val[0]; val[0].push(val[1]);"
    }

string_content:
    STRING_CONTENT
    {
      result = "result = ['string_content', val[0]];"
    }
  | STRING_DVAR string_dvar
    {
      result = "result = ['string_dvar', val[1]];"
    }
  | STRING_DBEG
    {
      result = "this.cond_push(0); this.cmdarg_push(0);"
    }
    compstmt '}'
    {
      result = "this.cond_lexpop(); this.cmdarg_lexpop();
                result = ['string_dbegin', val[2]];"
    }

string_dvar:
    GVAR
  | IVAR
  | CVAR
  | backref


symbol:
    SYMBOL_BEG sym
    {
      result = "result = new this.SymbolNode([val[1]]);"
    }
  | SYMBOL

sym: fname
  | IVAR
  | GVAR
  | CVAR

dsym:
    SYMBOL_BEG xstring_contents STRING_END
    {
      result = "result = ['dsym', val[1]];"
    }

numeric:
    INTEGER
    {
      result = "result = new this.NumericNode(val[0]);"
    }
  | FLOAT
    {
      result = "result = new this.NumericNode(val[0]);"
    }
  | '-@NUM' INTEGER =LOWEST
  | '-@NUM' FLOAT   =LOWEST

variable:
    IDENTIFIER
    {
      result = "result = new this.IdentifierNode(val[0]);"
    }
  | IVAR
    {
      result = "result = new this.IvarNode(val[0]);"
    }
  | GVAR
    {
      result = "result = new this.GvarNode(val[0]);"
    }
  | CONSTANT
    {
      result = "result = new this.ConstantNode(val[0]);"
    }
  | CVAR
    {
      result = "result = ['cvar', val[0]];"
    }
  | NIL
    {
      result = "result = new this.NilNode(val[0]);"
    }
  | SELF
    {
      result = "result = new this.SelfNode(val[0]);"
    }
  | TRUE
    {
      result = "result = new this.TrueNode(val[0]);"
    }
  | FALSE
    {
      result = "result = new this.FalseNode(val[0]);"
    }
  | FILE
    {
      result = "result = new this.FileNode(val[0]);"
    }
  | LINE
    {
      result = "result = new this.LineNode(val[0]);"
    }
  | BLOCK_GIVEN
    {
      result = "result = new this.BlockGivenNode(val[0]);"
    }

var_ref:
    variable

var_lhs:
    variable

backref:
    NTH_REF
  | BACK_REF

superclass:
    term
    {
      result = "result = null;"
    }
  | '<' expr_value term
    {
      result = "result = val[1];"
    }
  | error term
    {
      result = "result = null;"
    }

f_arglist:
    '(' f_args opt_nl ')'
    {
      result = "result = val[1];"
    }
  | f_args term
    {
      result = "result = val[0];"
    }

f_args:
    f_arg ',' f_optarg ',' f_rest_arg opt_f_block_arg
    {
      result = "result = [val[0], val[2], val[4], val[5]];"
    }
  | f_arg ',' f_optarg opt_f_block_arg
    {
      result = "result = [val[0], val[2], null, val[3]];"
    }
  | f_arg ',' f_rest_arg opt_f_block_arg
    {
      result = "result = [val[0], null, val[2], val[3]];"
    }
  | f_arg opt_f_block_arg
    {
      result = "result = [val[0], null, null, val[1]];"
    }
  | f_optarg ',' f_rest_arg opt_f_block_arg
    {
      result = "result = [null, val[0], val[2], val[3]];"
    }
  | f_optarg opt_f_block_arg
    {
      result = "result = [null, val[0], null, val[1]];"
    }
  | f_rest_arg opt_f_block_arg
    {
      result = "result = [null, null, val[0], val[1]];"
    }
  | f_block_arg
    {
      result = "result = [null, null, null, val[0]];"
    }
  |
    {
      result = "result = [null, null, null, null];"
    }

f_norm_arg:
    CONSTANT
    {
      result = "this.yyerror('formal argument cannot be a constant');"
    }
  | IVAR
    {
      result = "this.yyerror('formal argument cannot be an instance variable');"
    }
  | CVAR
    {
      result = "this.yyerror('formal argument cannot be a class variable');"
    }
  | GVAR
    {
      result = "this.yyerror('formal argument cannot be a global variable');"
    }
  | IDENTIFIER

f_arg:
    f_norm_arg
    {
      result = "result = [val[0]];"
    }
  | f_arg ',' f_norm_arg
    {
      result = "val[0].push(val[2]);
                result = val[0];"
    }

f_opt:
    IDENTIFIER '=' arg_value
    {
      result = "result = [val[0], val[2]];"
    }

f_optarg:
    f_opt
    {
      result = "[val[0]];"
    }
  | f_optarg ',' f_opt
    {
      result = "result = val[0]; val[0].push(val[2]);"
    }

restarg_mark:
    '*'
  | SPLAT

f_rest_arg:
    restarg_mark IDENTIFIER
    {
      result = "result = val[1];"
    }
  | restarg_mark
    {
      result = "result = val[0];"
    }

blkarg_mark:
    '&'
  | '&@'

f_block_arg:
    blkarg_mark IDENTIFIER
    {
      result = "result = val[1];"
    }

opt_f_block_arg:
    ',' f_block_arg
    {
      result = "result = val[1];"
    }
  |
    {
      result = "result = null;"
    }

singleton:
    var_ref
    {
      result = "result = val[0];"
    }
  | '(' expr opt_nl ')'
    {
      result = "result = val[1];"
    }

assoc_list:
    none
    {
      result = "result = [];"
    }
  | assocs trailer
    {
      result = "result = val[0];"
    }
  | args trailer
    {
      result = "this.yyerror('unsupported assoc list type');"
    }

assocs:
    assoc
    {
      result = "result = [val[0]];"
    }
  | assocs ',' assoc
    {
      result = "result = val[0]; val[0].push(val[2]);"
    }

assoc:
    arg_value '=>' arg_value
    {
      result = "result = [val[0], val[2]];"
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


