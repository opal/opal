module Opal
  class RubyParser < Racc::Parser

  # Indent for generated code scopes; 2 spaces, never use tabs
  INDENT = '  '

  LEVEL_TOP           = 0 # normal top level statements
  LEVEL_TOP_CLOSURE   = 1 # normal top level, but wrapped in js closure
  LEVEL_LIST          = 2
  LEVEL_EXPR          = 3

  # Base node for generators. All other nodes inherit from this
  class BaseNode

    attr_reader :line

    # Generate the code for this node. This MUST be overriden in subclasses.
    def generate(opts, level)
      ''
    end

    # Makes the node return its value. Overriden by various subclasses. This is
    # not for use with the ruby return statement, this just means that the
    # generated scope requires us to return within a javascript function. The
    # return statement in ruby uses another method for returning.
    def returns
      FuncReturnNode.new self
    end

    # By default, all nodes are expressions (';' to finish them). Statements
    # override this to be false.
    def expression?
      true
    end

    # Processes the node, which generates it. By default, process will also fix
    # the line number etc. Some nodes override this as they need a slightly
    # different approach. This will also set the level for indentation?? To
    # generate, but not indent or fix the line number, you may call {#generate}
    # directly. Note that this relies on level. If the level is {LEVEL_LIST},
    # for example, then a node will not correct its line number or indentation.
    def process(opts, level)
      if level <= LEVEL_LIST
        fix_line_number(opts) + generate(opts, level)
      else
        generate opts, level
      end
    end

    # Fix line numbers for nodes that need to. This returns code that is used
    # inside {#process}. Basically, this returns a string of new line chars
    # which will be prepended to the generated code for this node. This will
    # use the {@line} local ivar, if present, or you may pass a direct line
    # number into the {line} parameter.
    def fix_line_number(opts, line = nil)
      code = ''
      # make sure we are on the right line
      target = line || @line
      current = opts[:top].line

      if current < target
        (target - current).times {
          opts[:top].line += 1
          code += "\n"
        }

        code += opts[:indent]
      end

      code
    end
  end

  # Scope nodes. All scope nodes inherit from this node, including: method,
  # class, def, etc.
  class ScopeNode < BaseNode

    attr_reader :variables

    attr_reader :parent

    def initialize(parent, statements)
      @parent = parent
      @statements = statements
      # all variables - arg, tempts, params etc
      @variables = []
      # all vars for scope and temp
      @scope_vars = []
      # temps
      @temp_current = 'a'
      @temp_queue = []
      # ivars..we need to make sure these exist (make sure they are nil if new)
      @ivars = []

      # keep tabs on whether in while loop or not
      @while_scope = 0
      @while_scope_stack = []
    end

    def push_while_scope(while_scope)
      @while_scope_stack << while_scope
      @while_scope += 1
    end

    def pop_while_scope
      @while_scope_stack.pop
      @while_scope -= 1
    end

    def in_while_scope?
      @while_scope > 0
    end

    def while_scope
      @while_scope_stack.last
    end

    def ensure_ivar(name)
      @ivars << name unless @ivars.include? name
    end

    def param_variable(name)
      @variables << name
    end

    def ensure_variable(name)
      variable = find_variable name
      return variable if variable

      # does not exist in scope
      @scope_vars << name
      @variables << name
    end

    def find_variable(name)
      scope = self

      while scope
        return name if scope.variables.include? name

        if scope.is_a?(BlockNode) && scope.parent
          scope = scope.parent
        else
          break
        end
      end

      nil
    end

    def temp_local
      return @temp_queue.pop if @temp_queue.last

      name = '__' + @temp_current
      @scope_vars << name
      @temp_current = @temp_current.succ
      name
    end

    def queue_temp(temp)
      @temp_queue << temp
    end

    def set_uses_block
      return @block_arg_name if @block_arg_name

      @block_arg_name = '__block__'
    end

    def generate(opts, level)
      stmts = @statements.generate opts, level
      vars = ''

      vars + stmts
    end
  end

  # Top level scope. This also manages things like line numbers etc. All opts
  # will be passed a :top key, that references this root scope (instead of
  # needing to manually traverse it each time).
  class TopScopeNode < ScopeNode

    # helpers we need to add to top of file
    attr_reader :file_helpers

    # keep track of the current line number in the generator
    attr_accessor :line

    def initialize(statements)
      super nil, statements
      @file_helpers = []
      @line = 1
      @mm_ids = []
    end

    # Register a method name that needs to be called to $opal.mm. This method
    # will remove duplicates.
    def register_mm_id(mid)
      @mm_ids << mid unless @mm_ids.include? mid
    end

    def generate(opts, level)
      code = []
      code << super(opts, level)

      pre = '$$init();'

      post = "\n\nvar nil, $ac, $super, $break, $class, $def, $symbol, $range, "
      post += '$hash, $B, Qtrue, Qfalse;'
      # local vars... only if we used any..
      unless @scope_vars.empty?
        post += "var #{@scope_vars.join ', '};"
      end

      post += "\nfunction $$init() {"
      post += 'nil = $runtime.Qnil, $ac = $runtime.ac, $super = $runtime.S, $break = $runtime.B, '
      post += '$class = $runtime.dc, $def = $runtime.dm, $symbol = $runtime.Y, $range = $runtime.G, '
      post += '$hash = $runtime.H, $B = $runtime.P, Qtrue = $runtime.Qtrue, Qfalse = $runtime.Qfalse;'
      # add method missing setup
      if @mm_ids.length > 0
        mm_ids = "$runtime.mm(['#{@mm_ids.join "', '"}']);"
        post += mm_ids
      end

      # ivars
      @ivars.each do |ivar|
        post += "if (self['#{ivar}'] == undefined) { self['#{ivar}'] = nil; }"
      end

      post += "}\n"

      pre + code.join('') + post
    end
  end

  # Statements - represents any chain of statements
  class StatementsNode < BaseNode

    attr_reader :nodes

    def initialize(nodes = [])
      @line = 0
      @nodes = nodes
    end

    def returns
      if @nodes.length > 0
        @nodes[-1] = @nodes[-1].returns
      else
        @nodes << FuncReturnNode.new(NilNode.new)
      end
    end

    def generate(opts, level)
      code = []

      return NilNode.new.generate(opts, level) if @nodes.empty?

      @nodes.each do |node|
        node_code = node.process opts, LEVEL_TOP

        if level <= LEVEL_TOP_CLOSURE
          # to prevent lots of trailing whitespace when we generate statements
          # on new lines, we only insert indent if we dont have a newline
          # marker straight away
          if node_code[0] == "\n"
            code << node_code
          else
            code << (opts[:indent] + node_code)
          end

          # if expression, add ';' .. statements don't need ';'. We MUST call
          # this after we generate it, as some statements may determine
          # themselves during compilation. For example, IfNode does this
          # depending on whether it needs to generate as a LEVEL_TOP, or as a
          # LEVEL_TOP_CLOSURE.
          code << ';' if node.expression?

        else
          code << node_code
        end
      end

      code.join ''
    end

    # Push more statements onto end.
    def <<(node)
      @nodes << node
      self
    end

    # Generate statements for top level. Generally used for files
    def generate_top(opts = {})
      scope = TopScopeNode.new self
      opts[:scope] = scope
      opts[:indent] = ''
      opts[:top] = scope
      scope.generate opts, LEVEL_TOP
    end
  end

  class NumericNode < BaseNode

    attr_accessor :value

    def initialize(val)
      @line = val[:line]
      @value = val[:value]
    end

    def generate(opts, level)
      @value.to_s
    end
  end

  class SymbolNode < BaseNode

    def initialize(val)
      @line = val[:line]
      @value = val[:value]
    end

    def generate(opts, level)
      "$symbol('#{@value}')"
    end
  end

  class CallNode < BaseNode

    # any call may have a block assigned to it
    attr_writer :block

    attr_reader :recv

    attr_reader :mid

    def initialize(recv, mid, args)
      @recv = recv
      @mid = mid[:value]
      @args = args
      @line = recv ? recv.line : mid[:line]
    end

    def mid_to_jsid(id)
      return ".$m['#{id}']" if /[\!\=\?\+\-\*\/\^\&\%\@\|\[\]\<\>\~]/ =~ id

      # FIXME: if our id is a reserved word in js, we need to also wrap it in
      # brackets.
      return ".$m['#{id}']" if js_reserved_words.include? id

      # default we just do .method_name
      '.$m.' + id
    end

    # Reserved js words - we cannot just generate properties with these names
    # as they will cause a parse error, so we need to wrap them in brackets.
    def js_reserved_words
      %w[break case catch continue debugger default delete do else finally
         for function if in instanceof new return switch this throw try typeof
         var void while with class enum export extends import super]
    end

    def generate(opts, level)
      # Special handlers
      if @recv.is_a? NumericNode and @mid == '-@'
        @recv.value = "-#{@recv.value}"
        return @recv.generate opts, level
      end

      code = ''
      arg_res = []
      recv = nil
      mid = nil

      # we need a temp var for the receiver, which we add to the front of
      # the args to send.
      tmp_recv = opts[:scope].temp_local

      # method id
      mid = @mid

      # Register our method_id to ensure $opal.mm gets it
      opts[:top].register_mm_id @mid

      # receiver
      if @recv.is_a? NumericNode
        recv = "#{@recv.process opts, LEVEL_EXPR}"
      elsif @recv
        recv = @recv.process opts, LEVEL_EXPR
      else
        @recv = SelfNode.new
        recv = @recv.generate opts, LEVEL_EXPR
        mid = '$' + mid
      end

      if @recv.is_a? SelfNode
        recv_code = recv
        recv_arg = recv
      elsif @recv.is_a?(IdentifierNode) and @recv.local_variable?(opts)
        recv_code = recv
        recv_arg = recv
      else
        recv_code = "(#{tmp_recv} = #{recv})"
        recv_arg = "#{tmp_recv}"
      end

      mid = mid_to_jsid mid

      args = @args
      # normal args
      if args[0]
        args[0].each do |arg|
          arg_res << arg.generate(opts, LEVEL_EXPR)
        end
      end

      # hash assoc args
      if args[2]
        arg_res << HashNode.new(args[2], { :line => 0 }, { :line => 0 }).generate(opts, LEVEL_EXPR)
      end

      if @block
        block = @block.generate opts, LEVEL_TOP
        arg_res.unshift recv_arg

        code = "(($B.p = #{block}).$proc = [self], $B.f = "
        code += "#{recv_code}" + mid + ')(' + arg_res.join(', ') + ')'

        opts[:scope].queue_temp tmp_recv
        code

      # &to_proc. Note, this must not reassign the $self for the proc.. we are
      # just passing on an existing block.
      #
      # FIXME need to actually call to_proc.
      elsif args[3]
        arg_res.unshift recv_arg

        code = "($B.p = #{args[3].process opts, LEVEL_LIST}, "
        code += "$B.f = #{recv_code}#{mid})(#{arg_res.join ', '})"

        opts[:scope].queue_temp tmp_recv

        code

      # no block
      else
        # splat args
        if args[1]
          arg_res.unshift tmp_recv
          splat = args[1].generate(opts, LEVEL_EXPR)
          splat_args = arg_res.empty? ? splat : "[#{arg_res.join ', '}].concat(#{splat})"
          # when using splat, our this val for apply may need a tmp var
          # to save just outputting it twice (have to follow recv path twice)
          splat_recv = recv
          result = "(#{tmp_recv} = #{recv})" + mid + ".apply(nil, #{splat_args})"

          opts[:scope].queue_temp tmp_recv
          result
        else
          arg_res.unshift recv_arg

          result = "#{recv_code}" + mid + '(' + arg_res.join(', ') + ')'

          # requeue the tmp receiver as we are done with it and return
          opts[:scope].queue_temp tmp_recv
          result
        end
      end
    end
  end

  class SelfNode < BaseNode
    # We often use a fake SelfNode for filling in gaps, so it takes a default
    # hash to save us manually making one every time.
    def initialize(val = { :line => 0 })
      @line = val[:line]
    end

    def generate(opts, level)
      'self'
    end
  end

  class NilNode < BaseNode
    # Default val hash to save us passing them into fake nodes
    def initialize(val = { :line => 0 })
      @line = val[:line]
    end

    def generate(opts, level)
      'nil'
    end
  end

  class ModuleNode < ScopeNode

    def initialize(mod, path, body, _end)
      super nil, body
      @line = mod[:line]
      @base = path[0]
      @class_name = path[1][:value]
      @end_line = _end[:line]
    end

    def generate(opts, level)
      code = '$class('

      # base
      if @base.nil?
        code += SelfNode.new.generate(opts, level)
      else
        code += 'w'
      end

      code += ', '

      # superclass
      code += (NilNode.new.generate(opts, level) + ', ')

      # module name
      code += "'#{@class_name}', "

      # scope
      scope = { :indent => opts[:indent] + INDENT, :top => opts[:top], :scope => self }
      @statements.returns
      stmt = @statements.generate scope, LEVEL_TOP

      if @scope_vars.empty?
        code += ('function(self) { ' + stmt)
      else
        code += "function(self) {var #{@scope_vars.join ', '};#{stmt}"
      end

      # fix line ending
      code += fix_line_number opts, @end_line
      code += '}, 2)'

      code
    end
  end

  class ClassNode < ScopeNode

    def initialize(cls, path, sup, body, _end)
      super nil, body
      @line = cls[:line]
      @base = path[0]
      @cls_name = path[1]
      @super = sup
      @end_line = _end[:line]
    end

    def generate(opts, level)
      code = '$class('

      # base
      code += (@base.nil? ? SelfNode.new.generate(opts, level) : 'w')
      code += ', '

      # superclass
      code += (@super ? @super.generate(opts, level) : NilNode.new.generate(opts, level))
      code += ', '

      # class name
      code += "'#{@cls_name[:value]}', "

      # scope
      scope = { :indent => opts[:indent] + INDENT, :top => opts[:top], :scope => self }
      @statements.returns
      stmt = @statements.generate scope, level

      if @scope_vars.empty?
        code += "function(self) {#{stmt}"
      else
        code += "function(self) { var #{@scope_vars.join ', '};#{stmt}"
      end

      # fix trailing line number
      code += fix_line_number opts, @end_line

      code += opts[:indent] + '}, 0)'
      code
    end
  end

  class ClassShiftNode < ScopeNode

    def initialize(cls, expr, body, endn)
      super nil, body
      @line = cls[:line]
      @expr = expr
      @end_line = endn[:line]
    end

    def generate(opts, level)
      code = '$class('

      # base
      code += @expr.generate(opts, level)
      code += ', nil, nil, '

      # scope
      scope = { :indent => opts[:indent] + INDENT, :top => opts[:top], :scope => self }
      @statements.returns
      stmt = @statements.generate scope, level

      if @scope_vars.empty?
        code += "function(self) {#{stmt}"
      else
        code += "function(self) { var #{@scope_vars.join ', '};#{stmt}"
      end

      # fix trailing line number
      code += fix_line_number opts, @end_line

      code += opts[:indent] + '}, 1)'
      code
    end
  end

  class DefNode < ScopeNode

    def initialize(defn, singleton, fname, args, body, endn)
      super nil, body
      # do this early
      @line = defn[:line]
      @singleton = singleton
      @fname = fname
      @args = args
      @body = body
      @end_line = endn[:line]
    end

    def generate(opts, level)
      code = '$def('

      # singleton
      code += (@singleton ? @singleton.generate(opts, level) : SelfNode.new.generate(opts, level))
      code += ', '

      # method id
      code += "'#{@fname[:value]}', "

      # all method arg names need to be places in function arg list
      method_args = []

      pre_code = 'var $A = arguments, $M = $A.callee, $L = $A.length;'

      # scope
      scope = { :indent => opts[:indent] + INDENT, :top => opts[:top], :scope => self }

      args = @args

      # normal args
      if args[0]
        args[0].each do |arg|
          param_variable arg[:value]
          method_args << arg[:value]
        end
      end

      # Argument error support - should be optional for debug mode only.
      #
      # We do this after norm args as norm args are the only compulsary
      # ones... we either need an exact amount (norm args only), or
      # atleast some args (opt/rest args + normargs/noargs)
      if true
        # just normal args (or none..)
        if !args[1] && !args[2]
          arg_cnt = method_args.length
          arg_err = "if ($L != #{arg_cnt + 1}) { $ac(#{arg_cnt}, $L - 1); }"

        # no normal args, so all optional!
        elsif method_args.length == 0
          arg_err = ""

        # some normal args, some optional/rest
        else
          arg_cnt = method_args.length
          arg_err = "if ($L < #{arg_cnt + 1}) { $ac(#{arg_cnt}, $L - 1); }"
        end

        pre_code += arg_err
      end

      # optional args
      if args[1]
        args[1].each do |arg|
          param_variable arg[0][:value]
          method_args << arg[0][:value]
          pre_code += "if (#{arg[0][:value]} == undefined) {#{arg[0][:value]} = #{arg[1].generate(opts, LEVEL_EXPR)};}"
        end
      end

      # rest args
      if args[2]
        param_variable args[2][:value]
        method_args << args[2][:value]
        pre_code += "#{args[2][:value]} = [].slice.call($A, #{method_args.length});"
      end

      # block arg
      if args[3]
        param_variable args[3][:value]
        @block_arg_name = args[3][:value]
      end

      @body.returns
      stmt = @body.generate scope, LEVEL_TOP

      method_args.unshift 'self'

      code += "function(#{method_args.join ', '}) { "

      # local vars... only if we used any..
      unless @scope_vars.empty?
        pre_code = "var #{@scope_vars.join ', '};" + pre_code
      end

      # ivars
      @ivars.each do |ivar|
        pre_code += "self['#{ivar}']==undefined&&(self['#{ivar}']=nil);"
      end

      # block arg
      if @block_arg_name
        # pre_code += " var #@block_arg_name = ($block.f == $meth)"
        # pre_code += " ? $block.p : nil; $block.p = $block.f = nil;"

        pre_code += "var $yield, #@block_arg_name; if ($B.f == $M && $B.p != nil) { #@block_arg_name = "
        pre_code += "$yield = $B.p; } else { #@block_arg_name = nil; "
        pre_code += "$yield = $B.y; } $B.p = $B.f = nil;"
        pre_code += "var $yself = $yield.$proc[0];"

        stmt = "try{" + stmt

        # catch break statements
        stmt += "} catch (__err__) {if(__err__.$keyword == 2) {return __err__.$value;} throw __err__;}"
      end

      code += (pre_code + stmt)

      # fix trailing end and 0/1 for normal/singleton
      code += (fix_line_number(opts, @end_line) + "}, #{@singleton ? '1' : '0'})")

      code
    end
  end

  class BodyStatementsNode < BaseNode

    attr_reader :opt_rescue

    def initialize(stmt, optrescue, optelse, optensure)
      @statements = stmt
      @opt_rescue = optrescue
      @opt_else = optelse
      @opt_ensure = optensure
      @line = stmt.line
    end

    def returns
      @statements.returns
    end

    def generate(opts, level)
      @statements.generate opts, level
    end
  end

  class OrNode < BaseNode

    def initialize(node, lhs, rhs)
      @line = node[:line]
      @lhs = lhs
      @rhs = rhs
    end

    def generate(opts, level)
      res = '(('
      tmp = opts[:scope].temp_local
      res += "#{tmp} = #{@lhs.generate opts, LEVEL_LIST}).$r ? "
      res += "#{tmp} : #{@rhs.generate opts, LEVEL_LIST})"
      opts[:scope].queue_temp tmp
      res
    end
  end

  class AndNode < BaseNode

    def initialize(node, lhs, rhs)
      @line = node[:line]
      @lhs = lhs
      @rhs = rhs
    end

    def generate(opts, level)
      res = '(('
      tmp = opts[:scope].temp_local
      res += "#{tmp} = #{@lhs.generate opts, LEVEL_LIST}).$r ? "
      res += "#{@rhs.generate opts, LEVEL_LIST} : #{tmp})"
      opts[:scope].queue_temp tmp
      res
    end
  end

  class ArrayNode < BaseNode

    def initialize(parts, begn, endn)
      @line = begn[:line] || 0
      @end_line = endn[:line] || 0
      @args = parts
    end

    # We should really alter opts[:indent] to temp increase it so that args
    # on a new line are indented to that of the array beg/end
    def generate(opts, level)
      parts = @args[0].map { |arg| arg.process opts, LEVEL_LIST }
      code = "[#{parts.join ', '}#{fix_line_number opts, @end_line}]"

      if @args[1]
        "#{code}.concat(#{@args[1].generate opts, LEVEL_EXPR})"
      else
        code
      end
    end
  end

  class HashNode < BaseNode

    def initialize(parts, begn, endn)
      @line = begn[:line] || 0
      @end_line = endn[:line] || 0
      @parts = parts
    end

    def generate(opts, level)
      parts = @parts.flatten.map { |part| part.process opts, LEVEL_LIST }
      "$hash(#{parts.join ', '}#{fix_line_number opts, @end_line})"
    end
  end

  class IfNode < BaseNode

    def initialize(begn, expr, stmt, tail, endn)
      @line = begn[:line]
      @end_line = endn[:line]
      @expr = expr
      @stmt = stmt
      @tail = tail
    end

    def returns
      @stmt.returns
      # need to apply to each tail item
      @tail.each do |tail|
        if tail[0][:value] == 'elsif'
          tail[2].returns
        else
          tail[1].returns
        end
      end
      self
    end

    def expression?
      @expr_level
    end

    def generate(opts, level)
      code = ''
      done_else = false
      tail = nil
      old_indent = opts[:indent]

      opts[:indent] += INDENT

      # stmt_level is level_top, unless we are an expression.. then it is level_top_closure..
      stmt_level = (level == LEVEL_EXPR ? LEVEL_TOP_CLOSURE : LEVEL_TOP)

      if stmt_level == LEVEL_TOP_CLOSURE
        returns
        @level_expr = true
      end

      expr = @expr.generate opts, LEVEL_EXPR
      expr = "(#{expr})" if @expr.is_a? NumericNode

      # code += "if ((#{@expr.generate opts, LEVEL_EXPR}).$r) {#{@stmt.process opts, stmt_level}"
      code += "if (#{expr}.$r) {#{@stmt.process opts, stmt_level}"

      @tail.each do |tail|
        opts[:indent] = old_indent
        code += fix_line_number opts, tail[0][:line]

        if tail[0][:value] == 'elsif'
          expr = tail[1].generate opts, LEVEL_EXPR
          expr = "(#{expr})" if tail[1].is_a? NumericNode
          code += "} else if (#{expr}.$r) {"
          # code += "} else if ((#{tail[1].generate opts, LEVEL_EXPR}).$r) {"
          opts[:indent] += INDENT
          code += tail[2].process(opts, stmt_level)
        else
          done_else = true
          code += '} else {'
          opts[:indent] += INDENT
          code += tail[1].process(opts, stmt_level)
        end
      end

      if @force_else
        # generate an else statement if we MUST have one. If, for example, we
        # set the result of ourself as a variable, we must have an else part
        # which simply returns nil.
      end

      opts[:indent] = old_indent
      code += (fix_line_number(opts, @end_line) + '}')

      # if we were an expression, we need to wrap ourself as closure
      code = "(function() {#{code}})()" if level == LEVEL_EXPR
      code
    end
  end

  class CaseNode < BaseNode

    def initialize(begn, expr, body, endn)
      @line = begn[:line]
      @expr = expr
      @body = body
      @end_line = endn[:line]
    end

    def returns
      @body.each do |part|
        if part[0][:value] == 'when'
          part[2].returns
        else
          part[1].returns
        end
      end
      self
    end

    def generate(opts, level)
      code = ''
      done_else = false
      tail = nil
      old_indent = opts[:indent]

      opts[:indent] += INDENT

      stmt_level = (level == LEVEL_EXPR ? LEVEL_TOP_CLOSURE : LEVEL_TOP)

      if stmt_level == LEVEL_TOP_CLOSURE
        returns
        @level_expr = true
      end

      expr = @expr.generate opts, LEVEL_EXPR
      case_ref = opts[:scope].temp_local

      code += "#{case_ref} = #{expr};"

      @body.each_with_index do |part, idx|
        opts[:indent] = old_indent
        code += fix_line_number opts, part[0][:line]

        if part[0][:value] == 'when'
          code += (idx == 0 ? "if" : "} else if")
          parts = part[1].map do |expr|
            CallNode.new(expr,
                        {:value => '===' },
                        [[TempNode.new(case_ref)]]
            ).generate(opts, LEVEL_EXPR) + '.$r'
          end
          opts[:indent] += INDENT
          code += " (#{parts.join ' || '}) {#{part[2].process opts, stmt_level}"
        else
          code += "} else {#{part[1].process opts, stmt_level}"
        end
      end

      opts[:indent] = old_indent

      opts[:scope].queue_temp case_ref
      code += (fix_line_number(opts, @end_line) + '}')

      code = "(function() {#{code})()" if level == LEVEL_EXPR
      code
    end
  end

  class TempNode < BaseNode

    def initialize(val)
      @val = val
      @line = 0
    end

    def generate(opts, level)
      @val
    end
  end

  class ConstantNode < BaseNode

    def initialize(name)
      @line = name[:line]
      @name = name[:value]
    end

    def value
      @name
    end

    def generate(opts, level)
      "rb_vm_cg(#{SelfNode.new.generate opts, level}, '#{@name}')"
    end
  end

  class Colon2Node < BaseNode

    def initialize(lhs, name)
      @lhs = lhs
      @line = name[:line]
      @name = name[:value]
    end

    def generate(opts, level)
      # FIXME This should really be 'const at'.. const_get will relook all the way up chain
      "rb_vm_cg(#{@lhs.generate opts, level}, '#{@name}')"
    end
  end

  class Colon3Node < BaseNode

    def initialize(name)
      @line = name[:line]
      @name = name[:value]
    end

    def generate(opts, level)
      "rm_vm_cg($opal.Object, '#{@name}')"
    end
  end

  class AssignNode < BaseNode

    def initialize(lhs, rhs, assign = {})
      @line = lhs.line
      @lhs = lhs
      @rhs = rhs
    end

    def generate(opts, level)
      if @lhs.is_a? IvarNode
        return "#{SelfNode.new.generate(opts, level)}['#{@lhs.value}'] = #{@rhs.generate(opts, LEVEL_EXPR)}"

      elsif @lhs.is_a? GvarNode
        return "$runtime.gs('#{@lhs.value}', #{@rhs.generate(opts, LEVEL_EXPR)})"

      elsif @lhs.is_a? IdentifierNode
        opts[:scope].ensure_variable @lhs.value
        return @lhs.value + " = " + @rhs.generate(opts, LEVEL_EXPR)

      elsif @lhs.is_a? ArefNode
        return AsetNode.new(@lhs.recv, @lhs.arefs, @rhs).process(opts, level)

      elsif @lhs.is_a? ConstantNode
        return "rb_vm_cs(self, '#{@lhs.value}', #{@rhs.generate(opts, LEVEL_EXPR)})"

      elsif @lhs.is_a? CallNode
        return CallNode.new(@lhs.recv, { :value => @lhs.mid + '=', :line => @line }, [[@rhs]]).generate(opts, level);

      else
        raise "Bad lhs for assign on #{@line}"
      end
    end
  end

  class MlhsAssignNode < BaseNode

    def initialize(node, lhs, rhs)
      @line = node[:line]
      @lhs = lhs
      @rhs = rhs
    end

    def generate(opts, level)
      @lhs.inspect
      @generator_opts = opts
      '(' + generate_mlhs_context(@lhs, @rhs) + ')'
    end

    def generate_mlhs_context(arr, rhs)
      puts "mlhs node at #@line"
      parts = []

      tmp_recv = @generator_opts[:scope].temp_local
      tmp_len = @generator_opts[:scope].temp_local
      rhs_code = rhs.generate @generator_opts, LEVEL_EXPR

      parts << "#{tmp_recv} = #{rhs_code}"
      parts << "(#{tmp_recv}.$flags & $runtime.T_ARRAY) || (#{tmp_recv} = [#{tmp_recv}])"
      parts << "#{tmp_len} = #{tmp_recv}.length"

      if arr[0]
        arr[0].each_with_index do |part, idx|
          if part.is_a? Array
            parts.push generate_mlhs_context part, rhs
          else
            assign = AssignNode.new part, TempNode.new("#{tmp_recv}[#{idx}]")
            code = assign.generate @generator_opts, LEVEL_EXPR
            parts.push "#{idx} < #{tmp_len} ? #{code} : nil"
            # parts.push assign.generate @generator_opts, LEVE<D-/>L_EXPR
          end
        end
      end

      parts << tmp_recv

      @generator_opts[:scope].queue_temp tmp_recv
      @generator_opts[:scope].queue_temp tmp_len

      parts.join ', '
    end
  end

  class OpAsgnNode < BaseNode

    def initialize(asgn, lhs, rhs)
      @line = asgn[:line]
      @lhs  = lhs
      @rhs  = rhs
      @asgn = asgn[:value]
    end

    def generate(opts, level)
      assign = nil

      if @asgn == '||'
        assign = OrNode.new({:value => '||', :line => @line }, @lhs, AssignNode.new(@lhs, @rhs))
      elsif %w[+ - / *].include? @asgn
        assign = AssignNode.new @lhs, CallNode.new(@lhs, {:value => @asgn, :line => @line}, [[@rhs]])
      else
        raise "Bas op asgn type: #{@asgn}"
      end
      assign.generate(opts, level)
    end
  end

  class IvarNode < BaseNode

    attr_reader :value

    def initialize(val)
      @line = val[:line]
      @value = val[:value]
    end

    def generate(opts, level)
      opts[:scope].ensure_ivar @value
      "#{SelfNode.new.generate(opts, level)}['#{@value}']"
    end
  end

  class IdentifierNode < BaseNode
    attr_reader :value

    def initialize(val)
      @line = val[:line]
      @value = val[:value]
    end

    def local_variable?(opts)
      opts[:scope].find_variable(@value) ? true : false
    end

    def generate(opts, level)
      if opts[:scope].find_variable @value
        @value
      else
        CallNode.new(nil, { :value => @value, :line => @line }, [[]]).generate(opts, level)
      end
    end
  end

  class FuncReturnNode < BaseNode

    def initialize(val)
      @value = val
      @line = val.line
    end

    def generate(opts, level)
      "return #{@value.generate opts, level}"
    end
  end

  class StringNode < BaseNode

    def initialize(parts, endn)
      @line = endn[:line]
      @parts = parts
      @join = endn[:value]
    end

    def generate(opts, level)
      if @parts.length == 0
        "''"
      elsif @parts.length == 1
        if @parts[0][0] == 'string_content'
          @join + @parts[0][1][:value] + @join
        elsif @parts[0][0] == 'string_dbegin'
          CallNode.new(@parts[0][1], { :value => 'to_s', :line => 0 }, [[]]).generate(opts, level)
        end

      else
        parts = @parts.map do |part|
          if part[0] == 'string_content'
            @join + part[1][:value] + @join
          elsif part[0] == 'string_dbegin'
            CallNode.new(part[1], { :value => 'to_s', :line => 0 }, [[]]).generate(opts, level)
          end
        end

        '(' + parts.join(' + ') + ')'
      end
    end
  end

  class TrueNode < BaseNode

    def initialize(val)
      @line = val[:line]
    end

    def generate(opts, level)
      "Qtrue"
    end
  end

  class FalseNode < BaseNode

    def initialize(val)
      @line = val[:line]
    end

    def generate(opts, level)
      "Qfalse"
    end
  end

  class BlockNode < ScopeNode

    def initialize(start, vars, stmt, endn)
      super nil, stmt
      @line = start[:line]
      @args = vars
      @stmt = stmt
      @end_line = endn[:line]
    end

    def generate(opts, level)
      @parent   = opts[:scope]
      pre_code  = ''
      code      = ''

      scope = { :scope => self, :top => opts[:top], :indent => opts[:indent] + INDENT }
      args = @args[0]
      method_args = []

      if args
        # normal args
        if args[0]
          args[0].each do |arg|
            param_variable arg[:value]
            method_args << arg[:value]

            # Argument checking.. If normal args are required but not passed
            # they just default to nil. Lambdas have the same effect as
            # methods, so we check this by wrapping lambdas in an anon
            # function that knows the arity of this block. So here, make all
            # norm args nil if not present.
            #
            # Also, this is optional, and can be turned on/off for
            # performance gains.
            if true
              pre_code += "if (#{arg[:value]} === undefined) { #{arg[:value]} = nil; }"
            end
          end
        end

        # optional args
        if args[1]
          args[1].each do |arg|
            opt_arg_name = arg[0][:value]
            param_variable opt_arg_name
            method_args << arg[0][:value]
            pre_code += "if (#{opt_arg_name} === undefined) { #{opt_arg_name} = #{arg[1].generate(opts, level)};}"
          end
        end

        # rest args
        if args[2]
          # ignore rest arg if it is anonymous
          unless args[2][:value] == '*'
          rest_arg_name = args[2][:value]
          # FIXME if we just pass '*', then we make a tmp variable name for it..
          param_variable rest_arg_name
          method_args << rest_arg_name
          pre_code += "#{rest_arg_name} = [].slice.call($args, #{method_args.length});"
          end
        end
      end

      @stmt.returns
      stmt = @stmt.process scope, LEVEL_TOP
      method_args.unshift 'self'

      block_var = opts[:scope].temp_local
      # code += "(#{block_var} = "

      code += "function(#{method_args.join ', '}) {"

      # code += "var $meth = arguments.callee.$meth;"
      code += "var $A = arguments, $L = $A.length;"

      unless @scope_vars.empty?
        code += " var #{@scope_vars.join ', '};"
      end

      code += (pre_code + stmt + fix_line_number(opts, @end_line) + "}")

      # code += ", #{block_var}.$arity = 0, #{block_var}.$meth = null"
      # code += ", #{block_var})"
      opts[:scope].queue_temp block_var
      code
    end
  end

  class XStringNode < BaseNode

    def initialize(begn, parts, endn)
      @line = begn[:line]
      @parts = parts
      @end_line = endn[:line]
    end

    # we dont want return for xstring.. or do we? no..
    def returns
      self
    end

    # Treat ourself like an expression. All xstrings should add their own
    # semi-colons etc, so we can allow if, return, etc.
    def expression?
      false
    end

    def generate(opts, level)
      parts = @parts.map do |part|
        if part[0] == 'string_content'
          part[1][:value]
        elsif part[0] == 'string_dbegin'
          part[1].generate opts, LEVEL_EXPR
        end
      end

      parts.join ''
    end
  end

  class ParenNode < BaseNode

    def initialize(opening, parts, closing)
      @line = opening[:line]
      @parts = parts
      @end_line = closing[:line]
    end

    def generate(opts, level)
      parts = @parts.nodes.map do |part|
        part.generate opts, LEVEL_EXPR
      end

      # if no parens, then we need to eval to nil
      parts << 'nil' if parts.empty?

      "(#{parts.join ', '})"
    end
  end

  class ArefNode < BaseNode

    attr_reader :recv

    attr_reader :arefs

    def initialize(recv, arefs)
      @line = recv.line
      @recv = recv
      @arefs = arefs
    end

    def generate(opts, level)
      CallNode.new(@recv, { :line => @line, :value => '[]'}, @arefs).generate opts, level
    end
  end

  class AsetNode < BaseNode

    def initialize(recv, arefs, val)
      @line = recv.line
      @recv = recv
      @arefs = arefs
      @val = val
    end

    def generate(opts, level)
      (@arefs[0] ||= []) << @val
      CallNode.new(@recv, { :line => @line, :value => '[]='}, @arefs ).generate(opts, level)
    end
  end

  # Used for post form of IF and UNLESS statements
  class IfModNode < BaseNode

    def initialize(type, expr, stmt)
      @line = type[:line]
      @type = type[:value]
      @expr = expr
      @stmt = stmt
    end

    # If we return, that means our "else" result - which is not generated by
    # default, needs to return nil (as it might be needed if our if statement
    # does not evaluate truthy
    def returns
      @returns = true
      @stmt = @stmt.returns
      self
    end

    def generate(opts, level)
      # if we return, make sure our stmt does
      @stmt.returns if @returns

      r = "if(#{@type == 'if' ? '' : '!'}(#{@expr.generate(opts, LEVEL_EXPR)}"
      r += ").$r) {#{@stmt.process(opts, LEVEL_TOP)}}"

      # also, if we return, we need to ensure we have an else conditional
      r += " else { return nil; }" if @returns
      r
    end
  end

  class BlockGivenNode < BaseNode

    def initialize(given)
      @line = given[:line]
    end

    def generate(opts, level)
      name = opts[:scope].set_uses_block
      "(#{name} !== nil ? Qtrue : Qfalse)"
    end
  end

  class YieldNode < BaseNode

    def initialize(start, args)
      @line = start[:line]
      @args = args
    end

    def generate(opts, level)
      # need to get block from nearest method
      block = opts[:scope].set_uses_block

      # block_code = "(#{block} == nil ? $block.y : #{block})"
      block_code = "$yield"

      parts = ["$yself"]

      if @args[0]
        @args[0].each { |arg| parts << arg.generate(opts, LEVEL_EXPR) }
      end

      if @args[1]
        "#{block_code}.apply(null, [#{parts.join ', '}].concat(#{@args[1].generate(opts, LEVEL_EXPR)}))"
      else
        "#{block_code}(#{parts.join ', '})"
      end

      # "#{block}(#{parts.join ', '})"
    end
  end

  class BreakNode < BaseNode

    def initialize(start, args)
      @line = start[:line]
      @args = args
    end

    def generate(opts, level)
      code = []

      if @args[0]
        @args[0].each { |arg| code << arg.generate(opts, LEVEL_EXPR) }
      end

      case code.length
      when 0
        code = "nil"
      when 1
        code = code[0]
      else
        code = '[' + code.join(', ') + ']'
      end

      if opts[:scope].in_while_scope?
        while_scope = opts[:scope].while_scope
        tmp_break_val = while_scope.set_captures_break
        "#{tmp_break_val} = #{code}; break"
      else
        "$break(#{code})"
      end
    end
  end

  class NextNode < BaseNode

    def initialize(start, args)
      @line = start[:line]
      @args = args
    end

    def returns
      self
    end

    def generate(opts, level)
      code = []

      if @args[0]
        @args[0].each { |arg| code << arg.generate(opts, LEVEL_EXPR) }
      end

      case code.length
      when 0
        code = "nil"
      when 1
        code = code[0]
      else
        code = '[' + code.join(', ') + ']'
      end

      if opts[:scope].in_while_scope?
        "continue"
      else
      # if in block
        "return #{code}"
      # else if in while/until loop

      end
    end
  end

  class RedoNode < BaseNode

    def initialize(start)
      @line = start[:line]
    end

    def generate(opts, level)
      if opts[:scope].in_while_scope?
        "#{opts[:scope].while_scope.redo_var} = true"
      else
        "REDO()"
      end
    end
  end

  class WhileNode < BaseNode

    attr_reader :redo_var

    def initialize(begn, exp, stmt, endn)
      @line = begn[:line]
      @type = begn[:value]
      @expr = exp
      @stmt = stmt
      @end_line = endn[:line]
    end

    def returns
      @returns = true
      self
    end

    def set_captures_break
      tmp = @current_scope.temp_local
      @captures_break = tmp
    end

    def generate(opts, level)
      @current_scope = opts[:scope]
      stmt_level = (level == LEVEL_EXPR ? LEVEL_TOP_CLOSURE : LEVEL_TOP)
      truthy = @type == 'while' ? '' : '!'

      if stmt_level == LEVEL_TOP_CLOSURE
        returns
        @level_expr = true
      end

      @redo_var = eval_expr = opts[:scope].temp_local
      code = "#{eval_expr} = false; while (#{eval_expr} || #{truthy}("
      code += @expr.generate opts, LEVEL_EXPR
      code += ").$r) {#{eval_expr} = false;"

      opts[:scope].push_while_scope self

      code += @stmt.process opts, LEVEL_TOP

      opts[:scope].pop_while_scope

      code += fix_line_number opts, @end_line
      code += "}"

      opts[:scope].queue_temp eval_expr

      return_value = "nil"

      if @captures_break
        code = "#@captures_break = nil; #{code}"
        opts[:scope].queue_temp @captures_break
        return_value = @captures_break
      end

      code = "(function() {#{code} return #{return_value};})()" if stmt_level == LEVEL_TOP_CLOSURE
      code
    end
  end

  class SuperNode < BaseNode

    def initialize(start, args)
      @line = start[:line]
      @args = args
    end

    def generate(opts, level)
      parts = []

      if @args[0]
        @args[0].each { |arg| parts << arg.generate(opts, LEVEL_EXPR) }
      end

      "$super($meth, self, [#{parts.join ', '}])"
    end
  end

  class ReturnNode < BaseNode

    def initialize(ret, val)
      @line = ret[:line]
      @args = val
    end

    def returns
      self
    end

    def generate(opts, level)
      args = @args

      if args[0].nil?
        code = NilNode.new.generate opts, level
      elsif args[0].length == 1
        code = args[0][0].generate opts, level
      else
        # this really should return array of return vals
        code = NilNode.new.generate opts, level
      end

      # if we are in a block, we need to throw return to nearest mthod
      if !opts[:scope].is_a?(DefNode)
        return_func = '__return_func'
        return "$return(#{code}, #{return_func})"

      # level top, we are running full stmts, so just return normally
      elsif level == LEVEL_TOP
        return "return #{code}"
      else
        "$return(#{code})"
      end
    end
  end

  class BeginNode < BaseNode

    def initialize(beginn, body, endn)
      @line = beginn[:line]
      @body = body
      @end_line = endn[:line]
    end

    def generate(opts, level)
      code = "try {"
      old_indent = opts[:indent]
      opts[:indent] += INDENT

      code += @body.process opts, LEVEL_TOP
      code += "} catch (__err__) {"

      @body.opt_rescue.each do |res|
        code += "#{fix_line_number opts, res[0][:line]}if (true){"
        opts[:indent] += INDENT
        opts[:scope].ensure_variable res[2].value if res[2]
        code += (res[2].value + " = __err__;") if res[2]
        code += "#{res[3].process opts, LEVEL_TOP}}"
        opts[:indent] = old_indent + INDENT
      end


      opts[:indent] = old_indent
      code += (fix_line_number(opts, @end_line) + "}")
      code
    end
  end

  class GvarNode < BaseNode

    attr_reader :value

    def initialize(val)
      @line = val[:line]
      @value = val[:value]
    end

    def generate(opts, level)
      "$runtime.gg('#{@value}')"
    end
  end

  class FileNode < BaseNode

    def initialize(val)
      @line = val[:line]
    end

    def generate(opts, level)
      "__FILE__"
    end
  end

  class LineNode < BaseNode

    def initialize(val)
      @line = val[:line]
      @val = val[:value]
    end

    def generate(opts, level)
      @val
    end
  end

  class RegexpNode < BaseNode

    def initialize(begn, parts)
      @line = begn[:line]
      @parts = parts
    end

    def generate(opts, level)
      parts = @parts.map do |part|
        if part[0] == 'string_content'
          part[1][:value]
        elsif part[0] == 'string_dbegin'
          part[1].generate opts, LEVEL_EXPR
        end
      end

      "/#{parts.join ''}/"
    end
  end

  class WordsNode < BaseNode

    def initialize(begn, parts, endn)
      @line = begn[:line]
      @parts = parts
      @end_line = endn[:line]
    end

    def generate(opts, level)
      parts = @parts.map do |part|
        if part[0] == 'string_content'
          part[1][:value].inspect
        else
          CallNode.new(part[1], {:value => 'to_s', :line => @line }, []).generate(opts, LEVEL_EXPR)
        end
      end

      '[' + parts.join(', ') + ']'
    end
  end

  class RangeNode < BaseNode

    def initialize(range, beg, last)
      @line = beg.line
      @beg = beg
      @last = last
      @range = range[:value]
      @end_line = last.line
    end

    def generate(opts, level)
      beg = @beg.generate opts, LEVEL_EXPR
      last = @last.generate opts, LEVEL_EXPR
      excl = @range == '...'
      "$range(#{beg}, #{last}, #{excl})"
    end
  end
end
end

