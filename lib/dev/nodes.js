var Rp = opal.dev.RubyParser.prototype;

// Inheritence for nodes
var extend = function(subclass, superclass) {
  for (var key in superclass) {
    if (superclass.hasOwnProperty(key)) {
      subclass[key] = superclass[key];
    }
  }

  var cons = function() {};
  cons.prototype = superclass.prototype;
  subclass.prototype = new cons();
  subclass.__super__ = superclass.prototype;
  return subclass;
};

// Indent for generated code scopes; 2 spaces, never use tabs.
var INDENT = '  ';

var LEVEL_TOP         = 0; // normal top level statements
var LEVEL_TOP_CLOSURE = 1; // normal top level, but wrapped ina  closure - return needs to throw, etc
var LEVEL_LIST        = 2;
var LEVEL_EXPR        = 3;

// Base node. All other nodes inherit from this.
var BaseNode = function() {
  return this;
};

// Generate the code for this node. MUST override in subclasses.
BaseNode.prototype.generate = function() {
  return '';
};

// Makes the node return its value. Overriden by various subclasses.
// This is not for use with the ruby return statement, this just means that
// the generated scope requires us to return wihin javascript. The return stmt
// in ruby uses another method for returning.
BaseNode.prototype.returns = function() {
  // this is not a VM return, it just means return out of func
  return new FuncReturnNode(this);
};

// By default all nodes are expressions (';' to finish them). Statements override
// this to be false.
BaseNode.prototype.isExpression = function() {
  return true;
};

// processes the node which generates it. By default, process will also fix the
// line number etc. Some nodes override this as they need a slightly different
// approach. This will also set the level for indentation?? To generate, but not
// indent or fix line number, you may call .generate() directly. Note that this
// relies on the level. If the level is LEVEL_LIST, for example, then a node will
// not correct its line number or indentation.
BaseNode.prototype.process = function(opts, level) {
  if (level <= LEVEL_LIST) {
    return this.fixLineNumber(opts) + this.generate(opts, level);
  } else {
    return this.generate(opts, level);
  }
};

// Fix the line number for nodes that want to (calls etc)
BaseNode.prototype.fixLineNumber = function(opts, line) {
    var code = '';
    // make sure we are at the right line.
    var targetLine = (line || this.line), currentLine = opts.top.line;
    // console.log(targetLine + " ... " + currentLine);
    if (currentLine < targetLine) {
      for (var j = (targetLine - currentLine); j > 0; j--) {
        opts.top.line++;
        code += '\n';
      }

      code += opts.indent;
      // console.log(currentLine - targetLine);
    }
    return code;
};

// Scoped nodes - all scope nodes inherit from this: method, class, def, etc.
var ScopeNode = function(parent, statements) {
  this.parent = parent;
  this.statements = statements;
  // all variables - arg, temps, params etc
  this.variables = [];
  // all vars for scope and temp
  this.scopeVars = [];
  // temps
  this.temp_current = {};
  this.temp_queue = {};
  // ivars.. we need to make sure these exist (make sure they are nil if new)
  this.ivars = [];

  this.temp_queue = [];
  this.temp_current = 'a';
};

extend(ScopeNode, BaseNode);

ScopeNode.prototype.ensureIvar = function(name) {
  this.ivars.push(name);
};

ScopeNode.prototype.paramVariable = function(name) {
  this.variables.push(name);
};

ScopeNode.prototype.ensureVariable = function(name) {
  var variable;

  if (variable = this.findVariable(name)) {
    return variable;
  }

  // does not exist in scope
  this.scopeVars.push(name);
  return this.variables.push(name);
};

ScopeNode.prototype.findVariable = function(name) {
  var scope = this;

  while (scope) {
    
    if (scope.variables.indexOf(name) != -1) {
      return name;
    }

    if ((scope instanceof BlockNode) && scope.parent) {
      scope = scope.parent;
    } else {
      break;
    }
  }

  return null;
};

ScopeNode.prototype.temp_local = function() {
  if (this.temp_queue.length) {
    return this.temp_queue.pop();
  }

  var name = '__' + this.temp_current;
  this.scopeVars.push(name);
  this.temp_current = String.fromCharCode(this.temp_current.charCodeAt(0) + 1);
  return name;
};

ScopeNode.prototype.queue_temp = function(temp) {
  this.temp_queue.push(temp);
};

ScopeNode.prototype.set_uses_block = function() {
  if (this._block_arg_name) {
    return this._block_arg_name;
  }

  this._block_arg_name = '__block__';
  return this._block_arg_name;
};

ScopeNode.prototype.generate = function(opts, level) {
  var stmts = this.statements.generate(opts, level);
  var vars = '';

  return vars + stmts;
};

// Top level scope. This also manages things like line numbers etc. All opts will 
// be passed a .top property that references this root scope (instead of manually
// traversing it each time)
var TopScopeNode = Rp.TopScopeNode = function(statements) {
  ScopeNode.call(this, null, statements);
  // helpers we need at top of file
  this.file_helpers = [];
  // keep track of the line number
  this.line = 1;
  this.mm_ids = [];
  return this;
};

