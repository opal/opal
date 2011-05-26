class Opal::RubyParser

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
      result = val[0]
    }

bodystmt:
    compstmt opt_rescue opt_else opt_ensure
    {
      result = BodyStatementsNode.new val[0], val[1], val[2], val[3]
    }

compstmt:
    stmts opt_terms
    {
      result = val[0]
    }

stmts:
    none
    {
      result = StatementsNode.new []
    }
  | stmt
    {
      result = StatementsNode.new [val[0]]
    }
  | stmts terms stmt
    {
      val[0] << val[2]
      result = val[0]
    }

stmt:
    ALIAS fitem fitem
  | ALIAS GVAR GVAR
  | ALIAS GVAR BACK_REF
  | ALIAS GVAR NTH_REF
  | UNDEF undef_list
  | stmt IF_MOD expr_value
    {
      result = IfNode.new val[1], val[2], StatementsNode.new([val[0]]), [], val[1]
    }
  | stmt UNLESS_MOD expr_value
    {
      result = IfModNode.new val[1], val[2], val[0]
    }
  | stmt WHILE_MOD expr_value
    {
      result = WhileNode.new val[1], val[2], StatementsNode.new([val[0]]), val[1]
    }
  | stmt UNTIL_MOD expr_value
    {
      result = WhileNode.new val[1], val[2], StatementsNode.new([val[0]]), val[1]
    }
  | stmt RESCUE_MOD stmt
  | klBEGIN '{@' compstmt '}'
  | klEND '{@' compstmt '}'
  | lhs '=' command_call
    {
      result = AssignNode.new val[0], val[2], val[1]
    }
  | mlhs '=' command_call
    {
      result = MlhsAssignNode.new val[1], val[0], val[2]
    }
  | var_lhs OP_ASGN command_call
    {
      result = OpAsgnNode.new val[1], val[0], val[2]
    }
  | primary_value '[@' aref_args ']' OP_ASGN command_call
  | primary_value '.' IDENTIFIER OP_ASGN command_call
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
      result = AndNode.new val[1], val[0], val[2]
    }
  | expr OR expr
    {
      result = OrNode.new val[1], val[0], val[2]
    }
  | NOT expr
    {
      result = CallNode.new val[1], {:value => '!', :line => 0}, []
    }
  | '!' command_call
    {
      result = CallNode.new val[1], val[0], []
    }
  | arg

expr_value:
    expr

