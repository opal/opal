class Opal::Parser

token kCLASS kMODULE kDEF kUNDEF kBEGIN kRESCUE kENSURE kEND kIF kUNLESS
      kTHEN kELSIF kELSE kCASE kWHEN kWHILE kUNTIL kFOR kBREAK kNEXT
      kREDO kRETRY kIN kDO kDO_COND kDO_BLOCK kRETURN kYIELD kSUPER
      kSELF kNIL kTRUE kFALSE kAND kOR kNOT kIF_MOD kUNLESS_MOD kWHILE_MOD
      kUNTIL_MOD kRESCUE_MOD kALIAS kDEFINED klBEGIN klEND k__LINE__
      k__FILE__ tIDENTIFIER tFID tGVAR tIVAR tCONSTANT tCVAR tNTH_REF
      tBACK_REF tSTRING_CONTENT tINTEGER tFLOAT tREGEXP_END '+@'
      '-@' '-@NUM' tPOW tCMP tEQ tEQQ tNEQ tGEQ tLEQ tANDOP
      tOROP tMATCH tNMATCH tDOT tDOT2 tDOT3 tAREF tASET tLSHFT tRSHFT
      tCOLON2 tCOLON3 tOP_ASGN tASSOC tLPAREN tLPAREN2 tRPAREN tLPAREN_ARG
      ARRAY_BEG tRBRACK tLBRACE tLBRACE_ARG tSTAR tSTAR2 tAMPER tAMPER2
      tTILDE tPERCENT tDIVIDE '+' '-' tLT tGT tPIPE tBANG tCARET
      tLCURLY tRCURLY tBACK_REF2 tSYMBEG tSTRING_BEG tXSTRING_BEG tREGEXP_BEG
      tWORDS_BEG tAWORDS_BEG tSTRING_DBEG tSTRING_DVAR tSTRING_END tSTRING
      tSYMBOL tNL tEH tCOLON tCOMMA tSPACE tSEMI tLABEL tLAMBDA tLAMBEG kDO_LAMBDA
      tLBRACK2 tLBRACK

prechigh
  right    tBANG tTILDE '+@'
  right    tPOW
  right    '-@NUM' '-@'
  left     tSTAR2 tDIVIDE tPERCENT
  left     '+' '-'
  left     tLSHFT tRSHFT
  left     tAMPER2
  left     tPIPE tCARET
  left     tGT tGEQ tLT tLEQ
  nonassoc tCMP tEQ tEQQ tNEQ tMATCH tNMATCH
  left     tANDOP
  left     tOROP
  nonassoc tDOT2 tDOT3
  right    tEH tCOLON
  left     kRESCUE_MOD
  right    tEQL tOP_ASGN
  nonassoc kDEFINED
  right    kNOT
  left     kOR kAND
  nonassoc kIF_MOD kUNLESS_MOD kWHILE_MOD kUNTIL_MOD
  nonassoc tLBRACE_ARG
  nonassoc tLOWEST
preclow