extend(TopScopeNode, ScopeNode);

TopScopeNode.prototype.register_mm_id = function(mid) {
  if (this.mm_ids.indexOf(mid) == -1) {
    this.mm_ids.push(mid)
  }
};

TopScopeNode.prototype.generate = function(opts, level) {
  var code = [];
  // super()
  code.push(ScopeNode.prototype.generate.call(this, opts, level));

  // pre
  var pre = '$$init();', post;

  post = "\n\nvar nil, $ac, $super, $break, $class, $def, $symbol, $range, ";
  post += '$hash, $B, Qtrue, Qfalse;';

  if (this.scopeVars.length != 0) {
    post += ('var ' + this.scopeVars.join(', ') + ';');
  }

  post += "\nfunction $$init() {";
  post += 'nil = $runtime.Qnil, $ac = $runtime.ac, $super = $runtime.S, $break = $runtime.B, ';
  post += '$class = $runtime.dc, $def = $runtime.dm, $symbol = $runtime.Y, $range = $runtime.G, ';
  post += '$hash = $runtime.H, $B = $runtime.P, Qtrue = $runtime.Qtrue, Qfalse = $runtime.Qfalse;';


  // method missing
  if (this.mm_ids.length > 0) {
    var mm_ids = "$runtime.mm(['" + this.mm_ids.join("', '") + "']);";
    post += mm_ids;
  }

  for (var i = 0; i < this.ivars.length; i++) {
    post += ("if (self['" + this.ivars[i] + "'] == undefined) { self['" + this.ivars[i] + "'] = nil; }");
  }

  return pre + code.join('') + post;
};

// Statements - represents any chain of statements
var StatementsNode = Rp.StatementsNode = function(nodes) {
  this.nodes = nodes || [];
  return this;
};

extend(StatementsNode, BaseNode);

StatementsNode.prototype.returns = function() {
  if (this.nodes.length > 0) {
    // this.nodes[this.nodes.length - 1] = new ReturnNode({line: this.line}, [[this.nodes[this.nodes.length - 1]]]);
    this.nodes[this.nodes.length - 1] = this.nodes[this.nodes.length - 1].returns();
  } else {
    this.nodes[0] = (new FuncReturnNode(new NilNode({})));
  }
};

StatementsNode.prototype.generate = function(opts, level) {
  var code = [], node;
  for (var i = 0; i < this.nodes.length; i++) {
    node = this.nodes[i];


    var nodeCode = this.nodes[i].process(opts, LEVEL_TOP);
    // console.log("LEVEL is " + level);
    if (level <= LEVEL_TOP_CLOSURE) {
      // to prevent lots of trailing whitespace when we generate statements on new lines,
      // we only insert indent if we dont have a newline marker straight away.
      if (nodeCode.charAt(0) == '\n') {
        code.push(nodeCode);
      } else {
        code.push(opts.indent + nodeCode);
      }
      // if expression, add ';' .. statements dont need ';'
      // we MUST call this after we generate it, as some stmts may determine themselves
      // during compilation. for example, IfNode does depending on whether it needs to
      // generate as a level_top or a level_top_closure
      if (node.isExpression()) { code.push(';'); }

    } else {
      code.push(nodeCode);
    }
      // indent? we should add it here if the LEVEL is top level.. (or normal stmt
    // level)... currently no indentation
  }
  return code.join('');
};


// Push more statements onto end
StatementsNode.prototype.push = function(node) {
  this.nodes.push(node);
  return this;
};

// Generate statements for the top level - generally used for files
StatementsNode.prototype.generateTop = function(opts) {
  opts = opts || {};
  var scope = new TopScopeNode(this);
  opts.scope = scope;
  opts.indent = '';
  opts.top = scope;
  return scope.generate(opts, LEVEL_TOP);
  // return "shake sgake boom";
};

var NumericNode = Rp.NumericNode = function(val) {
  this.value = val.value;
  this.line = val.line;
  return this;
};

extend(NumericNode, BaseNode);

NumericNode.prototype.generate = function(opts) {
  return this.value;
};

var SymbolNode = Rp.SymbolNode = function(val) {
  this.val = val.value;
  this.line = val.line;
  return this;
};

extend(SymbolNode, BaseNode);

SymbolNode.prototype.generate = function(opts) {
  return '$symbol("' + this.val + '")';
};

var CallNode = Rp.CallNode = function(recv, mid, args) {
  this.recv = recv;
  this.mid = mid.value;
  this.args = args;
  // our initial line is where our receiver's line starts. method name might be
  // on a subsiquint line, e.g. calling the result of an IF stmt
  this.line = recv ? recv.line : mid.line;
  return this;
};

extend(CallNode, BaseNode);

CallNode.prototype.mid_to_jsid = function(id) {

  if(/[\!\=\?\+\-\*\/\^\&\%\@\|\[\]\<\>\~]/.exec(id)) {
    return '.$m["' + id + '"]';
  }

  if (this.js_reserved_words.indexOf(id) != -1) {
    return ".$m['" + id + "']";
  }

  return '.$m.' + id;
};