command_call:
    command
  | block_command
  | RETURN call_args
    {
      result = ReturnNode.new val[0], val[1]
    }
  | BREAK call_args
    {
      result = BreakNode.new val[0], val[1]
    }
  | NEXT call_args
    {
      result = NextNode.new val[0], val[1]
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
      result = CallNode.new nil, val[0], val[1]
    }
  | operation command_args cmd_brace_block
  | primary_value '.' operation2 command_args =LOWEST
    {
      result = CallNode.new val[0], val[2], val[3]
    }
  | primary_value '.' operation2 command_args cmd_brace_block
  | primary_value '::' operation2 command_args =LOWEST
    {
      result = "result = ['call', val[0], val[2], val[3]];"
    }
  | primary_value '::' operation2 command_args cmd_brace_block
  | SUPER command_args
    {
      result = SuperNode.new val[0], val[1]
    }
  | YIELD command_args
    {
      result = YieldNode.new val[0], val[1]
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
  | primary_value '[@' aref_args ']'
    {
      result = ArefNode.new val[0], val[2]
    }
  | primary_value '.' IDENTIFIER
    {
      result = CallNode.new val[0], val[2], [[]]
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
      result = [nil, val[0]]
    }
  | primary_value '::' cname
    {
      result = [val[0], val[2]]
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
      result = AssignNode.new val[0], val[2], val[1]
    }
  | lhs '=' arg RESCUE_MOD arg
  | var_lhs OP_ASGN arg
    {
      result = OpAsgnNode.new val[1], val[0], val[2]
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
      result = RangeNode.new val[1], val[0], val[2]
    }
  | arg '...' arg
    {
      result = RangeNode.new val[1], val[0], val[2]
    }
  | arg '+' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '-' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '*' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '/' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '%' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '**' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | '-@NUM' INTEGER '**' arg
  | '-@NUM' FLOAT '**' arg
  | '+@' arg
    {
      result = CallNode.new val[1], val[0], []
    }
  | '-@' arg
    {
      result = CallNode.new val[1], val[0], []
    }
  | arg '|' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '^' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '&' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '<=>' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '>' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '>=' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '<' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '<=' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '==' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '===' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '!=' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '=~' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '!~' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | '!' arg
    {
      result = CallNode.new val[1], val[0], []
    }
  | '~' arg
    {
      result = CallNode.new val[1], val[0], []
    }
  | arg '<<' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '>>' arg
    {
      result = CallNode.new val[0], val[1], [[val[2]]]
    }
  | arg '&&' arg
    {
      result = AndNode.new val[1], val[0], val[2]
    }
  | arg '||' arg
    {
      result = OrNode.new val[1], val[0], val[2]
    }
  | DEFINED opt_nl arg
  | arg '?' arg ':' arg
    {
      result = val[0]
      # FIXME
      # result = "result = ['ternary', val[0], val[2], val[4]];"
    }
  | primary

arg_value:
    arg

aref_args:
    none
    {
      result = [[], nil]
    }
  | command opt_nl
  | args trailer
    {
      result = [val[0], nil]
    }
  | args ',' SPLAT arg opt_nl
    {
      result = [val[0], val[3]]
    }
  | assocs trailer
    {
      result = [[HashNode.new(val[0], {}, {})], nil]
    }
  | SPLAT arg opt_nl
    {
      result = [[], val[1]]
    }

paren_args:
    '(' none ')'
    {
      result = [[]]
    }
  | '(' call_args opt_nl ')'
    {
      result = val[1]
    }
  | '(' block_call opt_nl ')'
  | '(' args ',' block_call opt_nl ')'

opt_paren_args:
    none
    {
      result = []
    }
  | paren_args

call_args:
    command
    {
      result = [[val[0]], nil, nil, nil]
    }
  | args opt_block_arg
    {
      result = [val[0], nil, nil, val[1]]
    }
  | args ',' SPLAT arg_value opt_block_arg
    {
      result = [val[0], val[3], nil, val[4]]
    }
  | assocs opt_block_arg
    {
      result = [nil, nil, val[0], val[1]]
    }
  | assocs ',' SPLAT arg_value opt_block_arg
    {
      result = [nil, val[3], val[0], val[4]]
    }
  | args ',' assocs opt_block_arg
    {
      result = [val[0], nil, val[2], val[3]]
    }
  | args ',' assocs ',' SPLAT arg opt_block_arg
    {
      result = [val[0], val[5], val[2], val[6]]
    }
  | SPLAT arg_value opt_block_arg
    {
      result = [nil, val[1], nil, val[2]]
    }
  | block_arg
    {
      result = [nil, nil, nil, val[0]]
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
      result = [[]]
    }
  | tLPAREN_ARG call_args2 ')'
    {
      result = val[1]
    }

block_arg:
    '&@' arg_value
    {
      result = val[1]
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
      result = [val[0]]
    }
  | args ',' arg_value
    {
      result = val[0] << val[2]
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
      result = BeginNode.new val[0], val[1], val[2]
    }
  | tLPAREN_ARG expr opt_nl ')'
  | PAREN_BEG compstmt ')'
    {
      result = ParenNode.new val[0], val[1], val[2]
    }
  | primary_value '::' CONSTANT
    {
      result = Colon2Node.new val[0], val[2]
    }
  | '::@' CONSTANT
    {
      result = Colon3Node.new val[1]
    }
  | primary_value '[@' aref_args ']'
    {
      result = CallNode.new val[0], { :line => val[0].line, :value => '[]' }, val[2]
    }
  | '[' aref_args ']'
    {
      result = ArrayNode.new val[1], val[0], val[2]
    }
  | '{' assoc_list '}'
    {
      result = HashNode.new val[1], val[0], val[2]
    }
  | RETURN
    {
      result = ReturnNode.new val[0], [nil]
    }
  | YIELD '(' call_args ')'
    {
      result = YieldNode.new val[0], val[2]
    }
  | YIELD '(' ')'
    {
      result = YieldNode.new val[0], []
    }
  | YIELD
    {
      result = YieldNode.new val[0], []
    }
  | DEFINED opt_nl '(' expr ')'
  | operation brace_block
    {
      result = CallNode.new nil, val[0], [[]]
      result.block = val[1]
    }
  | method_call
  | method_call brace_block
    {
      result = val[0];
      result.block = val[1]
    }
  | IF expr_value then compstmt if_tail END
    {
      result = IfNode.new val[0], val[1], val[3], val[4], val[5]
    }
  | UNLESS expr_value then compstmt opt_else END
    {
      result = IfNode.new val[0], val[1], val[3], val[4], val[5]
    }
  | WHILE
    {
      cond_push 1
    }
    expr_value do
    {
      cond_pop
    }
    compstmt END
    {
      result = WhileNode.new val[0], val[2], val[5], val[6]
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
      result = CaseNode.new val[0], val[1], val[3], val[4]
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
      result = ClassNode.new val[0], val[1], val[2], val[3], val[4]
    }
  | CLASS '<<' expr term bodystmt END
    {
      result = ClassShiftNode.new val[0], val[2], val[4], val[5]
    }
  | MODULE cpath bodystmt END
    {
      result = ModuleNode.new val[0], val[1], val[2], val[3]
    }
  | DEF fname f_arglist bodystmt END
    {
      result = DefNode.new val[0], nil, val[1], val[2], val[3], val[4]
    }
  | DEF singleton dot_or_colon fname f_arglist bodystmt END
    {
      result = DefNode.new val[0], val[1], val[3], val[4], val[5], val[6]
    }
  | BREAK
    {
      result = BreakNode.new val[0], []
    }
  | NEXT
    {
      result = NextNode.new val[0], []
    }
  | REDO
    {
      result = RedoNode.new val[0]
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
  | ELSIF expr_value then compstmt if_tail
    {
      result = [[val[0], val[1], val[3]]].concat val[4]
    }

opt_else:
    none
    {
      result = []
    }
  | ELSE compstmt
    {
      result = [[val[0], val[1]]]
    }

block_var:
    block_var_args
    {
      result = [val[0], nil]
    }

block_var_args:
    f_arg ',' f_block_optarg ',' f_rest_arg opt_f_block_arg
    {
      result = [val[0], val[2], val[4], val[5]]
    }
  | f_arg ',' f_block_optarg opt_f_block_arg
    {
      result = [val[0], val[2], nil, val[3]]
    }
  | f_arg ',' f_rest_arg opt_f_block_arg
    {
      result = [val[0], nil, val[2], val[3]]
    }
  | f_arg opt_f_block_arg
    {
      result = [val[0], nil, nil, val[1]]
    }
  | f_block_optarg ',' f_rest_arg opt_f_block_arg
    {
      result = [nil, val[0], val[2], val[3]]
    }
  | f_block_optarg opt_f_block_arg
    {
      result = [nil, val[0], nil, val[1]]
    }
  | f_rest_arg opt_f_block_arg
    {
      result = [nil, nil, val[0], val[1]]
    }
  | f_block_arg
    {
      result = [nil, nil, nil, val[0]]
    }

f_block_optarg:
    f_block_opt
    {
      result = [val[0]]
    }
  | f_block_optarg ',' f_block_opt
    {
      val[0] << val[2]
      result = val[0]
    }

f_block_opt:
    IDENTIFIER '=' primary_value
    {
      result = [val[0], val[2]]
    }

opt_block_var:
    none
    {
      result = [nil]
    }
  | '|' '|'
    {
      result = [nil]
    }
  | '||'
    {
      result = [nil]
    }
  | '|' block_var '|'
    {
      result = val[1]
    }

do_block:
    DO_BLOCK
    {
      # result = "print('doing half command');"
    }
    opt_block_var compstmt END
    {
      result = BlockNode.new val[0], val[2], val[3], val[4]
    }

block_call:
    command do_block
    {
      result = val[0]
      val[0].block = val[1]
    }
  | block_call '.' operation2 opt_paren_args
  | block_call '::' operation2 opt_paren_args

method_call:
    operation paren_args
    {
      result = CallNode.new nil, val[0], val[1]
    }
  | primary_value '.' operation2 opt_paren_args
    {
      result = CallNode.new val[0], val[2], val[3]
    }
  | primary_value '::' operation2 paren_args
  | primary_value '::' operation3
  | SUPER paren_args
    {
      result = SuperNode.new val[0], val[1]
    }
  | SUPER
    {
      result = SuperNode.new val[0], []
    }

brace_block:
    '{@' opt_block_var compstmt '}'
    {
      result = BlockNode.new val[0], val[1], val[2], val[3]
    }
  | DO opt_block_var compstmt END
    {
      result = BlockNode.new val[0], val[1], val[2], val[3]
    }

case_body:
    WHEN when_args then compstmt cases
    {
      # result = "result = [['when', val[1], val[3]]].concat(val[4]);"
      result = [[val[0], val[1], val[3]]] + val[4]
    }

when_args:
    args
    {
      result = val[0]
    }
  | args ',' SPLAT arg_value
    {
      result = val[0]
    }
  | SPLAT arg_value
    {
      result = []
    }

cases:
    opt_else
  | case_body

opt_rescue:
    RESCUE exc_list exc_var then compstmt opt_rescue
    {
      result = [[val[0], val[1], val[2], val[4]]]
      result.concat val[5]
    }
  |
    {
      result = []
    }

exc_list:
    arg_value
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
      result = StringNode.new val[1], val[2]
    }
  | STRING

xstring:
    XSTRING_BEG xstring_contents STRING_END
    {
      result = XStringNode.new val[0], val[1], val[2]
    }

regexp:
    REGEXP_BEG xstring_contents REGEXP_END
    {
      result = RegexpNode.new val[0], val[1]
    }

words:
    WORDS_BEG SPACE STRING_END
    {
      result = WordsNode.new val[0], [], val[2]
    }
  | WORDS_BEG word_list STRING_END
    {
      result = WordsNode.new val[0], val[1], val[2]
    }

word_list:
    none
    {
      result = []
    }
  | word_list word SPACE
    {
      result = val[0].concat([val[1]])
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
      result = WordsNode.new val[0], [], val[2]
    }
  | AWORDS_BEG qword_list STRING_END
    {
      result = WordsNode.new val[0], val[1], val[2]
    }

qword_list:
    none
    {
      result = []
    }
  | qword_list STRING_CONTENT SPACE
    {
      result = val[0].concat([['string_content', val[1]]])
    }

string_contents:
    none
    {
      result = []
    }
  | string_contents string_content
    {
      result = val[0] << val[1]
    }

xstring_contents:
    none
    {
      result = []
    }
  | xstring_contents string_content
    {
      result = val[0].concat [val[1]]
    }

string_content:
    STRING_CONTENT
    {
      result = ['string_content', val[0]]
    }
  | STRING_DVAR string_dvar
    {
      result = ['string_dvar', val[1]]
    }
  | STRING_DBEG
    {
      cond_push 0
      cmdarg_push 0
    }
    compstmt '}'
    {
      cond_lexpop
      cmdarg_lexpop
      result = ['string_dbegin', val[2]]
    }

string_dvar:
    GVAR
  | IVAR
  | CVAR
  | backref


symbol:
    SYMBOL_BEG sym
    {
      result = SymbolNode.new val[1]
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
      result = NumericNode.new val[0]
    }
  | FLOAT
    {
      result = NumericNode.new val[0]
    }
  | '-@NUM' INTEGER =LOWEST
  | '-@NUM' FLOAT   =LOWEST

variable:
    IDENTIFIER
    {
      result = IdentifierNode.new val[0]
    }
  | IVAR
    {
      result = IvarNode.new val[0]
    }
  | GVAR
    {
      result = GvarNode.new val[0];
    }
  | CONSTANT
    {
      result = ConstantNode.new val[0]
    }
  | CVAR
    {
      result = "result = ['cvar', val[0]];"
    }
  | NIL
    {
      result = NilNode.new val[0]
    }
  | SELF
    {
      result = SelfNode.new val[0]
    }
  | TRUE
    {
      result = TrueNode.new val[0]
    }
  | FALSE
    {
      result = FalseNode.new val[0]
    }
  | FILE
    {
      result = FileNode.new val[0]
    }
  | LINE
    {
      result = LineNode.new val[0]
    }
  | BLOCK_GIVEN
    {
      result = BlockGivenNode.new val[0]
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
      result = [val[0], val[2], val[4], val[5]]
    }
  | f_arg ',' f_optarg opt_f_block_arg
    {
      result = [val[0], val[2], nil, val[3]]
    }
  | f_arg ',' f_rest_arg opt_f_block_arg
    {
      result = [val[0], nil, val[2], val[3]]
    }
  | f_arg opt_f_block_arg
    {
      result = [val[0], nil, nil, val[1]]
    }
  | f_optarg ',' f_rest_arg opt_f_block_arg
    {
      rsult = [nil, val[0], val[2], val[3]]
    }
  | f_optarg opt_f_block_arg
    {
      result = [nil, val[0], nil, val[1]]
    }
  | f_rest_arg opt_f_block_arg
    {
      result = [nil, nil, val[0], val[1]]
    }
  | f_block_arg
    {
      result = [nil, nil, nil, val[0]]
    }
  |
    {
      result = [nil, nil, nil, nil]
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
      result = [val[0], val[2]]
    }

f_optarg:
    f_opt
    {
      result = [val[0]]
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
      result = val[1]
    }
  | restarg_mark
    {
      result = val[0]
    }

blkarg_mark:
    '&'
  | '&@'

f_block_arg:
    blkarg_mark IDENTIFIER
    {
      result = val[1]
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
      result = [val[0]]
    }
  | assocs ',' assoc
    {
      result = val[0] << val[2]
    }

assoc:
    arg_value '=>' arg_value
    {
      result = [val[0], val[2]]
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