rule

         program: top_compstmt
                    {
                      result = val[0]
                    }

    top_compstmt: top_stmts opt_terms
                    {
                      comp = new_compstmt val[0]
                      if comp and comp.type == :begin and comp.size == 2
                        result = comp[1]
                        result.line = comp.line
                      else
                        result = comp
                      end
                    }

       top_stmts: # none
                    {
                      result = new_block
                    }
                | top_stmt
                    {
                      result = new_block val[0]
                    }
                | top_stmts terms top_stmt
                    {
                      val[0] << val[2]
                      result = val[0]
                    }

        top_stmt: stmt
                | klBEGIN tLCURLY top_compstmt tRCURLY
                    {
                      result = val[2]
                    }

        bodystmt: compstmt opt_rescue opt_else opt_ensure
                    {
                      result = new_body val[0], val[1], val[2], val[3]
                    }

        compstmt: stmts opt_terms
                    {
                      comp = new_compstmt val[0]
                      if comp and comp.type == :begin and comp.size == 2
                        result = comp[1]
                        result.line = comp.line
                      else
                        result = comp
                      end
                    }

           stmts: # none
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

            stmt: kALIAS fitem
                    {
                      lexer.lex_state = :expr_fname
                    }
                    fitem
                    {
                      result = s(:alias, val[1], val[3])
                    }
                | kALIAS tGVAR tGVAR
                    {
                      result = s(:valias, val[1].intern, val[2].intern)
                    }
                | kALIAS tGVAR tBACK_REF
                | kALIAS tGVAR tNTH_REF
                    {
                      result = s(:valias, val[1].intern, val[2].intern)
                    }
                | kUNDEF undef_list
                    {
                      result = val[1]
                    }
                | stmt kIF_MOD expr_value
                    {
                      result = new_if val[2], val[0], nil
                    }
                | stmt kUNLESS_MOD expr_value
                    {
                      result = new_if val[2], nil, val[0]
                    }
                | stmt kWHILE_MOD expr_value
                    {
                      result = s(:while, val[2], val[0], true)
                    }
                | stmt kUNTIL_MOD expr_value
                    {
                      result = s(:until, val[2], val[0], true)
                    }
                | stmt kRESCUE_MOD stmt
                    {
                      result = s(:rescue_mod, val[0], val[2])
                    }
                | klEND tLCURLY compstmt tRCURLY
                | lhs tEQL command_call
                    {
                      result = new_assign val[0], val[2]
                    }
                | mlhs tEQL command_call
                    {
                      result = s(:masgn, val[0], s(:to_ary, val[2]))
                    }
                | var_lhs tOP_ASGN command_call
                    {
                      result = new_op_asgn val[1].intern, val[0], val[2]
                    }
                | primary_value tLBRACK2 aref_args tRBRACK tOP_ASGN command_call
                | primary_value tDOT tIDENTIFIER tOP_ASGN command_call
                    {
                      result = s(:op_asgn2, val[0], "#{val[2]}=".intern, val[3].intern, val[4])
                    }
                | primary_value tDOT tCONSTANT tOP_ASGN command_call
                | primary_value tCOLON2 tIDENTIFIER tOP_ASGN command_call
                | backref tOP_ASGN command_call
                | lhs tEQL mrhs
                    {
                      result = new_assign val[0], s(:svalue, val[2])
                    }
                | mlhs tEQL arg_value
                    {
                      result = s(:masgn, val[0], s(:to_ary, val[2]))
                    }
                | mlhs tEQL mrhs
                    {
                      result = s(:masgn, val[0], val[2])
                    }
                | expr

            expr: command_call
                | expr kAND expr
                    {
                      result = s(:and, val[0], val[2])
                      result.line = val[0].line
                    }
                | expr kOR expr
                    {
                      result = s(:or, val[0], val[2])
                      result.line = val[0].line
                    }
                | kNOT expr
                    {
                      result = s(:not, val[1])
                      result.line = val[1].line
                    }
                | tBANG command_call
                    {
                      result = s(:not, val[1])
                    }
                | arg

      expr_value: expr

    command_call: command
                | block_command
                | kRETURN call_args
                    {
                      args = val[1]
                      args = args[1] if args.size == 2
                      result = s(:return, args)
                    }
                | kBREAK call_args
                    {
                      args = val[1]
                      args = args[1] if args.size == 2
                      result = s(:break, args)
                    }
                | kNEXT call_args
                    {
                      args = val[1]
                      args = args[1] if args.size == 2
                      result = s(:next, args)
                    }

   block_command: block_call
                | block_call tDOT operation2 command_args
                | block_call tCOLON2 operation2 command_args

 cmd_brace_block: tLBRACE_ARG opt_block_var compstmt tRCURLY

         command: operation command_args =tLOWEST
                    {
                      result = new_call nil, val[0].intern, val[1]
                    }
                | operation command_args cmd_brace_block
                | primary_value tDOT operation2 command_args =tLOWEST
                    {
                      result = new_call val[0], val[2].intern, val[3]
                    }
                | primary_value tDOT operation2 command_args cmd_brace_block
                | primary_value tCOLON2 operation2 command_args =tLOWEST
                  {
                    result = new_call val[0], val[2].intern, val[3]
                  }
                | primary_value tCOLON2 operation2 command_args cmd_brace_block
                | kSUPER command_args
                    {
                      result = new_super val[1]
                    }
                | kYIELD command_args
                    {
                      result = new_yield val[1]
                    }

            mlhs: mlhs_basic
                    {
                      result = val[0]
                    }
                | tLPAREN mlhs_entry tRPAREN
                    {
                      result = val[1]
                    }

      mlhs_entry: mlhs_basic
                    {
                      result = val[0]
                    }
                | tLPAREN mlhs_entry tRPAREN
                    {
                      result = val[1]
                    }

      mlhs_basic: mlhs_head
                    {
                      result = val[0]
                    }
                | mlhs_head mlhs_item
                    {
                      result = val[0] << val[1]
                    }
                | mlhs_head tSTAR mlhs_node
                    {
                      result = val[0] << s(:splat, val[2])
                    }
                | mlhs_head tSTAR mlhs_node tCOMMA mlhs_post
                | mlhs_head tSTAR
                    {
                      result = val[0] << s(:splat)
                    }
                | mlhs_head tSTAR tCOMMA mlhs_post
                | tSTAR mlhs_node
                    {
                      result = s(:array, s(:splat, val[1]))
                    }
                | tSTAR
                    {
                      result = s(:array, s(:splat))
                    }
                | tSTAR tCOMMA mlhs_post

       mlhs_item: mlhs_node
                    {
                      result = val[0]
                    }
                | tLPAREN mlhs_entry tRPAREN
                    {
                      result = val[1]
                    }

       mlhs_head: mlhs_item tCOMMA
                    {
                      result = s(:array, val[0])
                    }
                | mlhs_head mlhs_item tCOMMA
                    {
                      result = val[0] << val[1]
                    }

       mlhs_post: mlhs_item
                | mlhs_post tCOMMA mlhs_item

       mlhs_node: variable
                    {
                      result = new_assignable val[0]
                    }
                | primary_value tLBRACK2 aref_args tRBRACK
                    {
                      args = val[2]
                      args.type = :arglist if args.type == :array
                      result = s(:attrasgn, val[0], :[]=, args)
                    }
                | primary_value tDOT tIDENTIFIER
                    {
                      result = new_call val[0], val[2].intern, s(:arglist)
                    }
                | primary_value tCOLON2 tIDENTIFIER
                | primary_value tDOT tCONSTANT
                | primary_value tCOLON2 tCONSTANT
                | tCOLON3 tCONSTANT
                | backref

             lhs: variable
                    {
                      result = new_assignable val[0]
                    }
                | primary_value tLBRACK2 aref_args tRBRACK
                    {
                      args = val[2]
                      args.type = :arglist if args.type == :array
                      result = s(:attrasgn, val[0], :[]=, args)
                    }
                | primary_value tDOT tIDENTIFIER
                    {
                      result = s(:attrasgn, val[0], "#{val[2]}=".intern, s(:arglist))
                    }
                | primary_value tCOLON2 tIDENTIFIER
                    {
                      result = s(:attrasgn, val[0], "#{val[2]}=".intern, s(:arglist))
                    }
                | primary_value tDOT tCONSTANT
                    {
                      result = s(:attrasgn, val[0], "#{val[2]}=".intern, s(:arglist))
                    }
                | primary_value tCOLON2 tCONSTANT
                    {
                      result = s(:colon2, val[0], val[2].intern)
                    }
                | tCOLON3 tCONSTANT
                    {
                      result = s(:colon3, val[1].intern)
                    }
                | backref

           cname: tCONSTANT

           cpath: tCOLON3 cname
                    {
                      result = s(:colon3, val[1].intern)
                    }
                | cname
                    {
                      result = val[0].intern
                    }
                | primary_value tCOLON2 cname
                    {
                      result = s(:colon2, val[0], val[2].intern)
                    }

           fname: tIDENTIFIER
                | tCONSTANT
                | tFID
                | op
                    {
                      lexer.lex_state = :expr_end
                      result = val[0]
                    }
                | reswords
                    {
                      lexer.lex_state = :expr_end
                      result = val[0]
                    }

           fitem: fname
                    {
                      result = s(:sym, val[0].intern)
                    }
                | symbol

      undef_list: fitem
                    {
                      result = s(:undef, val[0])
                    }
                | undef_list tCOMMA fitem
                    {
                      result = val[0] << val[2]
                    }

              op: tPIPE    | tCARET     | tAMPER2    | tCMP  | tEQ    | tEQQ
                | tMATCH   | tGT     | tGEQ   | tLT    | tLEQ    | tLSHFT
                | tRSHFT   | '+'     | '-'    | tSTAR2    | tSTAR   | tDIVIDE
                | tPERCENT    | tPOW    | tTILDE    | '+@'   | '-@'    | tAREF
                | tASET  | tBACK_REF2 | tBANG  | tNEQ

        reswords: k__LINE__ | k__FILE__   | klBEGIN    | klEND      | kALIAS  | kAND
                | kBEGIN    | kBREAK      | kCASE      | kCLASS     | kDEF    | kDEFINED
                | kDO       | kELSE       | kELSIF     | kEND       | kENSURE | kFALSE
                | kFOR      | kIN         | kMODULE    | kNEXT      | kNIL    | kNOT
                | kOR       | kREDO       | kRESCUE    | kRETRY     | kRETURN | kSELF
                | kSUPER    | kTHEN       | kTRUE      | kUNDEF     | kWHEN   | kYIELD
                | kIF_MOD   | kUNLESS_MOD | kWHILE_MOD | kUNTIL_MOD | kRESCUE_MOD
                | kIF       | kWHILE      | kUNTIL     | kUNLESS

             arg: lhs tEQL arg
                    {
                      result = new_assign val[0], val[2]
                    }
                | lhs tEQL arg kRESCUE_MOD arg
                    {
                      result = new_assign val[0], s(:rescue_mod, val[2], val[4])
                    }
                | var_lhs tOP_ASGN arg
                    {
                      result = new_op_asgn val[1].intern, val[0], val[2]
                    }
                | primary_value tLBRACK2 aref_args tRBRACK tOP_ASGN arg
                    {
                      args = val[2]
                      args.type = :arglist if args.type == :array
                      result = s(:op_asgn1, val[0], val[2], val[4].intern, val[5])
                      result.line = val[0].line
                    }
                | primary_value tDOT tIDENTIFIER tOP_ASGN arg
                    {
                      result = s(:op_asgn2, val[0], "#{val[2]}=".intern, val[3].intern, val[4])
                    }
                | primary_value tDOT tCONSTANT tOP_ASGN arg
                | primary_value tCOLON2 tIDENTIFIER tOP_ASGN arg
                | primary_value tCOLON2 tCONSTANT tOP_ASGN arg
                | tCOLON3 tCONSTANT tOP_ASGN arg
                | backref tOP_ASGN arg
                | arg tDOT2 arg
                    {
                      result = s(:dot2, val[0], val[2])
                      result.line = val[0].line
                    }
                | arg tDOT3 arg
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
                | arg tSTAR2 arg
                    {
                      result = new_call val[0], :"*", s(:arglist, val[2])
                    }
                | arg tDIVIDE arg
                    {
                      result = new_call val[0], :"/", s(:arglist, val[2])
                    }
                | arg tPERCENT arg
                    {
                      result = new_call val[0], :"%", s(:arglist, val[2])
                    }
                | arg tPOW arg
                    {
                      result = new_call val[0], :"**", s(:arglist, val[2])
                    }
                | '-@NUM' tINTEGER tPOW arg
                | '-@NUM' tFLOAT tPOW arg
                | '+@' arg
                    {
                      result = new_call val[1], :"+@", s(:arglist)
                      result = val[1] if [:int, :float].include? val[1].type
                    }
                | '-@' arg
                    {
                      result = new_call val[1], :"-@", s(:arglist)
                      if val[1].type == :int
                        val[1][1] = -val[1][1]
                        result = val[1]
                      elsif val[1].type == :float
                        val[1][1] = -val[1][1].to_f
                        result = val[1]
                      end
                    }
                | arg tPIPE arg
                    {
                      result = new_call val[0], :"|", s(:arglist, val[2])
                    }
                | arg tCARET arg
                    {
                      result = new_call val[0], :"^", s(:arglist, val[2])
                    }
                | arg tAMPER2 arg
                    {
                      result = new_call val[0], :"&", s(:arglist, val[2])
                    }
                | arg tCMP arg
                    {
                      result = new_call val[0], :"<=>", s(:arglist, val[2])
                    }
                | arg tGT arg
                    {
                      result = new_call val[0], :">", s(:arglist, val[2])
                    }
                | arg tGEQ arg
                    {
                      result = new_call val[0], :">=", s(:arglist, val[2])
                    }
                | arg tLT arg
                    {
                      result = new_call val[0], :"<", s(:arglist, val[2])
                    }
                | arg tLEQ arg
                    {
                      result = new_call val[0], :"<=", s(:arglist, val[2])
                    }
                | arg tEQ arg
                    {
                      result = new_call val[0], :"==", s(:arglist, val[2])
                    }
                | arg tEQQ arg
                    {
                      result = new_call val[0], :"===", s(:arglist, val[2])
                    }
                | arg tNEQ arg
                    {
                      result = s(:not, new_call(val[0], :"==", s(:arglist, val[2])))
                    }
                | arg tMATCH arg
                    {
                      result = new_call val[0], :"=~", s(:arglist, val[2])
                    }
                | arg tNMATCH arg
                    {
                      result = s(:not, new_call(val[0], :"=~", s(:arglist, val[2])))
                    }
                | tBANG arg
                    {
                      result = s(:not, val[1])
                    }
                | tTILDE arg
                    {
                      result = new_call val[1], :"~", s(:arglist)
                    }
                | arg tLSHFT arg
                    {
                      result = new_call val[0], :"<<", s(:arglist, val[2])
                    }
                | arg tRSHFT arg
                    {
                      result = new_call val[0], :">>", s(:arglist, val[2])
                    }
                | arg tANDOP arg
                    {
                      result = s(:and, val[0], val[2])
                      result.line = val[0].line
                    }
                | arg tOROP arg
                    {
                      result = s(:or, val[0], val[2])
                      result.line = val[0].line
                    }
                | kDEFINED opt_nl arg
                    {
                      result = s(:defined, val[2])
                    }
                | arg tEH arg tCOLON arg
                    {
                      result = s(:if, val[0], val[2], val[4])
                      result.line = val[0].line
                    }
                | primary

       arg_value: arg

       aref_args: none
                    {
                      result = nil
                    }
                | command opt_nl
                    {
                      result = s(:array, val[0])
                    }
                | args trailer
                    {
                      result = val[0]
                    }
                | args tCOMMA assocs trailer
                    {
                      val[0] << s(:hash, *val[2])
                      result = val[0]
                    }
                | assocs trailer
                    {
                      result = s(:array, s(:hash, *val[0]))
                    }

      paren_args: tLPAREN2 none tRPAREN
                    {
                      result = nil
                    }
                | tLPAREN2 call_args opt_nl tRPAREN
                    {
                      result = val[1]
                    }
                | tLPAREN2 block_call opt_nl tRPAREN
                | tLPAREN2 args tCOMMA block_call opt_nl tRPAREN

  opt_paren_args: none
                | paren_args

       call_args: command
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
                | args tCOMMA assocs opt_block_arg
                    {
                      result = val[0]
                      result << s(:hash, *val[2])
                    }
                | block_arg
                    {
                      result = s(:arglist)
                      add_block_pass result, val[0]
                    }

      call_args2: arg_value tCOMMA args opt_block_arg
                | block_arg

    command_args:   {
                      lexer.cmdarg_push 1
                    }
                    open_args
                    {
                      lexer.cmdarg_pop
                      result = val[1]
                    }

       open_args: call_args
                | tLPAREN_ARG tRPAREN
                    {
                      result = nil
                    }
                | tLPAREN_ARG call_args2 tRPAREN
                    {
                      result = val[1]
                    }

       block_arg: tAMPER arg_value
                    {
                      result = s(:block_pass, val[1])
                    }

   opt_block_arg: tCOMMA block_arg
                    {
                      result = val[1]
                    }
                | # none
                    {
                      result = nil
                    }

            args: arg_value
                    {
                      result = s(:array, val[0])
                    }
                | tSTAR arg_value
                    {
                      result = s(:array, s(:splat, val[1]))
                    }
                | args tCOMMA arg_value
                    {
                      result = val[0] << val[2]
                    }
                | args tCOMMA tSTAR arg_value
                    {
                      result  = val[0] << s(:splat, val[3])
                    }

            mrhs: args tCOMMA arg_value
                    {
                      val[0] << val[2]
                      result = val[0]
                    }
                | args tCOMMA tSTAR arg_value
                | tSTAR arg_value
                    {
                      result = s(:splat, val[1])
                    }

         primary: literal
                | strings
                | xstring
                | regexp
                | words
                | awords
                | var_ref
                | backref
                | tFID
                | kBEGIN
                    {
                      result = lexer.line
                    }
                    bodystmt kEND
                    {
                      result = s(:begin, val[2])
                      result.line = val[1]
                    }
                | tLPAREN_ARG expr opt_nl tRPAREN
                    {
                      result = val[1]
                    }
                | tLPAREN compstmt tRPAREN
                    {
                      result = s(:paren, val[1] || s(:nil))
                    }
                | primary_value tCOLON2 tCONSTANT
                    {
                      result = s(:colon2, val[0], val[2].intern)
                    }
                | tCOLON3 tCONSTANT
                    {
                      result = s(:colon3, val[1])
                    }
                | primary_value tLBRACK2 aref_args tRBRACK
                    {
                      result = new_call val[0], :[], val[2]
                    }
                | tLBRACK aref_args tRBRACK
                    {
                      result = val[1] || s(:array)
                    }
                | '{' assoc_list tRCURLY
                    {
                      result = s(:hash, *val[1])
                    }
                | kRETURN
                    {
                      result = s(:return)
                    }
                | kYIELD tLPAREN2 call_args tRPAREN
                    {
                      result = new_yield val[2]
                    }
                | kYIELD tLPAREN2 tRPAREN
                    {
                      result = s(:yield)
                    }
                | kYIELD
                    {
                      result = s(:yield)
                    }
                | kDEFINED opt_nl tLPAREN2 expr tRPAREN
                    {
                      result = s(:defined, val[3])
                    }
                | kNOT tLPAREN2 expr tRPAREN
                    {
                      result = s(:not, val[2])
                      result.line = val[2].line
                    }
                | kNOT tLPAREN2 tRPAREN
                    {
                      result = s(:not, s(:nil))
                    }
                | operation brace_block
                    {
                      result = new_call nil, val[0].intern, s(:arglist)
                      result << val[1]
                    }
                | method_call
                | method_call brace_block
                    {
                      val[0] << val[1]
                      result = val[0]
                    }
                | tLAMBDA lambda
                    {
                      result = val[1]
                    }
                | kIF expr_value then compstmt if_tail kEND
                    {
                      result = new_if val[1], val[3], val[4]
                    }
                | kUNLESS expr_value then compstmt opt_else kEND
                    {
                      result = new_if val[1], val[4], val[3]
                    }
                | kWHILE
                    {
                      lexer.cond_push 1
                      result = lexer.line
                    }
                    expr_value do
                    {
                      lexer.cond_pop
                    }
                    compstmt kEND
                    {
                      result = s(:while, val[2], val[5], true)
                      result.line = val[1]
                    }
                | kUNTIL
                    {
                      lexer.cond_push 1
                      result = lexer.line
                    }
                    expr_value do
                    {
                      lexer.cond_pop
                    }
                    compstmt kEND
                    {
                      result = s(:until, val[2], val[5], true)
                      result.line = val[1]
                    }
                | kCASE expr_value opt_terms case_body kEND
                    {
                      result = s(:case, val[1], *val[3])
                      result.line = val[1].line
                    }
                | kCASE opt_terms case_body kEND
                    {
                      result = s(:case, nil, *val[2])
                      # result.line = val[2].line
                    }
                | kCASE opt_terms kELSE compstmt kEND
                    {
                      result = s(:case, nil, val[3])
                      # result.line = val[3].line
                    }
                | kFOR mlhs kIN
                    {
                      # ...
                    }
                    expr_value do
                    {
                      # ...
                    }
                    compstmt kEND
                | kCLASS
                    {
                      result = lexer.line
                    }
                    cpath superclass
                    {
                      # ...
                    }
                    bodystmt kEND
                    {
                      result = new_class val[2], val[3], val[5]
                      result.line = val[1]
                      result.end_line = lexer.line
                    }
                | kCLASS tLSHFT
                    {
                      result = lexer.line
                    }
                    expr term
                    {
                      # ...
                    }
                    bodystmt kEND
                    {
                      result = new_sclass val[3], val[6]
                      result.line = val[2]
                    }
                | kMODULE
                    {
                      result = lexer.line
                    }
                    cpath
                    {
                      # ...
                    }
                    bodystmt kEND
                    {
                      result = new_module val[2], val[4]
                      result.line = val[1]
                      result.end_line = lexer.line
                    }
                | kDEF fname
                    {
                      result = lexer.scope_line
                      push_scope
                    }
                    f_arglist bodystmt kEND
                    {
                      result = new_def val[2], nil, val[1], val[3], val[4]
                      pop_scope
                    }
                | kDEF singleton dot_or_colon
                    {
                       lexer.lex_state = :expr_fname
                    }
                    fname
                    {
                      result = lexer.scope_line
                      push_scope
                    }
                    f_arglist bodystmt kEND
                    {
                      result = new_def val[5], val[1], val[4], val[6], val[7]
                      pop_scope
                    }
                | kBREAK
                    {
                      result = s(:break)
                    }
                | kNEXT
                    {
                      result = s(:next)
                    }
                | kREDO
                    {
                      result = s(:redo)
                    }
                | kRETRY

   primary_value: primary

            then: term
                | tCOLON
                | kTHEN
                | term kTHEN

              do: term
                | tCOLON
                | kDO_COND

          lambda: f_larglist lambda_body
                    {
                      result = new_call nil, :lambda, s(:arglist)
                      result << new_iter(val[0], val[1])
                    }

      f_larglist: tLPAREN2 block_param tRPAREN
                    {
                      result = val[1]
                    }
                | tLPAREN2 tRPAREN
                    {
                      result = nil
                    }
                | block_param
                | none

     lambda_body: tLAMBEG compstmt tRCURLY
                    {
                      result = val[1]
                    }
                | kDO_LAMBDA compstmt kEND
                    {
                      result = val[1]
                    }

         if_tail: opt_else
                    {
                      result = val[0]
                    }
                | kELSIF
                    {
                      result = lexer.line
                    }
                    expr_value then compstmt if_tail
                    {
                      result = s(:if, val[2], val[4], val[5])
                      result.line = val[1]
                    }

        opt_else: none
                | kELSE compstmt
                    {
                      result = val[1]
                    }

  f_block_optarg: f_block_opt
                    {
                      result = s(:block, val[0])
                    }
                | f_block_optarg tCOMMA f_block_opt
                    {
                      val[0] << val[2]
                      result = val[0]
                    }

     f_block_opt: tIDENTIFIER tEQL primary_value
                    {
                      result = new_assign new_assignable(s(:identifier, val[0].intern)), val[2]
                    }

   opt_block_var: none
                | tPIPE tPIPE
                    {
                      result = 0
                    }
                | tOROP
                    {
                      result = 0
                    }
                | tPIPE block_param tPIPE
                    {
                      result = val[1]
                    }

 block_args_tail: f_block_arg
                    {
                      result = val[0]
                    }