CallNode.prototype.js_reserved_words = [
  'break', 'case', 'catch', 'continue', 'debugger', 'default', 'delete', 'do',
  'else', 'finally', 'for', 'function', 'if', 'in', 'instanceof', 'new',
  'return', 'switch', 'this', 'throw', 'try', 'typeof', 'var', 'void',
  'while', 'with', 'class', 'enum', 'export', 'extends', 'import', 'super'
];

CallNode.prototype.generate = function(opts) {
  if ((this.recv instanceof NumericNode) && (this.mid == '-@')) {
    this.recv.value = '-' + this.recv.value;
    return this.recv.generate(opts, LEVEL_EXPR);
  }
  // var code = this.fixLineNumber(opts);
  var code = '', arg_res = [], recv, mid, result;

  var tmp_recv = opts.scope.temp_local();

  mid = this.mid;

  opts.top.register_mm_id(this.mid);

  // recv
  if (this.recv instanceof NumericNode) {
    recv = ('(' + this.recv.process(opts, LEVEL_EXPR) + ')');
  } else if (this.recv) {
    recv = this.recv.process(opts, LEVEL_EXPR);
  } else {
    this.recv = new SelfNode({});
    recv = this.recv.generate(opts);
    mid = '$' + mid;
  }

  var recv_code, recv_arg;

  if (this.recv instanceof SelfNode) {
    recv_code = recv;
    recv_arg = recv;
  } else if ((this.recv instanceof IdentifierNode) && opts.scope.findVariable(this.recv.value)) {
    recv_code = recv;
    recv_arg = recv;
  } else {
    recv_code = "(" + tmp_recv + " = " + recv + ")";
    recv_arg = tmp_recv;
  }

  // mid
  mid = this.mid_to_jsid(mid);

  // args
  var args = this.args;
  // norm
  if (args[0]) {
    for (var i = 0; i < args[0].length; i++) {
      arg_res.push(args[0][i].generate(opts, LEVEL_EXPR));
    }
  }

  // hash assoc args
  if (args[2]) {
    arg_res.push((new HashNode(args[2], { line: 0 }, { line: 0 })).generate(opts, LEVEL_EXPR));
  }

  if (this.block) {
    var block = this.block.generate(opts, LEVEL_TOP);
    arg_res.unshift(recv_arg);

    var code = "(($B.p = " + block + ").$proc = [self], $B.f = ";
    code += (recv_code + mid + ")(" + arg_res.join(', ') + ")");

    opts.scope.queue_temp(tmp_recv);

    return code;

  // &to_proc. Note: this must NOT reassign the $self for the proc... we are just
  // passing an existing block on.
  } else if (args[3]) {
    arg_res.unshift recv_arg

    var code = "($B.p = " + args[3].process(opts, LEVEL_LIST) + ", ";
    code += ("$B.f = " + recv_code + mid + ")(" + arg_res.join(', ') + ")");

    opts.scope.queue_temp(tmp_recv);
    return code;

  // no block..
  } else {

    // splat args
    if (args[1]) {
      var splat = args[1].generate(opts);
      return recv + mid + '.apply' + '(' + recv + ', [' + arg_res.join(', ') + '].concat(' + splat + '))';
    } else {
      arg_res.unshift(recv_arg);

      result = recv_code + mid + '(' + arg_res.join(', ') + ')';

      opts.scope.queue_temp(tmp_recv);
      return result;
    }
    // code += (recv + mid);
  }

  // return code + '(' + arg_res.join(', ') + ')';
};

var SelfNode = Rp.SelfNode = function(val) {
  this.line = val.line;
  return this;
};

extend(SelfNode, BaseNode);

SelfNode.prototype.generate = function(opts) {
  return 'self';
};

var NilNode = Rp.NilNode = function(val) {
  this.line = val.line;
  return this;
};

extend(NilNode, BaseNode);

NilNode.prototype.generate = function(opts) {
  return 'nil';
};

var ModuleNode = Rp.ModuleNode = function(mod, path, body, end) {
  ScopeNode.call(this, null, body);
  this.line = mod.line;
  this.base = path[0];
  this.clsName = path[1].value;
  this.endLine = end.line;
  return this;
};

extend(ModuleNode, BaseNode);

ModuleNode.prototype.generate = function(opts) {
  var code = '$class(';

  // base
  if (this.base == null) {
    code += (new SelfNode({})).generate(opts);
  } else {
    code += "w";
  }

  code += ', ';

  // superclass
  code += ((new NilNode({})).generate(opts) + ', ');

  // module name
  code += ('"' + this.clsName + '", ');

  // scope
  
  var scope = { indent: opts.indent + INDENT, top: opts.top, scope: this };
  var stmt = this.statements.generate(scope, LEVEL_TOP);
  code += "function() {";

  code += 'var self = this;';

  code += stmt;

  // fix ending line number
  var currentLine = opts.top.line, targetLine = this.endLine;
  for (var i = (targetLine - currentLine); i > 0; i--) {
    opts.top.line++;
    code += '\n';
  }

  code += opts.indent + '}, 2)';

  return code;
};