opt_block_args_tail: tCOMMA block_args_tail
                    {
                      result = val[1]
                    }
                | none
                    {
                      nil
                    }

     block_param: f_arg tCOMMA f_block_optarg tCOMMA f_rest_arg opt_block_args_tail
                    {
                      result = new_block_args val[0], val[2], val[4], val[5]
                    }
                | f_arg tCOMMA f_block_optarg opt_block_args_tail
                    {
                      result = new_block_args val[0], val[2], nil, val[3]
                    }
                | f_arg tCOMMA f_rest_arg opt_block_args_tail
                    {
                      result = new_block_args val[0], nil, val[2], val[3]
                    }
                | f_arg tCOMMA
                    {
                      result = new_block_args val[0], nil, nil, nil
                    }
                | f_arg opt_block_args_tail
                    {
                      result = new_block_args val[0], nil, nil, val[1]
                    }
                | f_block_optarg tCOMMA f_rest_arg opt_block_args_tail
                    {
                      result = new_block_args nil, val[0], val[2], val[3]
                    }
                | f_block_optarg opt_block_args_tail
                    {
                      result = new_block_args nil, val[0], nil, val[1]
                    }
                | f_rest_arg opt_block_args_tail
                    {
                      result = new_block_args nil, nil, val[0], val[1]
                    }
                | block_args_tail
                    {
                      result = new_block_args nil, nil, nil, val[0]
                    }

        do_block: kDO_BLOCK
                    {
                      push_scope :block
                      result = lexer.line
                    }
                    opt_block_var compstmt kEND
                    {
                      result = new_iter val[2], val[3]
                      result.line = val[1]
                      pop_scope
                    }

      block_call: command do_block
                    {
                      val[0] << val[1]
                      result = val[0]
                    }
                | block_call tDOT operation2 opt_paren_args
                | block_call tCOLON2 operation2 opt_paren_args

     method_call: operation paren_args
                    {
                      result = new_call nil, val[0].intern, val[1]
                    }
                | primary_value tDOT operation2 opt_paren_args
                    {
                      result = new_call val[0], val[2].intern, val[3]
                    }
                | primary_value tDOT paren_args
                    {
                      result = new_call val[0], :call, val[2]
                    }
                | primary_value tCOLON2 operation2 paren_args
                    {
                      result = new_call val[0], val[2].intern, val[3]
                    }
                | primary_value tCOLON2 operation3
                    {
                      result = new_call val[0], val[2].intern, s(:arglist)
                    }
                | kSUPER paren_args
                    {
                      result = new_super val[1]
                    }
                | kSUPER
                    {
                      result = s(:super, nil)
                    }

     brace_block: tLCURLY
                    {
                      push_scope :block
                      result = lexer.line
                    }
                    opt_block_var compstmt tRCURLY
                    {
                      result = new_iter val[2], val[3]
                      result.line = val[1]
                      pop_scope
                    }
                | kDO
                    {
                      push_scope :block
                      result = lexer.line
                    }
                    opt_block_var compstmt kEND
                    {
                      result = new_iter val[2], val[3]
                      result.line = val[1]
                      pop_scope
                    }

       case_body: kWHEN
                    {
                      result = lexer.line
                    }
                    args then compstmt cases
                    {
                      part = s(:when, val[2], val[4])
                      part.line = val[2].line
                      result = [part]
                      result.push *val[5] if val[5]
                    }

           cases: opt_else
                    {
                      result = [val[0]]
                    }
                | case_body

      opt_rescue: kRESCUE exc_list exc_var then compstmt opt_rescue
                    {
                      exc = val[1] || s(:array)
                      exc << new_assign(val[2], s(:gvar, '$!'.intern)) if val[2]
                      result = [s(:resbody, exc, val[4])]
                      result.push val[5].first if val[5]
                    }
                | # none
                    {
                      result = nil
                    }

        exc_list: arg_value
                    {
                      result = s(:array, val[0])
                    }
                | mrhs
                | none

         exc_var: tASSOC lhs
                    {
                      result = val[1]
                    }
                | none
                    {
                      result = nil
                    }

      opt_ensure: kENSURE compstmt
                    {
                      result = val[1].nil? ? s(:nil) : val[1]
                    }
                | none

         literal: numeric
                | symbol
                | dsym

         strings: string
                    {
                      result = new_str val[0]
                    }

          string: string1
                | string string1

         string1: tSTRING_BEG string_contents tSTRING_END
                    {
                      result = val[1]
                    }
                | tSTRING
                    {
                      result = s(:str, val[0])
                    }

         xstring: tXSTRING_BEG xstring_contents tSTRING_END
                    {
                      result = new_xstr val[1]
                    }

          regexp: tREGEXP_BEG xstring_contents tREGEXP_END
                    {
                      result = new_regexp val[1], val[2]
                    }

           words: tWORDS_BEG tSPACE tSTRING_END
                    {
                      result = s(:array)
                    }
                | tWORDS_BEG word_list tSTRING_END
                    {
                      result = val[1]
                    }

       word_list: none
                    {
                      result = s(:array)
                    }
                | word_list word tSPACE
                    {
                      part = val[1]
                      part = s(:dstr, "", val[1]) if part.type == :evstr
                      result = val[0] << part
                    }

            word: string_content
                    {
                      result = val[0]
                    }
                | word string_content
                    {
                      result = val[0].concat([val[1]])
                    }

          awords: tAWORDS_BEG tSPACE tSTRING_END
                    {
                      result = s(:array)
                    }
                | tAWORDS_BEG qword_list tSTRING_END
                    {
                      result = val[1]
                    }

      qword_list: none
                    {
                      result = s(:array)
                    }
                | qword_list tSTRING_CONTENT tSPACE
                    {
                      result = val[0] << s(:str, val[1])
                    }

 string_contents: none
                    {
                      result = nil
                    }
                | string_contents string_content
                    {
                      result = str_append val[0], val[1]
                    }