var ClassNode = Rp.ClassNode = function(cls, path, sup, body, end) {
  ScopeNode.call(this, null, body);
  this.scopeVars.push('self = this');
  this.line = cls.line;
  this.base = path[0];
  this.clsName = path[1];
  this.sup = sup;
  // we keep the end line number as its useful for keeping the generated '})' 
  // on the matching line to the source
  this.endLine = end.line;
};

extend(ClassNode, ScopeNode);

ClassNode.prototype.generate = function(opts) {
  var code = '$class(';

  // base
  if(this.base == null) {
    code += (new SelfNode({})).generate(opts);
  } else {
    code += "w";
  }

  code += ', ';

  // superclass
  if (this.sup) {
    code += this.sup.generate(opts);
  } else {
    code += (new NilNode({})).generate(opts);
  }

  code += ', ';

  // class name
  code += ('"' + this.clsName.value + '", ');

  // generate scope?
  var scope = { indent: opts.indent + INDENT, top: opts.top, scope: this };
  var stmt = this.statements.generate(scope, LEVEL_TOP);
  code += "function() {";
  code += ('var ' + this.scopeVars.join(', ') + ';');
  code += stmt;

  // fix ending line number
  var currentLine = opts.top.line, targetLine = this.endLine;
  for (var i = (targetLine - currentLine); i > 0; i--) {
    opts.top.line++;
    code += '\n';
  }

  code += opts.indent + '}, 0)'

  return code;
};

var DefNode = Rp.DefNode = function(def, singleton, fname, args, body, end) {
  ScopeNode.call(this, null, body);
  // do this early..
  this.line = def.line;
  this.singleton = singleton;
  this.fname = fname;
  this.args = args;
  this.body = body;
  this.endLine = end.line;
  return this;
};

extend(DefNode, ScopeNode);

DefNode.prototype.generate = function(opts) {
  var code = '$def(';

  // singleton
  if (this.singleton) {
    code += this.singleton.generate(opts);
  } else {
    code += (new SelfNode({})).generate(opts);
  }

  code += ', ';

  // method id
  code += '"' + this.fname.value + '", ';

  // all method arg names to be placed in function arg list
  var method_args = [];
  // all pre code - opt arg fixing, rest args, tmp variable names, and norm variable names.
  // This will also include the block capture for the function, and an initial try { expr
  // if we need to catch any errors within the method itself... all in all, lots goes in
  // here. Tmp var names must be inserted (or appear before) opt arg fixing, as that might
  // require the use of tmp variables.
  var pre_code = 'var $A = arguments, $M = $A.callee, $L = $A.length;';

  // stmt code
  var scope = { indent: opts.indent + INDENT, top: opts.top, scope: this };
  // generate args, method fixes etc. we do this before the body as it simply 
  // means that we are creating stataments on the fly and unshifting them onto
  // the current statements... magical!
  var args = this.args;

  // norm
  if (args[0]) {
    for (var i = 0; i < args[0].length; i++) {
      // this.push_arg(args[0].value);
      this.paramVariable(args[0][i].value);
      method_args.push(args[0][i].value);
    }
  }

  // opt
  if (args[1]) {
    for (i = 0; i < args[1].length; i++) {
      this.paramVariable(args[1][i][0].value);
      method_args.push(args[1][i][0].value);
    }
  }

  // rest
  if (args[2]) {
    this.paramVariable(args[2].value);
    method_args.push(args[2].value);
    pre_code += (args[2].value + ' = [].slice.call($A, ' + (method_args.length - 1) + ');');
  }

  if (args[3]) {
    this.paramVariable(args[3].value);
    this._block_arg_name = args[3].value;
  }

  this.body.returns();
  var stmt = this.body.generate(scope, LEVEL_TOP);

  method_args.unshift('self');

  code += "function(";
  // need to insert all args, local vars, opt_arg fixes and ivar fixes
  code += method_args.join(', ');
  code += ") { ";
  // dont put pre_code on new line.. keep it on def line to maintain correct lines. Its
    // better to clog up end of def line as its unimportant, and all pre_code is boring
    // boilerplate stuff which the user shouldnt/doesnt need to care about.

  pre_code = ('var ' + this.scopeVars.join(', ') + ';') + pre_code;

  // ivars
  for (var i = 0; i < this.ivars.length; i++) {
    pre_code += ('if (self["' + this.ivars[i] + '"] == undefined) {self["' + this.ivars[i] + '"] = nil;}');
  }

  // block arg
  if (this._block_arg_name) {
    pre_code += ('var $yield, ' + this._block_arg_name + '; if ($B.f == $M) { ' + this.block_arg_name + ' = ');
    pre_code += ('$yield = $B.p; } else { ' + this.block_arg_name + ' = nil; ');
    pre_code += 'var $yself = $yield.$proc[0];'
  }
  code += pre_code;
  code += stmt;

  // fix trailing }) as well as 0/1 for normal/singleton
  code += (this.fixLineNumber(opts, this.endLine) + '}, ' + (this.singleton ? '1' : '0') + ')');

  return code;
};

var BodyStatementsNode = Rp.BodyStatementsNode = function(stmt, rescue, optelse, optensure) {
  // StatementsNode.call(this, stmt.statements);
  this.statements = stmt;
  this.opt_rescue = rescue;
  this.opt_else = optelse;
  this.opt_ensure = optensure;
};

extend(BodyStatementsNode, BaseNode);

BodyStatementsNode.prototype.returns = function() {
  return this.statements.returns();
};


BodyStatementsNode.prototype.generate = function(opts, level) {
  return this.statements.generate(opts, level);
};

var OrNode = Rp.OrNode = function(node, lhs, rhs) {
  this.line = node.line;
  this.lhs = lhs;
  this.rhs = rhs;
};

extend(OrNode, BaseNode);

OrNode.prototype.generate = function(opts) {
  var res = '((';
  var tmp = opts.scope.temp_local();
  res += (tmp + ' = ' + this.lhs.generate(opts, LEVEL_LIST) + ').$r ? ');
  res += (tmp + ' : ' + this.rhs.generate(opts, LEVEL_LIST) + ')');
  // queue tmp
  opts.scope.queue_temp(tmp);
  return res;
};

var AndNode = Rp.AndNode = function(node, lhs, rhs) {
  this.line = node.line;
  this.lhs = lhs;
  this.rhs = rhs;
};

extend(AndNode, BaseNode);

AndNode.prototype.generate = function(opts) {
  var res = '((';
  var tmp = opts.scope.temp_local();
  res += (tmp + ' = ' + this.lhs.generate(opts, LEVEL_LIST) + ').$r ? ');
  res += (this.rhs.generate(opts, LEVEL_LIST) + ' : ' + tmp + ')');
  // queue tmp
  opts.scope.queue_temp(tmp);
  return res;
};

var ArrayNode = Rp.ArrayNode = function(parts, begin, end) {
  this.line = begin.line;
  this.endLine = end.line;
  this.args = parts;
  return this;
};

extend(ArrayNode, BaseNode);

ArrayNode.prototype.generate = function(opts) {
  var code = '', old_indent = opts.indent;

  opts.indent += INDENT;

  for (var i = 0 ; i < this.args[0].length; i++) {
    if (i > 0) code += ', ';
    code += this.args[0][i].process(opts, LEVEL_LIST);
  }

  opts.indent = old_indent;
  return '[' + code + this.fixLineNumber(opts, this.endLine) + ']';
};

var HashNode = Rp.HashNode = function(parts, begin, end) {
  this.line = begin.line;
  this.endLine = end.line;
  this.parts = parts;
  return this;
};

extend(HashNode, BaseNode);

HashNode.prototype.generate = function(opts) {
  var code = '', part, old_indent = opts.indent;
  
  opts.indent += INDENT;

  for (var i = 0; i < this.parts.length; i++) {
    part = this.parts[i];
    if (i > 0) code += ', ';
    code += part[0].process(opts, LEVEL_LIST);
    code += ', ';
    code += part[1].process(opts, LEVEL_LIST);
  }

  opts.indent = old_indent;

  code = '$hash(' + code;

  return code + this.fixLineNumber(opts, this.endLine) + ')';

  // return '$hash(' + code + ')';
};

var IfNode = Rp.IfNode = function(beg, expr, stmt, tail, end) {
  this.line = beg.line;
  this.expr = expr;
  this.stmt = stmt;
  this.tail = tail;
  this.endLine = end.line;
};

extend(IfNode, BaseNode);

IfNode.prototype.returns = function() {
  this.stmt.returns();

  for (var i = 0; i < this.tail.length; i++) {
    var tail = this.tail[i];

    if (tail[0].value == 'elsif') {
      tail[2].returns();
    } else {
      // else
      tail[1].returns();
    }
  }
  return this;
};

IfNode.prototype.isExpression = function() {
  return this._exprLevel;
};

IfNode.prototype.generate = function(opts, level) {
  var code = '', done_else = false, old_indent = opts.indent, tail;

  opts.indent += INDENT;

  // stmt_level is level_top, unless we are an expression.. then it is level_top_closure
  var stmt_level = level === LEVEL_EXPR ? LEVEL_TOP_CLOSURE : LEVEL_TOP;

  if (stmt_level === LEVEL_TOP_CLOSURE) {
    this.returns();
    this._exprLevel = true;
  }

  code += 'if (' + this.expr.generate(opts) + '.$r) {';

  code += this.stmt.process(opts, stmt_level);

  for (var i = 0; i < this.tail.length; i++) {
    tail = this.tail[i];
    opts.indent = old_indent;

    code += this.fixLineNumber(opts, tail[0].line);
    
    if (tail[0].value == 'elsif') {
      code += '} else if (' + tail[1].generate(opts) + '.$r) {';
      opts.indent += INDENT;
      code += tail[2].process(opts, stmt_level);

    } else {
      done_else = true;
      code += '} else {';
      opts.indent += INDENT;
      code += tail[1].process(opts, stmt_level);
    }
  }

  if (this.forceElse) {
    // generate an else statement if we MUST have one. If, for example, we set
    // the result of ourselves to a variable, we must have an else part which
    // simply returns nil.
  }

  opts.indent = old_indent;

  code += (this.fixLineNumber(opts, this.endLine) + '}');

  // if we are an expression, we need to wrap ourself as a closure..
  if (level === LEVEL_EXPR) {
    code = '(function() {' + code + '})()';
  }

  return code;
};