xstring_contents: none
                    {
                      result = nil
                    }
                | xstring_contents string_content
                    {
                      result = str_append val[0], val[1]
                    }

  string_content: tSTRING_CONTENT
                    {
                      result = s(:str, val[0])
                    }
                | tSTRING_DVAR
                    {
                      result = lexer.strterm
                      lexer.strterm = nil
                    }
                    string_dvar
                    {
                      lexer.strterm = val[1]
                      result = s(:evstr, val[2])
                    }
                | tSTRING_DBEG
                    {
                      lexer.cond_push 0
                      lexer.cmdarg_push 0
                      result = lexer.strterm
                      lexer.strterm = nil
                      lexer.lex_state = :expr_beg
                    }
                    compstmt tRCURLY
                    {
                      lexer.strterm = val[1]
                      lexer.cond_lexpop
                      lexer.cmdarg_lexpop
                      result = s(:evstr, val[2])
                    }

     string_dvar: tGVAR
                    {
                      result = s(:gvar, val[0].intern)
                    }
                | tIVAR
                    {
                      result = s(:ivar, val[0].intern)
                    }
                | tCVAR
                    {
                      result = s(:cvar, val[0].intern)
                    }
                | backref


          symbol: tSYMBEG sym
                    {
                      result = s(:sym, val[1].intern)
                      lexer.lex_state = :expr_end
                    }
                | tSYMBOL
                    {
                      result = s(:sym, val[0].intern)
                    }

             sym: fname
                | tIVAR
                | tGVAR
                | tCVAR

            dsym: tSYMBEG xstring_contents tSTRING_END
                    {
                      result = new_dsym val[1]
                    }

         numeric: tINTEGER
                    {
                      result = s(:int, val[0])
                    }
                | tFLOAT
                    {
                      result = s(:float, val[0])
                    }
                | '-@NUM' tINTEGER =tLOWEST
                | '-@NUM' tFLOAT   =tLOWEST

        variable: tIDENTIFIER
                    {
                      result = s(:identifier, val[0].intern)
                    }
                | tIVAR
                    {
                      result = s(:ivar, val[0].intern)
                    }
                | tGVAR
                    {
                      result = s(:gvar, val[0].intern)
                    }
                | tCONSTANT
                    {
                      result = s(:const, val[0].intern)
                    }
                | tCVAR
                    {
                      result = s(:cvar, val[0].intern)
                    }
                | kNIL
                    {
                      result = s(:nil)
                    }
                | kSELF
                    {
                      result = s(:self)
                    }
                | kTRUE
                    {
                      result = s(:true)
                    }
                | kFALSE
                    {
                      result = s(:false)
                    }
                | k__FILE__
                    {
                      result = s(:str, self.file)
                    }
                | k__LINE__
                    {
                      result = s(:int, lexer.line)
                    }

         var_ref: variable
                    {
                      result = new_var_ref val[0]
                    }

         var_lhs: variable
                    {
                      result = new_assignable val[0]
                    }

         backref: tNTH_REF
                    {
                      result = s(:nth_ref, val[0])
                    }
                | tBACK_REF

      superclass: term
                    {
                      result = nil
                    }
                | tLT expr_value term
                    {
                      result = val[1]
                    }
                | error term
                    {
                      result = nil
                    }

       f_arglist: tLPAREN2 f_args opt_nl tRPAREN
                    {
                      result = val[1]
                      lexer.lex_state = :expr_beg
                    }
                | f_args term
                    {
                      result = val[0]
                    }

          f_args: f_arg tCOMMA f_optarg tCOMMA f_rest_arg opt_f_block_arg
                    {
                      result = new_args val[0], val[2], val[4], val[5]
                    }
                | f_arg tCOMMA f_optarg opt_f_block_arg
                    {
                      result = new_args val[0], val[2], nil, val[3]
                    }
                | f_arg tCOMMA f_rest_arg opt_f_block_arg
                    {
                      result = new_args val[0], nil, val[2], val[3]
                    }
                | f_arg opt_f_block_arg
                    {
                      result = new_args val[0], nil, nil, val[1]
                    }
                | f_optarg tCOMMA f_rest_arg opt_f_block_arg
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
                | # none
                    {
                      result = s(:args)
                    }

      f_norm_arg: f_bad_arg
                | tIDENTIFIER
                    {
                      result = val[0].intern
                      scope.add_local result
                    }

       f_bad_arg: tCONSTANT
                    {
                      raise 'formal argument cannot be a constant'
                    }
                | tIVAR
                    {
                      raise 'formal argument cannot be an instance variable'
                    }
                | tCVAR
                    {
                      raise 'formal argument cannot be a class variable'
                    }
                | tGVAR
                    {
                      raise 'formal argument cannot be a global variable'
                    }

      f_arg_item: f_norm_arg
                    {
                      result = val[0]
                    }
                | tLPAREN f_margs tRPAREN
                    {
                      result = val[1]
                    }

          f_marg: f_norm_arg
                    {
                      result = s(:lasgn, val[0])
                    }
                | tLPAREN f_margs tRPAREN

     f_marg_list: f_marg
                    {
                      result = s(:array, val[0])
                    }
                | f_marg_list tCOMMA f_marg
                    {
                      val[0] << val[2]
                      result = val[0]
                    }

         f_margs: f_marg_list
                | f_marg_list tCOMMA tSTAR f_norm_arg
                | f_marg_list tCOMMA tSTAR
                | tSTAR f_norm_arg
                | tSTAR

           f_arg: f_arg_item
                    {
                      result = [val[0]]
                    }
                | f_arg tCOMMA f_arg_item
                    {
                      val[0] << val[2]
                      result = val[0]
                    }

           f_opt: tIDENTIFIER tEQL arg_value
                    {
                      result = new_assign new_assignable(s(:identifier, val[0].intern)), val[2]
                    }

        f_optarg: f_opt
                    {
                      result = s(:block, val[0])
                    }
                | f_optarg tCOMMA f_opt
                    {
                      result = val[0]
                      val[0] << val[2]
                    }

    restarg_mark: tSTAR2
                | tSTAR

      f_rest_arg: restarg_mark tIDENTIFIER
                    {
                      result = "*#{val[1]}".intern
                    }
                | restarg_mark
                    {
                      result = :"*"
                    }

     blkarg_mark: tAMPER2
                | tAMPER

     f_block_arg: blkarg_mark tIDENTIFIER
                    {
                      result = "&#{val[1]}".intern
                    }

 opt_f_block_arg: tCOMMA f_block_arg
                    {
                      result = val[1]
                    }
                | # none
                    {
                      result = nil
                    }

       singleton: var_ref
                    {
                      result = val[0]
                    }
                | tLPAREN2 expr opt_nl tRPAREN
                    {
                      result = val[1]
                    }

      assoc_list: # none
                    {
                      result = []
                    }
                | assocs trailer
                    {
                      result = val[0]
                    }

          assocs: assoc
                    {
                      result = val[0]
                    }
                | assocs tCOMMA assoc
                    {
                      result = val[0].push *val[2]
                    }

           assoc: arg_value tASSOC arg_value
                    {
                      result = [val[0], val[2]]
                    }
                | tLABEL arg_value
                    {
                      result = [s(:sym, val[0].intern), val[1]]
                    }

       operation: tIDENTIFIER
                | tCONSTANT
                | tFID

      operation2: tIDENTIFIER
                | tCONSTANT
                | tFID
                | op

      operation3: tIDENTIFIER
                | tFID
                | op

    dot_or_colon: tDOT
                | tCOLON2

       opt_terms: # none
                | terms

          opt_nl: # none
                | tNL

         trailer: # none
                | tNL
                | tCOMMA

            term: tSEMI
                | tNL

           terms: term
                | terms tSEMI

            none: # none
                    {
                      result = nil
                    }
end

---- inner