var ConstantNode = Rp.ConstantNode = function(name) {
  this.line = name.line;
  this.name = name.value;
  return this;
};

extend(ConstantNode, BaseNode);

ConstantNode.prototype.generate = function(opts) {
  return 'rb_vm_cg(' + (new SelfNode({})).generate(opts) + ', "' + this.name + '")';
};

var Colon2Node = Rp.Colon2Node = function(lhs, name) {
  this.lhs = lhs;
  this.line = name.line;
  this.name = name.value;
};

extend(Colon2Node, BaseNode);

Colon2Node.prototype.generate = function(opts) {
  return 'rb_vm_cg(' + this.lhs.generate(opts) + ', "' + this.name + '")';
};

var AssignNode = Rp.AssignNode = function(lhs, rhs, assign) {
  this.line = lhs.line;
  this.lhs = lhs;
  this.rhs = rhs;
  return this;
};

extend(AssignNode, BaseNode);

AssignNode.prototype.generate = function(opts, level) {
  var code = '';

  if (this.lhs instanceof IvarNode) {
    return (new SelfNode({})).generate(opts) + '["' + this.lhs.name + '"] = ' + this.rhs.generate(opts, LEVEL_EXPR);
  } else if (this.lhs instanceof IdentifierNode) {
    opts.scope.ensureVariable(this.lhs.name);
    return this.lhs.name + ' = ' + this.rhs.generate(opts, LEVEL_EXPR);
  } else if (this.lhs instanceof CallNode) {
    return (new CallNode(
      this.lhs.recv,
      { value: this.lhs.mid + '=', line: this.line },
      [[this.rhs]])
    ).generate(opts);

  } else if (this.lhs instanceof ConstantNode) {
    return 'rb_vm_cs(self, "' + this.lhs.name + '", ' + this.rhs.generate(opts, LEVEL_EXPR) + ')';

  } else if (this.lhs instanceof ArefNode) {
    return (new AsetNode(this.lhs.recv, this.lhs.arefs, this.rhs)).process(opts, level);
  } else {
    console.log(this.lhs);
    throw new Error("line " + this.line + ": bad lhs for assign");
  }
};

var OpAsgnNode = Rp.OpAsgnNode = function(asgn, lhs, rhs) {
  this.lhs = lhs;
  this.rhs = rhs;
  this.line = asgn.line;
  this.asgn = asgn;
};

extend(OpAsgnNode, BaseNode);

OpAsgnNode.prototype.generate = function(opts) {
  var assign;
  if (this.asgn.value == '||') {
    assign = new OrNode({value: '||', line: this.line }, this.lhs, new AssignNode(this.lhs, this.rhs));
  } else if (['+', '-', '/', '*'].indexOf(this.asgn.value) != -1) {
    assign = new AssignNode(this.lhs, new CallNode(this.lhs, this.asgn, [[this.rhs]]));
  } else {
    console.log(this.asgn);
    throw new Error("bad asgn type for opasgn");
  }
  return assign.generate(opts);
};

var IvarNode = Rp.IvarNode = function(name) {
  this.line = name.line;
  this.name = name.value;
};

extend(IvarNode, BaseNode);

IvarNode.prototype.generate = function(opts) {
  opts.scope.ensureIvar(this.name);
  return (new SelfNode({})).generate(opts) + '["' + this.name + '"]';
};

var IdentifierNode = Rp.IdentifierNode= function(name) {
  this.line = name.line;
  this.name = name.value;
};

extend(IdentifierNode, BaseNode);

IdentifierNode.prototype.generate = function(opts) {
  // for now assume it is an identifier
  if (opts.scope.findVariable(this.name)) {
    return this.name;
  } else {
    return (new CallNode(null, {value: this.name, line: this.line}, [[]])).generate(opts);
  }
};



// just return out of js scope
var FuncReturnNode = function(val) {
  this.val = val;
  this.line = val.line;
};

extend(FuncReturnNode, BaseNode);

FuncReturnNode.prototype.generate = function(opts) {
  return 'return ' + this.val.generate(opts);
};

var StringNode = Rp.StringNode = function(parts, end) {
  this.line = end.line;
  this.parts = parts;
  this.join = end.value;
};

extend(StringNode, BaseNode);

StringNode.prototype.generate = function(opts) {
  var code = '';
  if (this.parts.length == 0) return '""';

  if (this.parts.length == 1) {
    if (this.parts[0][0] == 'string_content') {
      return this.join + this.parts[0][1].value + this.join;
    }
  } else {
    code = '(';
    var part;
    for (var i = 0; i < this.parts.length; i++) {
      part = this.parts[i];
      if (i > 0) code += ' + ';

      if (part[0] == 'string_content') {
        code += (this.join + part[1].value + this.join);
      } else if (part[0] == 'string_dbegin') {
        code += (new CallNode(part[1], { value:'to_s', line:0}, [[]])).generate(opts);
      }
    }
    code += ')'
  }

  return code;
};

var TrueNode = Rp.TrueNode = function(val) {
  this.line = val.line;
};

extend(TrueNode, BaseNode);

TrueNode.prototype.generate = function(opts) {
  return 'Qtrue';
};


var FalseNode = Rp.FalseNode = function(val) {
  this.line = val.line;
};

extend(FalseNode, BaseNode);

FalseNode.prototype.generate = function(opts) {
  return 'Qfalse';
};

var BlockNode = Rp.BlockNode = function(start, vars, stmt, end) {
  ScopeNode.call(this, null, stmt);
  this.line = start.line;
  this.args = vars;
  this.stmt = stmt;
  this.endLine = end.line;
};

extend(BlockNode, ScopeNode);

BlockNode.prototype.generate = function(opts) {
  this.parent = opts.scope;

  var pre_code = '';

  var code = '';

  var arg;

  var scope = { scope: this, top: opts.top, indent: opts.indent + INDENT };

  var args = this.args[0], method_args = [];

  if (args) {
    // norm
    if (args[0]) {
    // console.log(args[0]);
    // console.log("length is " + args[0].length);
    for (var i = 0; i < args[0].length; i++) {
      // console.log(args[0][i]);
      // this.push_arg(args[0].value);
      this.paramVariable(args[0][i].value);
      method_args.push(args[0][i].value);

      // argument checking - default to nil
      if (true) {
        pre_code += ("if (" + args[0][i].value + " === undefined) {" + args[0][i].value + " = nil; }");
      }
    }
  }

  // opt
  if (args[1]) {
    for (i = 0; i < args[1].length; i++) {
      arg = args[1][i];
      method_args.push(arg[0].value);
      this.paramVariable(arg[0].value);
      pre_code =+ ("if(" + arg[0].value + " === undefined) { " + arg[0].value + " = " + arg[1].generate(opts, level) + "; }");
    }
  }

    // rest
    if (args[2]) {
      method_args.push(args[2].value);
      this.paramVariable(args[2].value);
      pre_code += (args[2].value + ' = [].slice.call(arguments, ' + (method_args.length) + ');');
    }

  }

  this.stmt.returns();
  var stmt = this.stmt.process(scope, LEVEL_TOP);
  method_args.unshift('self');

  code += 'function(';
  code += method_args.join(', ');
  code += ') {';

  if (this.scopeVars.length > 0) {
    code += ('var ' + this.scopeVars.join(', ') + ';');
  }

  code += stmt;

  code += (this.fixLineNumber(opts, this.endLine) + '}');

  return code;
};

var XStringNode = Rp.XStringNode = function(beg, parts, end) {
  this.line = beg.line;
  this.parts = parts;
  this.endLine = end.line;
};

extend(XStringNode, BaseNode);

XStringNode.prototype.returns = function() {
  // we dont return.. or do we?
  return this;
};

// treat ourself like an expression. All XString code should add their own
// semi-colons etc, so we can include for, if, return statements etc.
XStringNode.prototype.isExpression = function() {
  return false;
};

XStringNode.prototype.generate = function(opts) {
  var code = '', part;
  
  for (var i = 0; i < this.parts.length; i++) {
    part = this.parts[i];

    if (part[0] == 'string_content') {
      code += part[1].value;
    } else if (part[0] == 'string_dbegin') {
      code += part[1].generate(opts);
    }
  }

  code += this.fixLineNumber(opts, this.endLine);
  return code;
};

var IfModNode = Rp.IfModNode = function(type, expr, stmt) {
  this.line = type.line;
  this.type = type.value;
  this.expr = expr;
  this.stmt = stmt;
};

extend(IfModNode, BaseNode);

IfModNode.prototype.returns = function() {
  this.returns = true;
  this.stmt = stmt.returns();
  return this;
};

IfModNode.prototype.generate = function(opts, level) {
  if (this.returns) stmt.returns();
  var code = '';
  code += ('if (' + (this.type == 'if' ? '' : '!') + this.expr.generate(opts, LEVEL_EXPR) + '.$r) {');
  code += (this.stmt.process(opts, level) + '}');

  if (this.returns) code += " else { return nil; }"
  return code;
};

var ParenNode = Rp.ParenNode = function(opening, parts, closing) {
  this.line = opening.line;
  this.parts = parts;
  this.endLine = closing.line;
}

extend(ParenNode, BaseNode);

ParenNode.prototype.generate = function(opts) {
  var parts = [];

  for (var i = 0; i < this.parts.nodes.length; i++) {
    parts.push(this.parts.nodes[i].generate(opts));
  }

  // empty paren list
  if (parts.length == 0) {
    parts.push('nil');
  }

  return '(' + parts.join(', ') + ')';
};

var ArefNode = Rp.ArefNode = function(recv, arefs) {
  this.line = recv.line;
  this.recv = recv;
  this.arefs = arefs;
}

extend(ArefNode, BaseNode);

ArefNode.prototype.generate = function(opts) {
  return (new CallNode(this.recv, {value: '[]'}, this.arefs)).generate(opts);
};

var AsetNode = Rp.AsetNode = function(recv, arefs, val) {
  this.line = recv.line;
  this.recv = recv;
  this.arefs = arefs;
  this.val = val;
};

extend(AsetNode, BaseNode);

AsetNode.prototype.generate = function(opts) {
  this.arefs[0].push(this.val);
  return (new CallNode(this.recv, {value: '[]='}, this.arefs)).generate(opts);
  // return this.recv.generate(opts);
};

var BlockGivenNode = Rp.BlockGivenNode = function(given) {
  this.line = given.line;
};

extend(BlockGivenNode, BaseNode);

BlockGivenNode.prototype.generate = function(opts) {
  var name = opts.scope.set_uses_block();
  return '(' + name + ' !== nil ? Qtrue : Qfalse)';
};

var YieldNode = Rp.YieldNode = function(start, args) {
  this.line = start.line;
  this.args = args;
};

extend(YieldNode, BaseNode);

YieldNode.prototype.generate = function(opts) {
  // need to get block from nearet method
  var block = opts.scope.set_uses_block();
  var code = '';

  var parts = ['$yself'], args = this.args;

  if (args[0]) {
    for (var i = 0; i < args[0].length; i++) {
      parts.push(args[0][i].generate(opts));
    }
  }

  return block + '.call(' + parts.join(', ') + ')';
};

var ReturnNode = Rp.ReturnNode = function(ret, val) {
  this.line = ret.line;
  this.args = val;
};

extend(ReturnNode, BaseNode);

ReturnNode.prototype.returns = function() {
  return this;
};

ReturnNode.prototype.generate = function(opts, level) {
  var code = '', args = this.args;

  if (!args[0]) {
    code = (new NilNode({})).generate(opts);
  } else if (args[0].length === 1) {
    code = args[0][0].generate(opts);
  } else {
    code = (new NilNode({})).generate(opts);
  }

  // if we are in block, we need to throw return to the nearest method
  if (!(opts.scope instanceof DefNode)) {
    var return_func = '__return_func';
    return '$return(' + code + ', ' + return_func + ')';
  }
  // level top, we are running full statements, so just return normally
  else if (level == LEVEL_TOP) {
    return 'return ' + code;
  } else {
    return '$return(' + code + ')';
  }
};

var BeginNode = Rp.BeginNode = function(begin, body, end) {
  this.line = begin.line;
  this.body = body;
  this.endLine = end.line;
};

extend(BeginNode, BaseNode);

BeginNode.prototype.generate = function(opts) {
  var code = 'try {', old_indent = opts.indent;
  opts.indent += INDENT;

  code += this.body.process(opts, LEVEL_TOP);
  code += '} catch(__err__) {';

  // console.log(this.body.opt_rescue);
  for (var i = 0; i < this.body.opt_rescue.length; i++) {
    var rescue = this.body.opt_rescue[i];

    // need to comapre error types
    code += (this.fixLineNumber(opts, rescue[0].line) + 'if (true) {');
    opts.indent += INDENT;
    code += (rescue[3].process(opts, LEVEL_TOP) + '}');
    opts.indent = old_indent + INDENT;
  }

  opts.indent = old_indent;
  code += (this.fixLineNumber(opts, this.endLine) + '}');
  return code;
};

var GvarNode = Rp.GvarNode = function(val) {
  this.line = val.line;
  this.value = val.value;
};

extend(GvarNode, BaseNode);

GvarNode.prototype.generate = function() {
  return "$runtime.gg('" + this.valyue + "')";
};

var FileNode = Rp.FileNode = function(val) {
  this.line = val.line;
};

extend(FileNode, BaseNode);

FileNode.prototype.generate = function() {
  return '__FILE__';
};

var LineNode = Rp.LineNode = function(val) {
  this.line = val.line;
  this.val = val.value;
}

extend(LineNode, BaseNode);

LineNode.prototype.generate = function(opts) {
  return this.val;
};

var RegexpNode = Rp.RegexpNode = function(begn, parts) {
  this.line = begn.line;
  this.parts = parts;
};

extend(RegexpNode, BaseNode);

RegexpNode.prototype.generate = function(opts) {
  var parts = [], part;

  for (var i = 0, ii = this.parts.length; i < ii; i++) {
    part = this.parts[i];

    if (part[0] == 'string_content') {
      parts.push(part[1].value);
    } else if (part[0] == 'string_dbegin') {
      parts.push(part[1].generate(opts, LEVEL_EXPR));
    }
  }

  return '/' + parts.join('') + '/';
};

